package auth.Cliente;


public class PedidoDeOperacao extends Comunicado
{
    private String email;
    private String senha;

    public PedidoDeOperacao (String email, String senha)
    {
        this.email = email;
        this.senha = senha;
    }

    public String getEmail ()
    {
        return this.email;
    }

    public String getSenha ()
    {
        return this.senha;
    }

    public String toString ()
    {
        return this.email;
    }
}
