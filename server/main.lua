QBCore = exports["qb-core"]:GetCoreObject()

lib.addCommand(
    Config.PayCommand,
    {
        help = locale("command.pay")
        -- params = {},
        -- restricted = "group.admin",
    },
    function(source, args, raw)
        lib.callback(
            "space_payments:Client:Call",
            source,
            function()
            end,
            "pay"
        )
    end
)

lib.addCommand(
    Config.BillCommand,
    {
        help = locale("command.bill")
        -- params = {},
        -- restricted = "group.admin",
    },
    function(source, args, raw)
        Log.debug("Comando de pagamento acionado:", source, args, raw)
        lib.callback(
            "space_payments:Client:Call",
            source,
            function()
            end,
            "bill"
        )
    end
)

local function notifyPlayer(playerId, message, type)
    lib.notify(playerId, {description = message, type = type or "info"})
end

local function logTransactionError(action, playerCid, data)
    Log.error("Erro ao %s dinheiro do jogador: %s", action, playerCid)
    Log.debug("Dados da transação: %s", json.encode(data))
end

local function transferMoney(fromPlayer, toPlayer, amount, paymentType)
    local fromCid, toCid = fromPlayer.PlayerData.citizenid, toPlayer.PlayerData.citizenid

    local reasonFrom = locale("payment.reasonFrom", toCid)
    local reasonTo = locale("payment.reasonTo", fromCid)

    if exports.qbx_core:RemoveMoney(fromCid, paymentType, amount, reasonFrom) then
        if exports.qbx_core:AddMoney(toCid, paymentType, amount, reasonTo) then
            local formattedAmount = string.format("%s%.2f", Config.MoneyUnit, amount)
            notifyPlayer(fromPlayer.PlayerData.source, locale("payment.notifyFrom", formattedAmount), "success")
            notifyPlayer(toPlayer.PlayerData.source, locale("payment.notifyTo", formattedAmount), "success")
            return true
        else
            logTransactionError("adicionar", toCid, {from = fromCid, amount = amount, paymentType = paymentType})
        end
    else
        logTransactionError("remover", fromCid, {to = toCid, amount = amount, paymentType = paymentType})
    end
    return false
end

lib.callback.register(
    "space_payments:Server:ExecuteAction",
    function(source, data)
        local src = source
        local targetId, amount, paymentType, action = data.targetId, data.amount, data.paymentType, data.action

        local Player = QBCore.Functions.GetPlayer(src)
        local Target = QBCore.Functions.GetPlayer(targetId)

        if not Player or not Target then
            Log.debug("Player ou Target não encontrados: %s, %s", src, targetId)
            notifyPlayer(src, "Jogador não encontrado.", "error")
            return
        end

        if not paymentType or not Config.PaymentTypes[paymentType] then
            Log.debug("Tipo de pagamento inválido: %s", paymentType)
            notifyPlayer(src, "Tipo de pagamento inválido.", "error")
            return
        end

        if not amount or amount <= 0 then
            Log.debug("Valor inválido: %s", amount)
            notifyPlayer(src, "Valor inválido.", "error")
            return
        end

        Log.debug("Dados recebidos: %s, %s, %s", targetId, amount, paymentType)
        Log.debug("Player: %s", Player.PlayerData.citizenid)
        Log.debug("Target: %s", Target.PlayerData.citizenid)

        if action == "pay" then
            transferMoney(Player, Target, amount, paymentType)
        elseif action == "bill" then
            local senderName =
                ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
            data.senderName = senderName
            data.targetId, data.action = nil, nil

            Log.debug("Pedido de cobrança enviado ao jogador: %s", targetId)
            Log.debug("%s", json.encode(data, {indent = true}))

            local accepted = lib.callback.await("space_payments:Client:Bill", targetId, data)
            if not accepted then
                Log.debug("Jogador não aceitou a cobrança.")
                notifyPlayer(src, "Cobrança recusada.", "error")
                return
            end

            Log.debug("Cobrança aceita por: %s", targetId)
            transferMoney(Player, Target, amount, paymentType)
        end

        return true
    end
)
