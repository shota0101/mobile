#!/usr/bin/env node
"use strict";

const fs = require("fs");
const readlineSync = require("readline-sync");
const { AutoComplete } = require("enquirer");

/* ===============================
 * 定数定義
 * =============================== */
const 性格補正倍率 = {
  上昇: 1.2,
  下降: 0.8,
  無し: 1.0,
};

const サブスキル補正倍率 = {
  M: 1.36,
  S: 1.18,
};

/* ===============================
 * TSV 読み込み
 * =============================== */
function loadPokemons(path) {
  const tsv = fs.readFileSync(path, "utf8");

  return tsv
    .split("\n")
    .map(line => line.trim())
    .filter(line => line.length > 0)
    .map((line, index) => {
      const cols = line.split("\t");
      const rawProb = cols[2];

      // 食材確率がない行（例: ピカチュウ(ハロウィン)）は除外
      if (!rawProb || !rawProb.endsWith("%")) {
        console.error(
          `WARN: ${index + 1}行目をスキップ（食材確率なし）: ${cols[0]}`
        );
        return null;
      }

      const 食材確率 = Number(rawProb.replace("%", "")) / 100;
      if (Number.isNaN(食材確率)) {
        console.error(
          `WARN: ${index + 1}行目をスキップ（数値変換失敗）: ${cols[0]}`
        );
        return null;
      }

      return {
        name: cols[0],
        食材確率,
      };
    })
    .filter(Boolean);
}

/* ===============================
 * ポケモン選択
 * =============================== */
async function selectPokemon(pokemons) {
  const prompt = new AutoComplete({
    name: "pokemon",
    message: "ポケモンを選択してください",
    limit: 10,
    choices: pokemons.map(p => ({
      name: `${p.name}（食材 ${(p.食材確率 * 100).toFixed(1)}%）`,
      value: p,
    })),
  });

  return await prompt.run();
}

/* ===============================
 * ファイル保存（引数なし）
 * =============================== */
function saveResultToFile() {
  const roundedMinutes = Math.round(分);

  const sanitizeFileName = (str) =>
    str.replace(/[\\\/:*?"<>|]/g, "_");

  const fileName = sanitizeFileName(
    `${roundedMinutes}分_${pokemon.name}_${最大所持数}.txt`
  );

  const text = `
=== ポケモンスリープ 所持数計算ログ ===

■ ポケモン
名前: ${pokemon.name}
ベース食材確率: ${(ベース食材確率 * 100).toFixed(2)}%

■ 補正
性格補正: ×${性格補正}
サブスキル 食材確率アップM: ${hasM ? "あり" : "なし"}（×${サブスキルM補正}）
サブスキル 食材確率アップS: ${hasS ? "あり" : "なし"}（×${サブスキルS補正}）

最終食材確率: ${(食材確率 * 100).toFixed(2)}%

■ 入力値
最大所持数: ${最大所持数}
速度: ${速度}
食材の個数: ${食材の個数}
きのみの個数: ${きのみの個数}

■ 計算結果
1回あたりの獲得数: ${一回あたりの個数.toFixed(4)}
合計時間: ${分.toFixed(2)} 分
時間換算: ${時間} 時間 ${分残り.toFixed(2)} 分

====================================
`.trim() + "\n";

  fs.writeFileSync(fileName, text, "utf8");

  // console 出力はファイル名のみ
  console.log(fileName);
}

/* ===============================
 * main
 * =============================== */
(async function main() {
  try {
    const pokemons = loadPokemons("./estimatedValueTable.tsv");
    pokemon = await selectPokemon(pokemons);

    // --- 入力 ---
    最大所持数 = readlineSync.questionFloat("最大所持数: ");
    速度 = readlineSync.questionFloat("速度: ");
    食材の個数 = readlineSync.questionFloat("食材の個数: ");
    きのみの個数 = readlineSync.questionFloat("きのみの個数: ");

    // --- 補正 ---
    const 性格選択 = readlineSync.keyInSelect(
      ["上昇", "下降", "無し"],
      "性格による食材確率補正"
    );
    性格補正 =
      性格選択 === -1
        ? 性格補正倍率.無し
        : 性格補正倍率[["上昇", "下降", "無し"][性格選択]];

    hasM = readlineSync.keyInYN("サブスキル 食材確率アップM は付いていますか？");
    hasS = readlineSync.keyInYN("サブスキル 食材確率アップS は付いていますか？");

    サブスキルM補正 = hasM ? サブスキル補正倍率.M : 1.0;
    サブスキルS補正 = hasS ? サブスキル補正倍率.S : 1.0;

    // --- 計算 ---
    ベース食材確率 = pokemon.食材確率;

    食材確率 = Math.min(
      ベース食材確率 *
        性格補正 *
        サブスキルM補正 *
        サブスキルS補正,
      1.0
    );

    一回あたりの個数 =
      食材確率 * 食材の個数 + (1 - 食材確率) * きのみの個数;

    分 = (最大所持数 / 一回あたりの個数) * (速度 / 2.222);
    時間 = Math.floor(分 / 60);
    分残り = 分 % 60;

    // --- 保存 ---
    saveResultToFile();

  } catch (err) {
    console.error("ERROR:", err.message);
    process.exit(1);
  }
})();

/* ===============================
 * グローバル変数（最小限）
 * =============================== */
let pokemon;
let 最大所持数, 速度, 食材の個数, きのみの個数;
let ベース食材確率, 食材確率;
let 性格補正, サブスキルM補正, サブスキルS補正;
let hasM, hasS;
let 一回あたりの個数, 分, 時間, 分残り;
