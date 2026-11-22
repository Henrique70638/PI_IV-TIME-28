//Autora : Laura Lugli Fonseca Pereira RA:25000739
//no lugar das contas faz a verificacao dos dados de cadastro
package auth;

import java.io.*;
import java.net.*;
import java.util.*;

public class SupervisoraDeConexao extends Thread {
    //guarda o resultado da ultima verificacao pra devolver quando pedirem
    private boolean valido = false;
    private String mensagem = "Nenhum cadastro foi verificado";
    private Parceiro usuario;
    private Socket conexao;
    private ArrayList<Parceiro> usuarios;

    public SupervisoraDeConexao(Socket conexao, ArrayList<Parceiro> usuarios)
            throws Exception {
        if (conexao == null)
            throw new Exception("Conexao ausente");

        if (usuarios == null)
            throw new Exception("Usuarios ausentes");

        this.conexao = conexao;
        this.usuarios = usuarios;
    }

    public void run() {

        ObjectOutputStream transmissor;
        try {
            transmissor = new ObjectOutputStream(
                    this.conexao.getOutputStream());
        } catch (Exception erro) {
            return;
        }

        ObjectInputStream receptor = null;
        try {
            receptor = new ObjectInputStream(
                    this.conexao.getInputStream());
        } catch (Exception err0) {
            try {
                transmissor.close();
            } catch (Exception falha) {
            } // so tentando fechar antes de acabar a thread

            return;
        }

        try {
            this.usuario = new Parceiro(this.conexao,
                    receptor,
                    transmissor);
        } catch (Exception erro) {
        } // sei que passei os parametros corretos

        try {
            synchronized (this.usuarios) {
                this.usuarios.add(this.usuario);
            }

            for (;;) {
                Comunicado comunicado = this.usuario.envie();

                if (comunicado == null)
                    return;
                else if (comunicado instanceof PedidoDeOperacao) {
                    //chegou um cadastro, confere os dados
                    PedidoDeOperacao pedidoDeOperacao = (PedidoDeOperacao) comunicado;
                    this.verifiqueCadastro(pedidoDeOperacao);

                } else if (comunicado instanceof PedidoDeResultado) {
                    //devolve o resultado da última verificação
                    this.usuario.receba(new Resultado(this.valido, this.mensagem));
                } else if (comunicado instanceof PedidoParaSair) {
                    synchronized (this.usuarios) {
                        this.usuarios.remove(this.usuario);
                    }
                    this.usuario.adeus();
                }
            }
        } catch (Exception erro) {
            try {
                transmissor.close();
                receptor.close();
            } catch (Exception falha) {
            } // so tentando fechar antes de acabar a thread

            return;
        }
    }

    //confere os dados do cadastro, e private porque e só parte do serviço
    private void verifiqueCadastro(PedidoDeOperacao pedido) {
        //comeca inválido e só vira válido se passar em tudo
        this.valido = false;

        String nome = pedido.getNome();
        String email = pedido.getEmail();
        String senha = pedido.getSenha();
        String perfil = pedido.getPerfil();
        String bairro = pedido.getBairro();

        //null primeiro pra nao dar erro no trim
        if (nome == null || nome.trim().equals("") || nome.trim().length() > 60) {
            this.mensagem = "Informe um nome com ate 60 caracteres";
            return;
        }

        if (email == null || !email.trim().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            this.mensagem = "E-mail invalido";
            return;
        }

        if (senha == null || senha.length() < 8 || senha.length() > 72) {
            this.mensagem = "A senha deve ter de 8 a 72 caracteres";
            return;
        }

        //so aceita os perfis que existem no banco
        if (perfil == null || !(perfil.equals("ofertante") ||
                perfil.equals("interessado") ||
                perfil.equals("ambos"))) {
            this.mensagem = "Perfil invalido";
            return;
        }

        if (bairro == null || bairro.trim().equals("")) {
            this.mensagem = "Informe seu bairro";
            return;
        }

        //passou em todas as verificações
        this.valido = true;
        this.mensagem = "Cadastro valido";
    }
}
