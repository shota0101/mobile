#!/usr/bin/env node
"use strict";

const fs = require("fs");
const readlineSync = require("readline-sync");
const { AutoComplete } = require("enquirer");

/* ===============================
 * 定数
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

const おてつだいボーナス補正 = [1.0, 0.95, 0.9, 0.85, 0.8, 0.75];
const 一緒に眠った時間Options = [
  { key: "0", value: "0000時間" },
  { key: "1", value: "0200時間" },
  { key: "2", value: "0500時間" },
  { key: "3", value: "1000時間" },
  { key: "4", value: "2000時間" },
];
const 性格補正ByInput = {
  u: 性格補正倍率.上昇,
  d: 性格補正倍率.下降,
  "": 性格補正倍率.無し,
};

/* ===============================
 * TSV 読み込み
 * =============================== */
function loadPokemons(path) {
  const tsv = fs.readFileSync(path, "utf8");

  return tsv
    .split("\n")
    .map(line => line.trim())
    .filter(Boolean)
    .map((line, index) => {
      const cols = line.split("\t");
      const rawProb = cols[2];

      if (!rawProb || !rawProb.endsWith("%")) {
        console.error(`WARN: ${index + 1}行目をスキップ: ${cols[0]}`);
        return null;
      }

      const 食材確率 = Number(rawProb.replace("%", "")) / 100;
      if (Number.isNaN(食材確率)) {
        console.error(`WARN: ${index + 1}行目をスキップ: ${cols[0]}`);
        return null;
      }

      return { name: cols[0], 食材確率 };
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
 * 性格補正入力
 * =============================== */
function questionNatureModifier() {
  while (true) {
    const input = readlineSync.question("性格補正 (u=上昇, d=下降, Enter=無し): ").trim().toLowerCase();
    if (Object.prototype.hasOwnProperty.call(性格補正ByInput, input)) {
      return 性格補正ByInput[input];
    }

    console.log("u, d, 空文字のいずれかで入力してください");
  }
}

/* ===============================
 * Yes/No 入力
 * =============================== */
function questionYesNoDefaultNo(message) {
  while (true) {
    const input = readlineSync.question(`${message} (y/N): `).trim().toLowerCase();
    if (input === "") {
      return false;
    }
    if (input === "y") {
      return true;
    }
    if (input === "n") {
      return false;
    }

    console.log("y, n, 空文字のいずれかで入力してください");
  }
}

/* ===============================
 * 食材の個数入力
 * =============================== */
function questionAverageIngredientCount() {
  const labels = ["1つめ", "2つめ", "3つめ"];

  while (true) {
    const values = labels
      .map(label => readlineSync.question(`食材の個数（${label}）: `).trim())
      .filter(input => input !== "")
      .map(input => Number(input));

    if (values.length === 0) {
      console.log("食材の個数を1つ以上入力してください");
      continue;
    }

    if (values.some(Number.isNaN)) {
      console.log("食材の個数は数値で入力してください");
      continue;
    }

    return values.reduce((sum, value) => sum + value, 0) / values.length;
  }
}

/* ===============================
 * 一緒に眠った時間入力
 * =============================== */
function questionSleepTime() {
  while (true) {
    console.log("一緒に眠った時間:");
    一緒に眠った時間Options.forEach(option => {
      console.log(`  ${option.key}: ${option.value}`);
    });

    const input = readlineSync.question("番号を選択してください: ").trim();
    const selectedOption = 一緒に眠った時間Options.find(option => option.key === input);
    if (selectedOption) {
      return selectedOption.value;
    }

    console.log("0〜4の番号で入力してください");
  }
}

/* ===============================
 * 保存（引数なし）
 * =============================== */
function saveResultToFile(resultsByBonus) {
  const result5 = resultsByBonus[5];
  const roundedMinutes = Math.round(result5.totalMinutes);

  const sanitize = s => s.replace(/[\\\/:*?"<>|]/g, "_");
  const fileName = sanitize(
    `${roundedMinutes}分_Lv${Lv}_${一緒に眠った時間}_${pokemon.name}.txt`
  );

  let text = `
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
Lv: ${Lv}
一緒に眠った時間: ${一緒に眠った時間}
速度: ${速度}
食材の個数（平均）: ${食材の個数}
きのみの個数: ${きのみの個数}

■ おてつだい回数
${おてつだい回数} 回

■ おてつだいボーナス別結果
`.trim() + "\n\n";

  for (let i = 0; i <= 5; i++) {
    const r = resultsByBonus[i];
    text += `
[おてつだいボーナス ${i} 個]
合計時間: ${r.totalMinutes.toFixed(2)} 分
時間換算: ${r.hours} 時間 ${r.minutes.toFixed(2)} 分
`.trim() + "\n\n";
  }

  fs.writeFileSync(fileName, text, "utf8");
  console.log(fileName);
}

/* ===============================
 * main
 * =============================== */
(async function main() {
  try {
    const pokemons = loadPokemons("./estimatedValueTable.tsv");
    pokemon = await selectPokemon(pokemons);

    最大所持数 = readlineSync.questionFloat("最大所持数: ");
    速度 = readlineSync.questionFloat("速度: ");
    食材の個数 = questionAverageIngredientCount();
    きのみの個数 = readlineSync.questionFloat("きのみの個数: ");

    性格補正 = questionNatureModifier();

    hasM = questionYesNoDefaultNo("サブスキル 食材確率アップM は付いていますか？");
    hasS = questionYesNoDefaultNo("サブスキル 食材確率アップS は付いていますか？");
    Lv = readlineSync.questionInt("Lv: ");
    一緒に眠った時間 = questionSleepTime();

    サブスキルM補正 = hasM ? サブスキル補正倍率.M : 1.0;
    サブスキルS補正 = hasS ? サブスキル補正倍率.S : 1.0;

    ベース食材確率 = pokemon.食材確率;
    食材確率 = Math.min(
      ベース食材確率 * 性格補正 * サブスキルM補正 * サブスキルS補正,
      1.0
    );

    一回あたりの個数 =
      食材確率 * 食材の個数 + (1 - 食材確率) * きのみの個数;

    // ★ 切り捨て
    おてつだい回数 = Math.floor(最大所持数 / 一回あたりの個数);

    const resultsByBonus = {};

    for (let i = 0; i <= 5; i++) {
      const bonusRate = おてつだいボーナス補正[i];
      const minutes =
        おてつだい回数 * (速度 / 2.222) * bonusRate;

      resultsByBonus[i] = {
        totalMinutes: minutes,
        hours: Math.floor(minutes / 60),
        minutes: minutes % 60,
      };
    }

    saveResultToFile(resultsByBonus);

  } catch (err) {
    console.error("ERROR:", err.message);
    process.exit(1);
  }
})();

/* ===============================
 * 共有変数
 * =============================== */
let pokemon;
let 最大所持数, Lv, 一緒に眠った時間, 速度, 食材の個数, きのみの個数;
let ベース食材確率, 食材確率;
let 性格補正, サブスキルM補正, サブスキルS補正;
let hasM, hasS;
let 一回あたりの個数, おてつだい回数;
