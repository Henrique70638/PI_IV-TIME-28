/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

const assert = require('assert');
const { geohash, distanciaKm } = require('./geo');

assert.strictEqual(geohash(57.64911, 10.40744, 11), 'u4pruydqqvj');
assert.strictEqual(geohash(42.605, -5.603, 5), 'ezs42');
assert.strictEqual(geohash(-22.9056, -47.0608, 5).length, 5);
assert.ok(Math.abs(distanciaKm(0, 0, 0, 1) - 111.195) < 0.05);
assert.ok(Math.abs(distanciaKm(-22.91, -47.065, -22.9208, -47.065) - 1.2) < 0.01);

console.log('geo.test.js: ok');
