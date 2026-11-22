package auth.Servidor;

import java.io.*;
import java.net.*;
import java.util.*;

public class SupervisoraDeConexao extends Thread {
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
                    PedidoDeOperacao pedidoDeOperacao = (PedidoDeOperacao) comunicado;
                    this.verifiqueCadastro(pedidoDeOperacao);

                } else if (comunicado instanceof PedidoDeResultado) {
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

    private void verifiqueCadastro(PedidoDeOperacao pedido) {
        this.valido = false;

        String nome = pedido.getNome();
        String email = pedido.getEmail();
        String senha = pedido.getSenha();
        String perfil = pedido.getPerfil();
        String bairro = pedido.getBairro();

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

        this.valido = true;
        this.mensagem = "Cadastro valido";
    }
}
