// Autor: Rafaela Jacobsen Braga - RA: 25004280
// Servidor LOCAL DE DEMONSTRAÇÃO para testar o Flutter sem MongoDB.
// Não utiliza dados reais e não altera o banco de dados do CULT+.
const http = require('node:http');

const ofertas = [
  { id: 'demo1', produto: 'Manga Tommy', categoria: 'frutas', quantidade: 5, unidade: 'kg', modalidade: 'doacao', distanciaKm: 1.2 },
  { id: 'demo2', produto: 'Limão Taiti', categoria: 'frutas', quantidade: 3, unidade: 'kg', modalidade: 'doacao', distanciaKm: 2.4 },
  { id: 'demo3', produto: 'Banana prata', categoria: 'frutas', quantidade: 2, unidade: 'cacho', modalidade: 'venda', distanciaKm: 3.0 },
  { id: 'demo4', produto: 'Alface', categoria: 'verduras', quantidade: 4, unidade: 'un', modalidade: 'doacao', distanciaKm: 1.0 },
  { id: 'demo5', produto: 'Manjericão', categoria: 'mudas', quantidade: 2, unidade: 'muda', modalidade: 'doacao', distanciaKm: 1.5 },
];

const enviar = (res, status, conteudo) => {
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(conteudo));
};

const servidor = http.createServer((req, res) => {
  const url = new URL(req.url, 'http://127.0.0.1:3334');
  if (req.method !== 'GET' || url.pathname !== '/api/inicio/excedentes') {
    return enviar(res, 404, { erro: 'Rota de demonstração não encontrada' });
  }
  const latitude = Number(url.searchParams.get('latitude'));
  const longitude = Number(url.searchParams.get('longitude'));
  if (!Number.isFinite(latitude) || !Number.isFinite(longitude) ||
      !url.searchParams.has('latitude') || !url.searchParams.has('longitude') ||
      latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
    return enviar(res, 400, { erro: 'Coordenadas inválidas' });
  }
  const categoria = url.searchParams.get('categoria');
  const modalidade = url.searchParams.get('modalidade');
  const raioKm = Number(url.searchParams.get('raioKm') ?? 5);
  const busca = (url.searchParams.get('busca') ?? '').toLocaleLowerCase('pt-BR');
  if (!Number.isFinite(raioKm) || raioKm <= 0) {
    return enviar(res, 400, { erro: 'Raio inválido' });
  }
  const resultados = ofertas.filter((item) =>
    item.distanciaKm <= raioKm &&
    (!categoria || item.categoria === categoria) &&
    (!modalidade || item.modalidade === modalidade) &&
    item.produto.toLocaleLowerCase('pt-BR').includes(busca)
  );
  enviar(res, 200, { total: resultados.length, excedentes: resultados });
});

servidor.listen(3334, '127.0.0.1', () => {
  console.log('API DEMO (sem MongoDB) em http://127.0.0.1:3334');
});
