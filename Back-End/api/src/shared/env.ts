import 'dotenv/config';

export const env = {
  porta: Number(process.env.PORTA ?? 3333),
  mongoUri: process.env.MONGODB_URI ?? 'mongodb://localhost:27017',
  mongoBanco: process.env.MONGO_BANCO ?? 'cultmais',
};