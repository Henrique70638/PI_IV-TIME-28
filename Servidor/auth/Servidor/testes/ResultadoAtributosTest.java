//Autora: Laura Lugli Fonseca Pereira RA:25000739
//testes intraclasse do Resultado com particionamento por atributos
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

//atributos: valido e mensagem
//so o construtor modifica, isValido, getMensagem e toString usam
//padrao AAA (Arrange, Action, Assert)
class ResultadoAtributosTest {
    // faz o mesmo caminho que o objeto faz no socket: vira bytes e volta
    private Resultado transporte(Resultado original) throws Exception {
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        ObjectOutputStream transmissor = new ObjectOutputStream(bytes);
        transmissor.writeObject(original);
        transmissor.flush();

        ObjectInputStream receptor = new ObjectInputStream(new ByteArrayInputStream(bytes.toByteArray()));
        return (Resultado) receptor.readObject();
    }

    // atributo valido = true: lido por isValido e pelo toString
    @Test
    void atributoValidoVerdadeiroDeveAparecerNoIsValidoENoToString() {
        // Arrange
        Resultado resultado = new Resultado(true, "Cadastro valido");

        // Action
        boolean valido = resultado.isValido();
        String texto = resultado.toString();

        // Assert
        assertTrue(valido);
        assertEquals("valido: Cadastro valido", texto);
    }

    // atributo valido = false: o toString troca o prefixo
    @Test
    void atributoValidoFalsoDeveTrocarOPrefixoDoToString() {
        // Arrange
        Resultado resultado = new Resultado(false, "E-mail invalido");

        // Action
        boolean valido = resultado.isValido();
        String texto = resultado.toString();

        // Assert
        assertFalse(valido);
        assertEquals("invalido: E-mail invalido", texto);
    }

    // atributo mensagem: getMensagem devolve exatamente o que entrou, inclusive
    // vazio
    @Test
    void atributoMensagemDeveSerGuardadoSemAlteracao() {
        // Arrange
        Resultado comTexto = new Resultado(false, "A senha deve ter de 8 a 72 caracteres");
        Resultado vazio = new Resultado(true, "");

        // Action
        String mensagem = comTexto.getMensagem();
        String mensagemVazia = vazio.getMensagem();

        // Assert
        assertEquals("A senha deve ter de 8 a 72 caracteres", mensagem);
        assertEquals("", mensagemVazia);
        assertEquals("valido: ", vazio.toString());
    }

    // os dois atributos tem que chegar iguais do outro lado do socket
    @Test
    void atributosDevemSobreviverAoTransportePeloSocket() throws Exception {
        // Arrange
        Resultado original = new Resultado(false, "Perfil invalido");

        // Action
        Resultado recebido = this.transporte(original);

        // Assert
        assertNotSame(original, recebido);
        assertEquals(original.isValido(), recebido.isValido());
        assertEquals(original.getMensagem(), recebido.getMensagem());
    }

    // particao invalida: mensagem nula e aceita sem validacao
    @Test
    void mensagemNulaEAceitaEApareceComoNullNoToString() {
        // Arrange
        String nada = null;

        // Action
        Resultado resultado = new Resultado(true, nada);

        // Assert: documenta a anomalia, o construtor nao confere a mensagem
        assertNull(resultado.getMensagem());
        assertEquals("valido: null", resultado.toString());
    }
}