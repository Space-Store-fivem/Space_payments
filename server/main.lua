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

lib.callback.register(
    "space_payments:Server:ExecuteAction",
    function(source, data)
        local src = source
        local targetId = data.targetId
        local amount = data.amount
        local paymentType = data.paymentType

        local Player = QBCore.Functions.GetPlayer(src)
        local Target = QBCore.Functions.GetPlayer(targetId)

        if not Player or not Target then
            Log.debug("Player ou Target não encontrados: %s, %s", src, targetId)
            lib.notify(src, {description = "Jogador não encontrado.", type = "error"})
            return
        end

        if not paymentType or not Config.PaymentTypes[paymentType] then
            Log.debug("Tipo de pagamento inválido.", paymentType)
            lib.notify(src, {description = "Tipo de pagamento inválido.", type = "error"})
            return
        end

        if not amount or amount <= 0 then
            Log.debug("Valor inválido.", amount)
            lib.notify(src, {description = "Valor inválido.", type = "error"})
            return
        end

        Log.debug("Dados recebidos: ", targetId, amount, paymentType)
        Log.debug("Player: ", Player.PlayerData.citizenid)
        Log.debug("Target: ", Target.PlayerData.citizenid)

        if data.action == "pay" then
            if
                exports.qbx_core:RemoveMoney(
                    Player.PlayerData.citizenid,
                    paymentType,
                    amount,
                    locale("payment.reasonFrom", Target.PlayerData.citizenid)
                )
             then
                if
                    exports.qbx_core:AddMoney(
                        Target.PlayerData.citizenid,
                        paymentType,
                        amount,
                        locale("payment.reasonTo", Player.PlayerData.citizenid)
                    )
                 then
                    lib.notify(
                        src,
                        {
                            description = locale(
                                "payment.notifyFrom",
                                string.format("%s%.2f", Config.MoneyUnit, amount)
                            ),
                            type = "success"
                        }
                    )

                    lib.notify(
                        targetId,
                        {
                            description = locale("payment.notifyTo", string.format("%s%.2f", Config.MoneyUnit, amount)),
                            type = "success"
                        }
                    )
                else
                    Log.error("Erro ao adicionar dinheiro ao jogador: %s", Target.PlayerData.citizenid)
                    Log.debug("Dados da transação: ", json.encode(data))
                    lib.notify(src, {description = "Erro ao realizar pagamento.", type = "error"})
                end
            else
                Log.error("Erro ao remover dinheiro do jogador: %s", Player.PlayerData.citizenid)
                Log.debug("Dados da transação: ", json.encode(data))
                lib.notify(src, {description = "Erro ao realizar pagamento.", type = "error"})
            end
        elseif data.action == "bill" then
            local senderName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname

            Log.debug("Pedido de cobrança enviado ao jogador: %s", targetId)
            Log.debug("%s", json.encode(data, {indent = true}))
            data.targetId = nil
            data.action = nil
            data["senderName"] = senderName
            Log.debug("%s", json.encode(data, {indent = true}))
            local result = lib.callback.await("space_payments:Client:Bill", targetId, data)
            if not result then
                Log.debug("Jogador não aceitou a cobrança.")
                lib.notify(src, {description = "Cobrança recusada.", type = "error"})
                return
            end

            Log.debug("Pedido de cobrança aceito pelo jogador: %s", targetId)

            if
                exports.qbx_core:RemoveMoney(
                    Player.PlayerData.citizenid,
                    paymentType,
                    amount,
                    locale("payment.reasonFrom", Target.PlayerData.citizenid)
                )
             then
                if
                    exports.qbx_core:AddMoney(
                        Target.PlayerData.citizenid,
                        paymentType,
                        amount,
                        locale("payment.reasonTo", Player.PlayerData.citizenid)
                    )
                 then
                    lib.notify(
                        src,
                        {
                            description = locale(
                                "payment.notifyFrom",
                                string.format("%s%.2f", Config.MoneyUnit, amount)
                            ),
                            type = "success"
                        }
                    )

                    lib.notify(
                        targetId,
                        {
                            description = locale("payment.notifyTo", string.format("%s%.2f", Config.MoneyUnit, amount)),
                            type = "success"
                        }
                    )
                    Log.debug("Cobrança realizada com sucesso.")
                else
                    Log.error("Erro ao adicionar dinheiro ao jogador: %s", Target.PlayerData.citizenid)
                    Log.debug("Dados da transação: ", json.encode(data))
                    lib.notify(src, {description = "Erro ao realizar cobrança.", type = "error"})
                end
            else
                Log.error("Erro ao remover dinheiro do jogador: %s", Player.PlayerData.citizenid)
                Log.debug("Dados da transação: ", json.encode(data))
                lib.notify(src, {description = "Erro ao realizar cobrança.", type = "error"})
            end
        end

        return true
    end
)
