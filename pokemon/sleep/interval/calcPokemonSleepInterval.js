#!/usr/bin/env node
"use strict";

const fs = require("fs");
const readlineSync = require("readline-sync");
const { AutoComplete } = require("enquirer");

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

(async function main() {
  // --- TSV読み込み ---
  const pokemons = loadPokemons("./estimatedValueTable.tsv");

  // --- ポケモン選択 ---
  const pokemon = await selectPokemon(pokemons);
  const 食材確率 = pokemon.食材確率;

  console.log(`\n選択されたポケモン: ${pokemon.name}`);
  console.log(`食材確率: ${(食材確率 * 100).toFixed(2)}%\n`);

  // --- 数値入力 ---
  const 最大所持数 = readlineSync.questionFloat("最大所持数を入力してください: ");
  const 速度 = readlineSync.questionFloat("速度を入力してください: ");
  const 食材の個数 = readlineSync.questionFloat("食材の個数を入力してください: ");
  const きのみの個数 = readlineSync.questionFloat("きのみの個数を入力してください: ");

  // --- 計算 ---
  const 一回あたりの個数 =
    食材確率 * 食材の個数 + (1 - 食材確率) * きのみの個数;

  const 分 = (最大所持数 / 一回あたりの個数) * (速度 / 2.222);
  const 時間 = Math.floor(分 / 60);
  const 分残り = 分 % 60;

  // --- 出力 ---
  console.log("\n=== 結果 ===");
  console.log(`分（合計）: ${分.toFixed(2)} 分`);
  console.log(`時間換算: ${時間} 時間 ${分残り.toFixed(2)} 分`);
})();
