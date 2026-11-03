/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

const real = process.argv.includes('--real');
if (!real) process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';

const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, Timestamp, GeoPoint } = require('firebase-admin/firestore');

initializeApp(real ? { credential: applicationDefault() } : { projectId: 'cult-mais-dev' });

module.exports = {
  db: getFirestore(),
  Timestamp,
  GeoPoint,
  destino: real ? 'projeto real (credenciais do ambiente)' : 'emulador local (localhost:8080)',
};
