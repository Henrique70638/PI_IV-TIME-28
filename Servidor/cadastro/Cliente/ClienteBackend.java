/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;

public class ClienteBackend
{
    public static void main (String[] args)
    {
        String host  = args.length > 0 ? args[0] : "localhost";
        int    porta = 3001;

        try
        {
            if (args.length > 1)
                porta = Integer.parseInt (args[1]);

            BufferedReader entrada =
            new BufferedReader (
            new InputStreamReader (System.in, StandardCharsets.UTF_8));

            String nome   = lerLinha (entrada);
            String email  = lerLinha (entrada);
            String senha  = lerLinha (entrada);
            String perfil = lerLinha (entrada);
            String bairro = lerLinha (entrada);

            Socket conexao = new Socket ();
            conexao.connect (new InetSocketAddress (host, porta), 3000);
            conexao.setSoTimeout (5000);

            ObjectOutputStream transmissor = new ObjectOutputStream (conexao.getOutputStream());
            ObjectInputStream  receptor    = new ObjectInputStream  (conexao.getInputStream());
            Parceiro           servidor    = new Parceiro (conexao, receptor, transmissor);

            servidor.receba (new PedidoDeCadastro (nome, email, senha, perfil, bairro));

            Comunicado comunicado;
            do
            {
                comunicado = servidor.envie ();
            }
            while (!(comunicado instanceof RespostaDeCadastro));

            RespostaDeCadastro resposta = (RespostaDeCadastro)comunicado;

            try
            {
                servidor.receba (new PedidoParaSair ());
            }
            catch (Exception erro)
            {}

            System.out.println ("{\"valido\":" + resposta.isValido() +
                                ",\"mensagem\":" + json (resposta.getMensagem()) + "}");
            System.exit (0);
        }
        catch (Exception erro)
        {
            System.out.println ("{\"erro\":" + json ("Servidor de validacao indisponivel") + "}");
            System.exit (2);
        }
    }

    private static String lerLinha (BufferedReader entrada) throws IOException
    {
        String linha = entrada.readLine ();
        return linha == null ? "" : linha;
    }

    private static String json (String texto)
    {
        StringBuilder saida = new StringBuilder ("\"");
        for (char c : texto.toCharArray())
        {
            if (c == '"' || c == '\\')
                saida.append ('\\').append (c);
            else if (c < 32 || c > 126)
                saida.append (String.format ("\\u%04x", (int)c));
            else
                saida.append (c);
        }
        return saida.append ('"').toString();
    }
}
