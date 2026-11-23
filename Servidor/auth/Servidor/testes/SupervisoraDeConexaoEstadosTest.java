//Autora: Laura Lugli Fonseca Pereira RA:25000739
//testes intraclasse da SupervisoraDeConexao com particionamento por estados
package auth;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Timeout;

//estados: NENHUM_VERIFICADO (inicial), VALIDO e INVALIDO
//PedidoDeOperacao muda o estado e PedidoDeResultado so consulta
//padrao AAA (Arrange, Action, Assert)
@Timeout(5)
class SupervisoraDeConexaoEstadosTest {
    private ServerSocket pedido;
    private Parceiro servidor;

    // abre uma conexao de verdade com uma SupervisoraDeConexao, igual o cliente faz
    @BeforeEach
    void conectar() throws Exception {
        // porta 0 deixa o sistema escolher uma porta livre
        this.pedido = new ServerSocket(0);
        Socket ladoCliente = new Socket("localhost", this.pedido.getLocalPort());
        Socket ladoServidor = this.pedido.accept();

        // se o servidor travar o teste falha em vez de ficar esperando pra sempre
        ladoCliente.setSoTimeout(3000);

        SupervisoraDeConexao supervisora = new SupervisoraDeConexao(ladoServidor, new ArrayList<Parceiro>());
        supervisora.start();

        // mesma ordem do Cliente do professor: transmissor antes do receptor
        ObjectOutputStream transmissor = new ObjectOutputStream(ladoCliente.getOutputStream());
        ObjectInputStream receptor = new ObjectInputStream(ladoCliente.getInputStream());
        this.servidor = new Parceiro(ladoCliente, receptor, transmissor);
    }

    @AfterEach
    void desconectar() throws Exception {
        try {
            this.servidor.receba(new PedidoParaSair());
            this.servidor.adeus();
        } catch (Exception erro) {
        } // so tentando fechar
        this.pedido.close();
    }

    // manda um cadastro, faz a transicao de estado
    private void verifique(String nome, String email, String senha, String perfil, String bairro) throws Exception {
        this.servidor.receba(new PedidoDeOperacao(nome, email, senha, perfil, bairro));
    }

    // pede o resultado, consulta o estado atual
    private Resultado resultado() throws Exception {
        this.servidor.receba(new PedidoDeResultado());
        return (Resultado) this.servidor.envie();
    }

    // texto com a quantidade de caracteres pedida, pra testar os limites
    private String texto(char letra, int tamanho) {
        return String.valueOf(letra).repeat(tamanho);
    }

    // estado inicial: ninguem mandou cadastro ainda
    @Test
    void estadoInicialDeveSerNenhumCadastroVerificado() throws Exception {
        // Arrange: a conexao acabou de ser aberta no conectar

        // Action
        Resultado inicial = this.resultado();

        // Assert
        assertFalse(inicial.isValido());
        assertEquals("Nenhum cadastro foi verificado", inicial.getMensagem());
    }

    // transicao NENHUM_VERIFICADO -> VALIDO
    @Test
    void cadastroCorretoDeveLevarAoEstadoValido() throws Exception {
        // Arrange
        String senha = "12345678";

        // Action
        this.verifique("Laura", "laura@teste.com", senha, "ambos", "Cambui");
        Resultado depois = this.resultado();

        // Assert
        assertTrue(depois.isValido());
        assertEquals("Cadastro valido", depois.getMensagem());
    }

    // transicoes VALIDO -> INVALIDO -> VALIDO, o estado novo sempre substitui o
    // anterior
    @Test
    void cadaNovoCadastroDeveSubstituirOEstadoAnterior() throws Exception {
        // Arrange
        this.verifique("Laura", "laura@teste.com", "12345678", "ambos", "Cambui");
        Resultado valido = this.resultado();

        // Action
        this.verifique("Laura", "laura", "12345678", "ambos", "Cambui");
        Resultado invalido = this.resultado();
        this.verifique("Rafa", "rafa@teste.com", "abcdefgh", "ofertante", "Taquaral");
        Resultado validoDeNovo = this.resultado();

        // Assert
        assertTrue(valido.isValido());
        assertFalse(invalido.isValido());
        assertEquals("E-mail invalido", invalido.getMensagem());
        assertTrue(validoDeNovo.isValido());
    }

    // auto transicao: pedir o resultado nao muda o estado
    @Test
    void consultarVariasVezesNaoDeveMudarOEstado() throws Exception {
        // Arrange
        this.verifique("Laura", "laura@teste.com", "123", "ambos", "Cambui");

        // Action
        Resultado primeira = this.resultado();
        Resultado segunda = this.resultado();

        // Assert
        assertEquals(primeira.isValido(), segunda.isValido());
        assertEquals(primeira.getMensagem(), segunda.getMensagem());
    }

