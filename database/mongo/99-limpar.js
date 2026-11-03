/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 *
 * Apaga as coleções do banco cultmais. Para executar, troque CONFIRMO_APAGAR_TUDO para true.
 */

(() => {
  const CONFIRMO_APAGAR_TUDO = false;
  const bd = db.getSiblingDB('cultmais');

  if (!CONFIRMO_APAGAR_TUDO) {
    print('Nada foi apagado. Altere CONFIRMO_APAGAR_TUDO para true se tiver certeza.');
    return;
  }

  for (const nome of ['mensagens', 'matches', 'excedentes', 'usuarios']) {
    print(nome + ': ' + (bd.getCollection(nome).drop() ? 'removida' : 'não existia'));
  }
})();
