//Autora: Laura Lugli Fonseca Pereira RA:25000739
//testes intraclasse do PedidoDeOperacao com particionamento por categorias de metodos
package auth;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotSame;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import org.junit.jupiter.api.Test;

//categorias: inicializacao (construtor), consulta (5 getters),
//representacao (toString) e transporte (serializacao herdada do Comunicado)
//padrao AAA (Arrange, Action, Assert)
class PedidoDeOperacaoCategoriasTest {
    private PedidoDeOperacao pedidoCorreto() {
        return new PedidoDeOperacao("Laura", "laura@teste.com", "senhaSecreta1", "ambos", "Cambui");
    }

    // inicializacao + consulta: cada get devolve o que o construtor guardou
    @Test
    void construtorDeveGuardarOsCincoCamposParaOsGetters() {
        // Arrange e Action (inicializacao)
        PedidoDeOperacao pedido = this.pedidoCorreto();

        // Assert (consulta)
        assertEquals("Laura", pedido.getNome());
        assertEquals("laura@teste.com", pedido.getEmail());
        assertEquals("senhaSecreta1", pedido.getSenha());
        assertEquals("ambos", pedido.getPerfil());
        assertEquals("Cambui", pedido.getBairro());
    }

    // representacao: o toString mostra so o email e nunca a senha
    @Test
    void toStringDeveMostrarSoOEmailSemASenha() {
        // Arrange
        PedidoDeOperacao pedido = this.pedidoCorreto();

        // Action
        String texto = pedido.toString();

        // Assert
        assertEquals("laura@teste.com", texto);
        assertFalse(texto.contains("senhaSecreta1"));
    }

    // transporte: o pedido chega igual do outro lado do socket
    @Test
    void pedidoDeveChegarIgualDepoisDoTransporte() throws Exception {
        // Arrange
        PedidoDeOperacao original = this.pedidoCorreto();
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();

        // Action
        ObjectOutputStream transmissor = new ObjectOutputStream(bytes);
        transmissor.writeObject(original);
        transmissor.flush();
        ObjectInputStream receptor = new ObjectInputStream(new ByteArrayInputStream(bytes.toByteArray()));
        PedidoDeOperacao recebido = (PedidoDeOperacao) receptor.readObject();

        // Assert
        assertNotSame(original, recebido);
        assertTrue(recebido instanceof Comunicado);
        assertEquals(original.getNome(), recebido.getNome());
        assertEquals(original.getEmail(), recebido.getEmail());
        assertEquals(original.getSenha(), recebido.getSenha());
        assertEquals(original.getPerfil(), recebido.getPerfil());
        assertEquals(original.getBairro(), recebido.getBairro());
    }

    // inicializacao sem validacao: aceita nulos e guarda sem mexer (nao tira
    // espacos)
    @Test
    void construtorAceitaNulosEEspacosSemValidar() {
        // Arrange
        String nada = null;

        // Action
        PedidoDeOperacao nulo = new PedidoDeOperacao(nada, nada, nada, nada, nada);
        PedidoDeOperacao comEspacos = new PedidoDeOperacao("  Laura  ", " laura@teste.com ", "12345678", "ambos",
                " Cambui ");

        // Assert: documenta que quem confere e a SupervisoraDeConexao
        assertNull(nulo.getNome());
        assertNull(nulo.toString());
        assertEquals("  Laura  ", comEspacos.getNome());
        assertEquals(" laura@teste.com ", comEspacos.toString());
    }
}
