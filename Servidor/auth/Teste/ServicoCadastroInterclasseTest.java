//Autor: Henrique Leite de Camargo RA: 25005997
//testes INTERCLASSE do servico principal: verificacao de cadastro (Servidor/auth)
//classes participantes: AceitadoraDeConexao, SupervisoraDeConexao, Parceiro, PedidoDeOperacao, PedidoDeResultado, PedidoParaSair, Resultado
package auth;

import static org.junit.Assert.*;

import java.io.*;
import java.net.*;
import java.util.*;

import org.junit.*;

public class ServicoCadastroInterclasseTest
{
    private ArrayList<Parceiro> usuarios;
    private int porta;

    private Socket conexao;
    private ObjectOutputStream saida;
    private ObjectInputStream entrada;

    //sobe o servidor de verdade numa porta livre, com a lista de usuarios na mao para observar o que as classes fazem com ela
    @Before
    public void sobeServidorEConecta () throws Exception
    {
        ServerSocket livre = new ServerSocket (0);
        this.porta = livre.getLocalPort();
        livre.close();

        this.usuarios = new ArrayList<Parceiro>();
        AceitadoraDeConexao aceitadora = new AceitadoraDeConexao (String.valueOf(this.porta), this.usuarios);
        aceitadora.setDaemon (true);
        aceitadora.start();

        this.conexao = new Socket ("localhost", this.porta);
        this.saida   = new ObjectOutputStream (this.conexao.getOutputStream());
        this.entrada = new ObjectInputStream  (this.conexao.getInputStream());
    }

    @After
    public void fechaConexao () throws Exception
    {
        this.conexao.close();
    }

    //espera a supervisora (que roda em outra thread) chegar ao tamanho esperado da lista
    private boolean esperaUsuarios (int esperado) throws Exception
    {
        for (int i = 0; i < 40; i++)
        {
            synchronized (this.usuarios)
            {
                if (this.usuarios.size() == esperado)
                    return true;
            }
            Thread.sleep (50);
        }
        return false;
    }

    private Resultado verifica (String nome, String email, String senha, String perfil, String bairro) throws Exception
    {
        this.saida.writeObject (new PedidoDeOperacao (nome, email, senha, perfil, bairro));
        this.saida.writeObject (new PedidoDeResultado());
        this.saida.flush();
        return (Resultado) this.entrada.readObject();
    }

    //CT-F01: cenario normal - cadastro valido percorre Aceitadora -> Supervisora -> Parceiro -> verifiqueCadastro -> Resultado
    @Test
    public void cenarioNormal_cadastroValidoPercorreTodasAsClasses () throws Exception
    {
        assertTrue ("Aceitadora e Supervisora deveriam registrar 1 Parceiro na lista", this.esperaUsuarios (1));

        Resultado resultado = this.verifica ("Maria da Silva", "maria@email.com", "senha1234", "ofertante", "Centro");

        assertTrue (resultado.isValido());
        assertEquals ("Cadastro valido", resultado.getMensagem());
        assertEquals ("valido: Cadastro valido", resultado.toString());

        this.saida.writeObject (new PedidoParaSair());
        this.saida.flush();

        assertTrue ("Supervisora deveria remover o Parceiro da lista ao sair", this.esperaUsuarios (0));
        try
        {
            this.entrada.readObject();
            fail ("Parceiro.adeus deveria ter fechado a conexao");
        }
        catch (IOException esperado)
        {
        }
    }

    //CT-F02: cenario alternativo - e-mail invalido e recusado, a conexao continua viva e aceita novo cadastro
    @Test
    public void cenarioAlternativo_emailInvalidoERecusadoEConexaoContinua () throws Exception
    {
        assertTrue (this.esperaUsuarios (1));

        Resultado recusado = this.verifica ("Maria da Silva", "maria-sem-arroba", "senha1234", "ofertante", "Centro");

        assertFalse (recusado.isValido());
        assertEquals ("E-mail invalido", recusado.getMensagem());
        assertEquals ("invalido: E-mail invalido", recusado.toString());
        assertTrue ("Recusar o cadastro nao pode remover o Parceiro da lista", this.esperaUsuarios (1));

        Resultado aceito = this.verifica ("Maria da Silva", "maria@email.com", "senha1234", "ofertante", "Centro");

        assertTrue (aceito.isValido());
        assertEquals ("Cadastro valido", aceito.getMensagem());
    }

    //CT-F03 (complementar): chamadas com parametros ausentes lancam excecao nas classes do servico
    @Test
    public void complementar_parametrosAusentesLancamExcecao () throws Exception
    {
        try
        {
            new SupervisoraDeConexao (null, new ArrayList<Parceiro>());
            fail ("deveria lancar excecao");
        }
        catch (Exception erro)
        {
            assertEquals ("Conexao ausente", erro.getMessage());
        }

        try
        {
            new SupervisoraDeConexao (this.conexao, null);
            fail ("deveria lancar excecao");
        }
        catch (Exception erro)
        {
            assertEquals ("Usuarios ausentes", erro.getMessage());
        }

        try
        {
            new AceitadoraDeConexao ("abc", new ArrayList<Parceiro>());
            fail ("deveria lancar excecao");
        }
        catch (Exception erro)
        {
            assertEquals ("Porta invalida", erro.getMessage());
        }

        try
        {
            new Parceiro (this.conexao, null, null);
            fail ("deveria lancar excecao");
        }
        catch (Exception erro)
        {
            assertEquals ("Receptor ausente", erro.getMessage());
        }
    }
}
