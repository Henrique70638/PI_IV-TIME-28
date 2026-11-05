export class ErroApp extends Error {
    constructor(public status: number, mensagem: string) {
      super(mensagem);
    }
  }