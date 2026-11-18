//Autora: Laura Lugli Fonseca Pereira RA:25000739
import { app } from './app';
import { env } from './shared/env';
import { conectarBanco } from './shared/banco';

//conecta no banco e liga a api
async function iniciar() {
    //se o banco falhar a api sobe mesmo assim
    try {
        await conectarBanco();
    } catch (erro) {
        console.warn('Aviso: não conectou no MongoDB, as rotas que usam o banco vão falhar');
        console.warn((erro as Error).message);
    }

    app.listen(env.porta, () => {
        console.log(`API do CULT+ rodando em http://localhost:${env.porta}`);
    });
}

iniciar();