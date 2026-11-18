/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import java.util.*;
import java.util.regex.Pattern;

public class ValidadorDeCadastro
{
    private static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");
    private static final List<String> PERFIS = Arrays.asList("ofertante", "interessado", "ambos");

    public static RespostaDeCadastro validar (PedidoDeCadastro pedido)
    {
        if (pedido==null)
            return new RespostaDeCadastro (false, "Pedido ausente");

        ArrayList<String> erros = new ArrayList<String> ();

        String nome = texto (pedido.getNome());
        if (nome.isEmpty())
            erros.add ("Informe o nome");
        else if (nome.length() > 60)
            erros.add ("O nome pode ter no maximo 60 caracteres");

        String email = texto (pedido.getEmail());
        if (email.isEmpty())
            erros.add ("Informe o e-mail");
        else if (!EMAIL.matcher(email).matches())
            erros.add ("E-mail invalido");

        String senha = pedido.getSenha()==null ? "" : pedido.getSenha();
        if (senha.length() < 8 || senha.length() > 72)
            erros.add ("A senha deve ter de 8 a 72 caracteres");

        String perfil = texto (pedido.getPerfil()).toLowerCase();
        if (!PERFIS.contains(perfil))
            erros.add ("Perfil invalido (use ofertante, interessado ou ambos)");

        if (texto (pedido.getBairro()).isEmpty())
            erros.add ("Informe o bairro ou a cidade");

        if (erros.isEmpty())
            return new RespostaDeCadastro (true, "");

        return new RespostaDeCadastro (false, String.join ("; ", erros));
    }

    private static String texto (String valor)
    {
        return valor==null ? "" : valor.trim();
    }
}
