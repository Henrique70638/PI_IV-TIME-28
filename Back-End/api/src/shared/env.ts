//Autora: Laura Lugli Fonseca Pereira RA:25000739

//carrega as variaveis do arquivo .env
import 'dotenv/config';

//junta as configuracoes da api num lugar so
export const env = {
    porta: Number(process.env.PORTA ?? 3333),
    mongoUri: process.env.MONGODB_URI ?? 'mongodb://localhost:27017',
    mongoBanco: process.env.MONGO_BANCO ?? 'cultmais',
};