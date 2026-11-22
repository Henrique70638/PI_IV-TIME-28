package auth;
import java.net.*;
import java.io.*;

public class Cliente
{
	public static final String HOST_PADRAO  = "localhost";
	public static final int    PORTA_PADRAO = 3000;

	public static void main (String[] args)
	{
        if (args.length>2)
        {
            System.err.println ("Uso esperado: java Cliente [HOST [PORTA]]\n");
            return;
        }

        Socket conexao=null;
        try
        {
            String host = Cliente.HOST_PADRAO;
            int    porta= Cliente.PORTA_PADRAO;

            if (args.length>0)
                host = args[0];

            if (args.length==2)
                porta = Integer.parseInt(args[1]);

            conexao = new Socket (host, porta);
        }
        catch (Exception erro)
        {
            System.err.println ("Indique o servidor e a porta corretos!\n");
            return;
        }

        ObjectOutputStream transmissor=null;
        try
        {
            transmissor =
            new ObjectOutputStream(
            conexao.getOutputStream());
        }
        catch (Exception erro)
        {
            System.err.println ("Indique o servidor e a porta corretos!\n");
            return;
        }

        ObjectInputStream receptor=null;
        try
        {
            receptor =
            new ObjectInputStream(
            conexao.getInputStream());
        }
        catch (Exception erro)
        {
            System.err.println ("Indique o servidor e a porta corretos!\n");
            return;
        }

        Parceiro servidor=null;
        try
        {
            servidor =
            new Parceiro (conexao, receptor, transmissor);
        }
        catch (Exception erro)
        {
            System.err.println ("Indique o servidor e a porta corretos!\n");
            return;
        }

        TratadoraDeComunicadoDeDesligamento tratadoraDeComunicadoDeDesligamento = null;
        try
        {
			tratadoraDeComunicadoDeDesligamento = new TratadoraDeComunicadoDeDesligamento (servidor);
		}
		catch (Exception erro)
		{} // sei que servidor foi instanciado
		
        tratadoraDeComunicadoDeDesligamento.start();

        char opcao=' ';
        do
        {
            System.out.print ("Sua opcao ( [V]erificar cadastro, =, [T]erminar)? ");

            try
            {
				opcao = Character.toUpperCase(Teclado.getUmChar());
		    }
		    catch (Exception erro)
		    {
				System.err.println ("Opcao invalida!\n");
				continue;
			}

			if ("V=T".indexOf(opcao)==-1)
		    {
				System.err.println ("Opcao invalida!\n");
				continue;
			}

			try
			{
				if (opcao=='V'){
					System.out.print ("Nome? ");
					String nome = Teclado.getUmString();

					System.out.print ("E-mail? ");
					String email = Teclado.getUmString();

					System.out.print ("Senha? ");
					String senha = Teclado.getUmString();

					System.out.print ("Perfil? ");
					String perfil = Teclado.getUmString();

					System.out.print ("Bairro? ");
					String bairro = Teclado.getUmString();

					System.out.println();
					servidor.receba(new PedidoDeOperacao (nome, email, senha, perfil, bairro));

				}
				else if (opcao=='=')
				{
					servidor.receba (new PedidoDeResultado ());
					Comunicado comunicado = null;
					do
					{
						comunicado = (Comunicado)servidor.espie ();
					}
					while (!(comunicado instanceof Resultado));
					Resultado resultado = (Resultado)servidor.envie ();
					System.out.println ("Resultado atual: "+resultado+"\n");
				}
			}
			catch (Exception erro)
			{
				System.err.println ("Erro de comunicacao com o servidor;");
				System.err.println ("Tente novamente!");
				System.err.println ("Caso o erro persista, termine o programa");
				System.err.println ("e volte a tentar mais tarde!\n");
			}
        }
        while (opcao != 'T');

		try
		{
			servidor.receba (new PedidoParaSair ());
		}
		catch (Exception erro)
		{}
		
		System.out.println ("Obrigado por usar este programa!");
		System.exit(0);
	}
}

