Space Payments - Sistema de Pagamentos com Dinheiro do Inventário (QBOX)
Este script permite que jogadores realizem pagamentos diretos utilizando o dinheiro armazenado no inventário, ao invés do saldo bancário. Ideal para servidores que desejam integrar um sistema de economia física e realista.

Funcionalidades
Pagamento com dinheiro físico (money) do inventário.

Verificação automática de saldo antes da transação.

Bloqueia transações se o jogador não tiver saldo suficiente.

Totalmente adaptável para sistemas baseados na QBOX / MRI Framework.

Exportável para uso em diversos scripts (ex: lojas, missões, serviços, etc).
## Demonstração em Vídeo

[![Assista ao vídeo](https://img.youtube.com/vi/0p0K-FYdYhA/0.jpg)](https://youtu.be/0p0K-FYdYhA)


Requisitos
Framework QBOX/MRI com sistema de inventário integrado.

Inventário deve conter o item money com funcionalidade de adição e remoção.

Instalação
Adicione a pasta space_payments à sua pasta resources/[local].

No seu server.cfg, adicione:


ensure space_payments
Como Usar (Exemplo)
Para usar o sistema em outros scripts:


local amount = 500

TriggerServerEvent('space_payments:pay', amount, function(success)
    if success then
        print("Pagamento concluído!")
    else
        print("Saldo insuficiente.")
    end
end)

Testado Com
MRI QBOX (2024)

Inventário padrão com item money

Recursos de servidor em produção


Licença
Este script é gratuito para uso e modificação em servidores privados. É proibida a revenda ou redistribuição sem autorização da Space Store.

Desenvolvido por
Space Store — soluções otimizadas para servidores FiveM.
