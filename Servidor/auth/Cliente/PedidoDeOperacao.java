//Autora: Laura Lugli Fonseca Pereira RA:25000739
package auth;

//leva os dados do cadastro do cliente pro servidor verificar
public class PedidoDeOperacao extends Comunicado
{
    private String nome;
    private String email;
    private String senha;
    private String perfil;
    private String bairro;

    //só guarda os dados, quem confere é o servidor
    public PedidoDeOperacao (String nome, String email, String senha, String perfil, String bairro)
    {
        this.nome = nome;
        this.email = email;
        this.senha = senha;
        this.perfil = perfil;
        this.bairro = bairro;
    }

    public String getNome ()
    {
        return this.nome;
    }

    public String getEmail ()
    {
        return this.email;
    }

    public String getSenha ()
    {
        return this.senha;
    }

    public String getPerfil (){
        return this.perfil;
    }

    public String getBairro (){
        return this.bairro;
    }

    //mostra só o email pra nunca aparecer a senha
    public String toString ()
    {
        return this.email;
    }

    
}
