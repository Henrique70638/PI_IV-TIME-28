/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

const assert = require("assert");
const { distanciaKm } = require("./geo");

assert.ok(Math.abs(distanciaKm(0, 0, 0, 1) - 111.195) < 0.05);
assert.ok(Math.abs(distanciaKm(-22.91, -47.065, -22.9208, -47.065) - 1.2) < 0.01);
assert.strictEqual(distanciaKm(-22.9, -47.06, -22.9, -47.06), 0);

console.log("geo.test.js: ok");
