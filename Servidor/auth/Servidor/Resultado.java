//Autora: Laura Lugli Fonseca Pereira RA:25000739
package auth;

//resposta do servidor dizendo se o cadastro e válido e o motivo
public class Resultado extends Comunicado
{
    private boolean valido;
    private String mensagem;

    public Resultado (boolean valido, String mensagem)
    {
        this.valido = valido;
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
		return (this.valido ? "valido: " : "invalido: ") + this.mensagem;
	}

}

