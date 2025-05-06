QBCore = exports["qb-core"]:GetCoreObject()

lib.callback.register(
    "space_payments:payPlayer",
    function(source, targetId, amount, paymentType)
        if Config.Debug then
            print(json.encode(targetId), "target")
            print(json.encode(amount), "amount")
            print(json.encode(paymentType), "paymentType")
        end
        local src = source
        local Player = QBCore.Functions.GetPlayer(src) -- QBCore (novo)
        local Target = QBCore.Functions.GetPlayer(targetId) -- QBCore (novo)
        if Config.Debug then
            print(json.encode(Target), "Target")
            print(json.encode(Player), "Player")
        end

        if not Player or not Target then
            TriggerClientEvent("ox_lib:notify", src, {description = "Jogador não encontrado.", type = "error"})
            return
        end

        local balance = Player.Functions.GetMoney(paymentType)
        if balance < amount then
            TriggerClientEvent(
                "ox_lib:notify",
                src,
                {description = "Você não tem dinheiro suficiente.", type = "error"}
            )
            return
        end

        Player.Functions.RemoveMoney(paymentType, amount)
        Target.Functions.AddMoney(paymentType, amount)
        TriggerClientEvent(
            "ox_lib:notify",
            src,
            {description = "Pagamento enviado diretamente para o inventário!", type = "info"}
        )
        TriggerClientEvent(
            "ox_lib:notify",
            targetId,
            {description = "Você recebeu R$" .. amount .. " no seu inventário.", type = "success"}
        )

        return true
    end
)

lib.callback.register(
    "space_payments:requestPayment",
    function(source, targetId, amount, paymentType)
        if Config.Debug then
            print("DEBUG: Callback requestPayment acionado:", source, targetId, amount, paymentType)
        end

        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        local Target = QBCore.Functions.GetPlayer(targetId)

        if not Player or not Target then
            if Config.Debug then
                print("DEBUG: Player ou Target não encontrados.")
            end
            TriggerClientEvent("ox_lib:notify", src, {description = "Jogador não encontrado.", type = "error"})
            return
        end

        local senderName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname

        TriggerClientEvent(
            "space_payments:client:receivePaymentRequest",
            targetId,
            src,
            senderName,
            amount,
            paymentType
        )
        if Config.Debug then
            print("DEBUG: Pedido de pagamento enviado ao jogador", targetId)
        end
    end
)

RegisterNetEvent(
    "space_payments:server:confirmPayment",
    function(requesterId, amount, paymentType)
        local payer = source
        if Config.Debug then
            print("DEBUG: Evento confirmPayment acionado pelo jogador", payer)
        end

        local PayerPlayer = QBCore.Functions.GetPlayer(payer)
        local RequesterPlayer = QBCore.Functions.GetPlayer(requesterId)

        if not PayerPlayer or not RequesterPlayer then
            if Config.Debug then
                print("DEBUG: Payer ou Requester não encontrados.")
            end
            return
        end

        local balance = PayerPlayer.Functions.GetMoney(paymentType)
        if Config.Debug then
            print("DEBUG: Saldo atual do jogador que vai pagar:", balance)
        end

        if balance < amount then
            if Config.Debug then
                print("DEBUG: Saldo insuficiente.")
            end
            TriggerClientEvent("ox_lib:notify", payer, {description = "Saldo insuficiente para pagar.", type = "error"})
            return
        end

        -- Remove e adiciona dinheiro
        local remove = PayerPlayer.Functions.RemoveMoney(paymentType, amount)
        local add = RequesterPlayer.Functions.AddMoney(paymentType, amount)

        if Config.Debug then
            print("DEBUG: Remoção de dinheiro:", remove)
            print("DEBUG: Adição de dinheiro:", add)
        end

        -- Notificações
        TriggerClientEvent("ox_lib:notify", payer, {description = "Você pagou R$" .. amount .. ".", type = "success"})
        TriggerClientEvent(
            "ox_lib:notify",
            requesterId,
            {
                description = "Você recebeu R$" .. amount .. " de " .. PayerPlayer.PlayerData.charinfo.firstname,
                type = "success"
            }
        )
    end
)
