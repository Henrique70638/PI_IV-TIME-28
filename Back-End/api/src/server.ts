import { app } from './app';
import { env } from './shared/env';
import { conectarBanco } from './shared/banco';

async function iniciar() {
  try {
    await conectarBanco();
  } catch {
    console.warn('Aviso: não conectou no MongoDB, as rotas que usam o banco vão falhar');
  }

  app.listen(env.porta, () => {
    console.log(`API do CULT+ rodando em http://localhost:${env.porta}`);
  });
}

iniciar();