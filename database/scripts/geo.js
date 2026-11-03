/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

const BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz';

function geohash(lat, lng, precisao = 10) {
  let latMin = -90, latMax = 90, lngMin = -180, lngMax = 180;
  let hash = '', bit = 0, ch = 0, par = true;
  while (hash.length < precisao) {
    if (par) {
      const meio = (lngMin + lngMax) / 2;
      if (lng >= meio) { ch = (ch << 1) | 1; lngMin = meio; } else { ch = ch << 1; lngMax = meio; }
    } else {
      const meio = (latMin + latMax) / 2;
      if (lat >= meio) { ch = (ch << 1) | 1; latMin = meio; } else { ch = ch << 1; latMax = meio; }
    }
    par = !par;
    if (++bit === 5) { hash += BASE32[ch]; bit = 0; ch = 0; }
  }
  return hash;
}

function distanciaKm(lat1, lng1, lat2, lng2) {
  const R = 6371.0088;
  const rad = (g) => (g * Math.PI) / 180;
  const dLat = rad(lat2 - lat1);
  const dLng = rad(lng2 - lng1);
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(rad(lat1)) * Math.cos(rad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}

module.exports = { geohash, distanciaKm };
