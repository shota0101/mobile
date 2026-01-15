const readlineSync = require("readline-sync");

const 最大所持数 = readlineSync.questionFloat("最大所持数を入力してください: ");
const 速度 = readlineSync.questionFloat("速度を入力してください: ");
const 食材確率 = readlineSync.questionFloat("食材確率を入力してください（例: 0.174）: ");
const 食材の個数 = readlineSync.questionFloat("食材の個数を入力してください: ");
const きのみの個数 = readlineSync.questionFloat("きのみの個数を入力してください: ");

const 一回あたりの個数 =
    食材確率 * 食材の個数 + (1 - 食材確率) * きのみの個数;

const 分 = (最大所持数 / 一回あたりの個数) * (速度 / 2.222);
const 時間 = 分 / 60;
const 秒 = 分 % 60;

console.log("\n=== 結果 ===");
console.log(`分（合計）: ${分}`);
console.log(`時間換算: ${Math.floor(時間)}時間 ${秒.toFixed(2)}分`);