    // particoes invalidas: cada regra leva ao estado INVALIDO com a sua mensagem
    @Test
    void cadaRegraQuebradaDeveLevarAoEstadoInvalidoComSeuMotivo() throws Exception {
        // Arrange e Action: um campo errado por vez
        this.verifique("", "laura@teste.com", "12345678", "ambos", "Cambui");
        Resultado semNome = this.resultado();
        this.verifique("Laura", "laura.teste.com", "12345678", "ambos", "Cambui");
        Resultado semArroba = this.resultado();
        this.verifique("Laura", "laura@teste.com", "1234567", "ambos", "Cambui");
        Resultado senhaCurta = this.resultado();
        this.verifique("Laura", "laura@teste.com", "12345678", "vendedor", "Cambui");
        Resultado perfilErrado = this.resultado();
        this.verifique("Laura", "laura@teste.com", "12345678", "ambos", "   ");
        Resultado semBairro = this.resultado();

        // Assert
        assertEquals("Informe um nome com ate 60 caracteres", semNome.getMensagem());
        assertEquals("E-mail invalido", semArroba.getMensagem());
        assertEquals("A senha deve ter de 8 a 72 caracteres", senhaCurta.getMensagem());
        assertEquals("Perfil invalido", perfilErrado.getMensagem());
        assertEquals("Informe seu bairro", semBairro.getMensagem());
        assertFalse(semNome.isValido() || semArroba.isValido() || senhaCurta.isValido() ||
                perfilErrado.isValido() || semBairro.isValido());
    }

    // campos nulos nao podem derrubar a supervisora
    @Test
    void camposNulosDevemLevarAoEstadoInvalidoSemQuebrarAConexao() throws Exception {
        // Arrange
        String nada = null;

        // Action
        this.verifique(nada, nada, nada, nada, nada);
        Resultado depois = this.resultado();

        // Assert
        assertFalse(depois.isValido());
        assertEquals("Informe um nome com ate 60 caracteres", depois.getMensagem());
    }

    // valores limite do nome (60 e 61) e da senha (7, 8, 72 e 73)
    @Test
    void valoresLimiteDoNomeEDaSenha() throws Exception {
        // Arrange
        String email = "laura@teste.com";

        // Action
        this.verifique(texto('a', 60), email, "12345678", "ambos", "Cambui");
        Resultado nome60 = this.resultado();
        this.verifique(texto('a', 61), email, "12345678", "ambos", "Cambui");
        Resultado nome61 = this.resultado();
        this.verifique("Laura", email, texto('s', 7), "ambos", "Cambui");
        Resultado senha7 = this.resultado();
        this.verifique("Laura", email, texto('s', 8), "ambos", "Cambui");
        Resultado senha8 = this.resultado();
        this.verifique("Laura", email, texto('s', 72), "ambos", "Cambui");
        Resultado senha72 = this.resultado();
        this.verifique("Laura", email, texto('s', 73), "ambos", "Cambui");
        Resultado senha73 = this.resultado();

        // Assert
        assertTrue(nome60.isValido(), "nome com 60");
        assertFalse(nome61.isValido(), "nome com 61");
        assertFalse(senha7.isValido(), "senha com 7");
        assertTrue(senha8.isValido(), "senha com 8");
        assertTrue(senha72.isValido(), "senha com 72");
        assertFalse(senha73.isValido(), "senha com 73");
    }

    // quando tudo esta errado o motivo e o da primeira regra (o nome)
    @Test
    void comVariosErrosDeveValerAPrimeiraRegra() throws Exception {
        // Arrange e Action
        this.verifique("", "errado", "1", "x", "");
        Resultado depois = this.resultado();

        // Assert
        assertEquals("Informe um nome com ate 60 caracteres", depois.getMensagem());
    }

    // falha esperada: senha so com espacos deveria ser invalida
    @Test
    void senhaSoComEspacosDeveriaSerInvalida() throws Exception {
        // Arrange
        String senhaDeEspacos = texto(' ', 8);

        // Action
        this.verifique("Laura", "laura@teste.com", senhaDeEspacos, "ambos", "Cambui");
        Resultado depois = this.resultado();

        // Assert
        assertFalse(depois.isValido(), "senha com 8 espacos foi aceita");
    }

    // falha esperada: e-mail com dois pontos seguidos deveria ser invalido
    @Test
    void emailComPontosSeguidosDeveriaSerInvalido() throws Exception {
        // Arrange
        String emailErrado = "laura@teste..com";

        // Action
        this.verifique("Laura", emailErrado, "12345678", "ambos", "Cambui");
        Resultado depois = this.resultado();

        // Assert
        assertFalse(depois.isValido(), "e-mail com .. foi aceito");
    }
}
