#!/usr/bin/env node
"use strict";

const fs = require("fs");
const readlineSync = require("readline-sync");
const { AutoComplete } = require("enquirer");

const 性格補正倍率 = {
  無し: 1.0,
  上昇: 1.2,
  下降: 0.8,
};

const サブスキル補正倍率 = {
  M: 1.36,
  S: 1.18,
};


/**
 * TSVを読み込んでポケモン情報を作る
 */
function loadPokemons(path) {
  const tsv = fs.readFileSync(path, "utf8");

  return tsv
    .split("\n")
    .map(line => line.trim())
    .filter(line => line.length > 0)
    .map((line, index) => {
      const cols = line.split("\t");

      const rawProb = cols[2];

      // 食材確率がない or %で終わってない行は無効
      if (!rawProb || !rawProb.endsWith("%")) {
        return null;
      }

      const 食材確率 = Number(rawProb.replace("%", "")) / 100;

      if (Number.isNaN(食材確率)) {
        return null;
      }

      return {
        name: cols[0],
        食材確率,
      };
    })
    .filter(Boolean);
}

/**
 * ポケモンをインクリメンタルサーチで選択
 */
async function selectPokemon(pokemons) {
  const prompt = new AutoComplete({
    name: "pokemon",
    message: "ポケモンを選択してください",
    limit: 10,
    choices: pokemons.map((p) => ({
      name: `${p.name}（食材:${(p.食材確率 * 100).toFixed(1)}%）`,
      value: p,
    })),
  });

  return await prompt.run();
}

/**
 * 計算結果をファイルに保存する
 *
 * @param {Object} params
 * @param {string} params.pokemonName - ポケモン名
 * @param {number} params.totalMinutes - 合計分（小数）
 * @param {number} params.maxCapacity - 最大所持数
 * @param {Object} params.input - 入力値まとめ
 * @param {Object} params.result - 計算結果まとめ
 */
function saveResultToFile({
  pokemonName,
  totalMinutes,
  maxCapacity,
  input,
  result,
}) {
  // ファイル名用：分は四捨五入
  const roundedMinutes = Math.round(totalMinutes);
  
  const sanitizeFileName = (str) =>
    str.replace(/[\\\/:*?"<>|]/g, "_");

  const fileName = sanitizeFileName(
    `${roundedMinutes}分_${pokemonName}_${maxCapacity}.txt`
  );

  const text = `
=== ポケモンスリープ 所持数計算ログ ===

■ ポケモン
名前: ${pokemonName}
ベース食材確率: ${(input.baseIngredientRate * 100).toFixed(2)}%

■ 補正
性格補正: ×${input.personalityMultiplier}
サブスキル 食材確率アップM: ${input.hasM ? "あり" : "なし"}（×${input.skillMMultiplier}）
サブスキル 食材確率アップS: ${input.hasS ? "あり" : "なし"}（×${input.skillSMultiplier}）

最終食材確率: ${(result.finalIngredientRate * 100).toFixed(2)}%

■ 入力値
最大所持数: ${maxCapacity}
速度: ${input.speed}
食材の個数: ${input.ingredientCount}
きのみの個数: ${input.berryCount}

■ 計算結果
1回あたりの獲得数: ${result.itemsPerHelp.toFixed(4)}
合計時間: ${totalMinutes.toFixed(2)} 分
時間換算: ${result.hours} 時間 ${result.minutes.toFixed(2)} 分

====================================
`.trim() + "\n";

  fs.writeFileSync(fileName, text, "utf8");

  return fileName;
}

(async function main() {
  const pokemons = loadPokemons("./estimatedValueTable.tsv");
  
  // --- ポケモン選択 ---
  const pokemon = await selectPokemon(pokemons);

  console.log(`選択されたポケモン: ${pokemon.name}`);

  const 性格選択 = readlineSync.keyInSelect(
    ["無し","上昇", "下降"],
    "性格による食材確率補正を選択してください"
  );

  const 性格補正 =
	性格選択 === -1
	? 性格補正倍率["無し"]
	: 性格補正倍率[["無し", "上昇", "下降"][性格選択]];

  const hasM = readlineSync.keyInYN("サブスキル「食材確率アップM」は付いていますか？");
  const hasS = readlineSync.keyInYN("サブスキル「食材確率アップS」は付いていますか？");
  
  const サブスキルM補正 = hasM ? サブスキル補正倍率.M : 1.0;
  const サブスキルS補正 = hasS ? サブスキル補正倍率.S : 1.0;

  const 食材確率 =
	pokemon.食材確率 *
	性格補正 *
	サブスキルM補正 *
	サブスキルS補正;

  console.log(`食材確率（ベース）: ${(pokemon.食材確率 * 100).toFixed(2)}%`);
  console.log(`食材確率（補正後）: ${(食材確率 * 100).toFixed(2)}%`);

  const 最大所持数 = readlineSync.questionFloat("最大所持数を入力してください: ");
  const 速度 = readlineSync.questionFloat("速度を入力してください: ");
  const 食材の個数 = readlineSync.questionFloat("食材の個数を入力してください: ");
  const きのみの個数 = readlineSync.questionFloat("きのみの個数を入力してください: ");

  const 一回あたりの個数 =
    食材確率 * 食材の個数 + (1 - 食材確率) * きのみの個数;
  console.log(`一回あたりの個数: ${(一回あたりの個数).toFixed(2)}`);

  const 分 = (最大所持数 / 一回あたりの個数) * (速度 / 2.222);
  const 時間 = Math.floor(分 / 60);
  const 分残り = 分 % 60;

  console.log(`分（合計）: ${分.toFixed(2)} 分`);
  console.log(`時間換算: ${時間} 時間 ${分残り.toFixed(2)} 分`);

  const savedFile = saveResultToFile({
    pokemonName: pokemon.name,
    totalMinutes: 分,
    maxCapacity: 最大所持数,
    input: {
      baseIngredientRate: pokemon.食材確率,
      personalityMultiplier: 性格補正,
      hasM,
      hasS,
      skillMMultiplier: サブスキルM補正,
      skillSMultiplier: サブスキルS補正,
      speed: 速度,
      ingredientCount: 食材の個数,
      berryCount: きのみの個数,
    },
    result: {
      finalIngredientRate: 食材確率,
      itemsPerHelp: 一回あたりの個数,
      hours: 時間,
      minutes: 分残り,
    },
  });
  
  console.log(`📄 結果を保存しました: ${savedFile}`);
})();

