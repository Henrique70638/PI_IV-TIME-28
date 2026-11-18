/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

public class RespostaDeCadastro extends Comunicado
{
    private static final long serialVersionUID = 1L;

    private boolean valido;
    private String  mensagem;

    public RespostaDeCadastro (boolean valido, String mensagem)
    {
        this.valido   = valido;
        this.mensagem = mensagem;
    }

    public boolean isValido ()
    {
        return this.valido;
    }

    public String getMensagem ()
    {
        return this.mensagem;
    }

    public String toString ()
    {
        return (this.valido ? "valido" : "invalido: " + this.mensagem);
    }
}
