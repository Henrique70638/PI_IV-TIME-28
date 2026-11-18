//Autora: Laura Lugli Fonseca Pereira RA:25000739

//carrega as variaveis do arquivo .env
import 'dotenv/config';

//junta as configuracoes da api num lugar so
export const env = {
    porta: Number(process.env.PORTA ?? 3333),
    mongoUri: process.env.MONGODB_URI ?? 'mongodb://localhost:27017',
    mongoBanco: process.env.MONGO_BANCO ?? 'cultmais',
    servidorJavaAtivo: process.env.SERVIDOR_JAVA_ATIVO === 'true',
    servidorJavaHost: process.env.SERVIDOR_JAVA_HOST ?? 'localhost',
    servidorJavaPorta: Number(process.env.SERVIDOR_JAVA_PORTA ?? 3001),
    servidorJavaClasses: process.env.SERVIDOR_JAVA_CLASSES ?? '../../Servidor/cadastro/out/cliente',
    javaComando: process.env.JAVA_COMANDO ?? 'java',
};