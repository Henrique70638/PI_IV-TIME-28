//Autor: Henrique Leite de Camargo RA: 25005997
//testes do servidor de verificacao de cadastro (Servidor/auth), feitos por socket como o Back-End usa
package auth;

import static org.junit.Assert.*;

import java.io.*;
import java.net.*;
import java.util.*;

import org.junit.*;

public class ServidorDeVerificacaoTest
{
    private static int porta;

    private Socket conexao;
    private ObjectOutputStream saida;
    private ObjectInputStream entrada;

    //sobe o servidor de verdade numa porta livre, uma vez para todos os testes
    @BeforeClass
    public static void sobeServidor () throws Exception
    {
        ServerSocket livre = new ServerSocket (0);
        porta = livre.getLocalPort();
        livre.close();

        AceitadoraDeConexao aceitadora = new AceitadoraDeConexao (String.valueOf(porta), new ArrayList<Parceiro>());
        aceitadora.setDaemon (true);
        aceitadora.start();
    }

    //cada teste abre a propria conexao, porque o servidor guarda o resultado por conexao
    @Before
    public void abreConexao () throws Exception
    {
        this.conexao = new Socket ("localhost", porta);
        this.saida   = new ObjectOutputStream (this.conexao.getOutputStream());
        this.entrada = new ObjectInputStream  (this.conexao.getInputStream());
    }

    @After
    public void fechaConexao () throws Exception
    {
        this.saida.writeObject (new PedidoParaSair());
        this.saida.flush();
        this.conexao.close();
    }

    private Resultado verifica (String nome, String email, String senha, String perfil, String bairro) throws Exception
    {
        this.saida.writeObject (new PedidoDeOperacao (nome, email, senha, perfil, bairro));
        this.saida.writeObject (new PedidoDeResultado());
        this.saida.flush();
        return (Resultado) this.entrada.readObject();
    }


    @Test
    public void semVerificacaoPrevia_resultadoEInvalido () throws Exception
    {
        this.saida.writeObject (new PedidoDeResultado());
        this.saida.flush();
        Resultado r = (Resultado) this.entrada.readObject();
        assertFalse (r.isValido());
        assertEquals ("Nenhum cadastro foi verificado", r.getMensagem());
    }

    @Test
    public void aceitaCadastroValido () throws Exception
    {
        Resultado r = this.verifica ("Henrique", "henrique@teste.com", "senha12345", "ambos", "Centro");
        assertTrue (r.isValido());
        assertEquals ("Cadastro valido", r.getMensagem());
    }

    @Test
    public void rejeitaNomeEmBranco () throws Exception
    {
        Resultado r = this.verifica ("   ", "a@b.com", "senha12345", "ambos", "Centro");
        assertFalse (r.isValido());
        assertEquals ("Informe um nome com ate 60 caracteres", r.getMensagem());
    }

    @Test
    public void rejeitaNomeNulo () throws Exception
    {
        Resultado r = this.verifica (null, "a@b.com", "senha12345", "ambos", "Centro");
        assertFalse (r.isValido());
        assertEquals ("Informe um nome com ate 60 caracteres", r.getMensagem());
    }

    @Test
    public void aceitaNomeCom60ERejeitaCom61 () throws Exception
    {
        assertTrue (this.verifica ("a".repeat (60), "a@b.com", "senha12345", "ambos", "Centro").isValido());
        Resultado r = this.verifica ("a".repeat (61), "a@b.com", "senha12345", "ambos", "Centro");
        assertFalse (r.isValido());
        assertEquals ("Informe um nome com ate 60 caracteres", r.getMensagem());
    }

    @Test
    public void rejeitaEmailsInvalidos () throws Exception
    {
        String[] invalidos = { "abc", "abc@", "@dominio.com", "abc@dominio", "a b@dominio.com", "" };
        for (String email : invalidos)
        {
            Resultado r = this.verifica ("Ana", email, "senha12345", "ambos", "Centro");
            assertFalse ("deveria rejeitar: " + email, r.isValido());
            assertEquals ("E-mail invalido", r.getMensagem());
        }
    }

    @Test
    public void rejeitaEmailNulo () throws Exception
    {
        Resultado r = this.verifica ("Ana", null, "senha12345", "ambos", "Centro");
        assertFalse (r.isValido());
        assertEquals ("E-mail invalido", r.getMensagem());
    }

    @Test
    public void rejeitaSenhaCurtaELonga () throws Exception
    {
        String mensagem = "A senha deve ter de 8 a 72 caracteres";
        assertEquals (mensagem, this.verifica ("Ana", "a@b.com", "1234567", "ambos", "Centro").getMensagem());
        assertEquals (mensagem, this.verifica ("Ana", "a@b.com", "x".repeat (73), "ambos", "Centro").getMensagem());
        assertEquals (mensagem, this.verifica ("Ana", "a@b.com", null, "ambos", "Centro").getMensagem());
    }

    @Test
    public void aceitaSenhaNosLimites () throws Exception
    {
        assertTrue (this.verifica ("Ana", "a@b.com", "12345678", "ambos", "Centro").isValido());
        assertTrue (this.verifica ("Ana", "a@b.com", "x".repeat (72), "ambos", "Centro").isValido());
    }

    @Test
    public void aceitaOsTresPerfis () throws Exception
    {
        for (String perfil : new String[] { "ofertante", "interessado", "ambos" })
            assertTrue ("perfil " + perfil, this.verifica ("Ana", "a@b.com", "senha12345", perfil, "Centro").isValido());
    }

    @Test
    public void rejeitaPerfilInvalidoOuNulo () throws Exception
    {
        assertEquals ("Perfil invalido", this.verifica ("Ana", "a@b.com", "senha12345", "qualquer", "Centro").getMensagem());
        assertEquals ("Perfil invalido", this.verifica ("Ana", "a@b.com", "senha12345", null, "Centro").getMensagem());
    }

    @Test
    public void rejeitaBairroEmBrancoOuNulo () throws Exception
    {
        assertEquals ("Informe seu bairro", this.verifica ("Ana", "a@b.com", "senha12345", "ambos", "  ").getMensagem());
        assertEquals ("Informe seu bairro", this.verifica ("Ana", "a@b.com", "senha12345", "ambos", null).getMensagem());
    }

    @Test
    public void paraNoPrimeiroErro () throws Exception
    {
        Resultado r = this.verifica ("", "abc", "123", "qualquer", "");
        assertFalse (r.isValido());
        assertEquals ("Informe um nome com ate 60 caracteres", r.getMensagem());
    }

    @Test
    public void ultimaVerificacaoSubstituiAAnterior () throws Exception
    {
        assertTrue (this.verifica ("Ana", "a@b.com", "senha12345", "ambos", "Centro").isValido());
        assertFalse (this.verifica ("Ana", "abc", "senha12345", "ambos", "Centro").isValido());
    }

    @Test
    public void conexoesNaoCompartilhamResultado () throws Exception
    {
        assertTrue (this.verifica ("Ana", "a@b.com", "senha12345", "ambos", "Centro").isValido());

        Socket outra = new Socket ("localhost", porta);
        ObjectOutputStream saida2 = new ObjectOutputStream (outra.getOutputStream());
        ObjectInputStream entrada2 = new ObjectInputStream (outra.getInputStream());
        saida2.writeObject (new PedidoDeResultado());
        saida2.flush();
        Resultado r = (Resultado) entrada2.readObject();
        outra.close();

        assertFalse (r.isValido());
        assertEquals ("Nenhum cadastro foi verificado", r.getMensagem());
    }
}
