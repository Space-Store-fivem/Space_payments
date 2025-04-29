
lib.callback.register("space_payments:payPlayer", function(source, targetId, amount)
    print('estou aqui puta')
    print(json.encode(targetId),'target')
    print(json.encode(amount),'amount')
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    local Target = exports.qbx_core:GetPlayer(tonumber(targetId))
    print(json.encode(Target),'Target')
    print(json.encode(Player),'Player')

    if not Player or not Target then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Jogador não encontrado.', type = 'error'})
        return
    end

    local cash = Player.Functions.GetMoney('cash')
    if cash < amount then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Você não tem dinheiro suficiente.', type = 'error'})
        return
    end

    Player.Functions.RemoveMoney('cash', amount)

    local jobName = Target.PlayerData.job.name

    if jobName and jobName ~= "unemployed" and jobName ~= "none" then
        print(json.encode(jobName),'jobname')
        print(json.encode(amount),'quantidade')
        local updated = exports['ps-banking']:AddMoney(jobName, amount, string.format("Você recebeu R$ %s na conta de trabalho", amount))
        if updated then
            TriggerClientEvent('ox_lib:notify', targetId, {description = 'Você recebeu R$'..amount..' na conta de trabalho.', type = 'success'})
        end
        print(json.encode(updated),'psbanking')
        if not updated  then
            TriggerClientEvent('ox_lib:notify', src, {description = 'Não foi possivel encontrar a conta!', type = 'error'})
            return
        end
     else
        Target.Functions.AddMoney('cash', amount)
        TriggerClientEvent('ox_lib:notify', src, {description = 'Pagamento enviado diretamente para o inventário!', type = 'info'})
        TriggerClientEvent('ox_lib:notify', targetId, {description = 'Você recebeu R$'..amount..' no seu inventário.', type = 'success'})
    end
    return true
end)

-- RegisterNetEvent('space_payments:payPlayer', function(targetId, amount)
--     print('estou aqui puta')
--     local src = source
--     local Player = exports['qbx-core']:GetPlayer(src)
--     local Target = exports['qbx-core']:GetPlayer(tonumber(targetId))
--     print(json.encode(Target),'Target')
--     print(json.encode(Player),'Player')

--     if not Player or not Target then
--         TriggerClientEvent('ox_lib:notify', src, {description = 'Jogador não encontrado.', type = 'error'})
--         return
--     end

--     local cash = Player.Functions.GetMoney('cash')
--     if cash < amount then
--         TriggerClientEvent('ox_lib:notify', src, {description = 'Você não tem dinheiro suficiente.', type = 'error'})
--         return
--     end

--     Player.Functions.RemoveMoney('cash', amount)

--     local jobName = Target.PlayerData.job.name

--     if jobName and jobName ~= "unemployed" and jobName ~= "none" then
--         print(json.encode(jobName),'jobname')
--         print(json.encode(amount),'quantidade')
--         local updated = exports['ps-banking']:AddMoney(jobName, amount, string.format("Você recebeu R$ %s na conta de trabalho", amount))
--         print(json.encode(updated),'psbanking')
--         -- local updated = MySQL.update.await('UPDATE ps_banking_accounts SET balance = balance + ? WHERE holder = ?', { amount, jobName })
--         if not updated  then
--             TriggerClientEvent('ox_lib:notify', src, {description = 'Não foi possivel encontrar a conta!', type = 'error'})
--             return
--         end
--     end

--     Target.Functions.AddMoney('cash', amount)
--     TriggerClientEvent('ox_lib:notify', src, {description = 'Pagamento enviado diretamente para o inventário!', type = 'info'})
--     TriggerClientEvent('ox_lib:notify', targetId, {description = 'Você recebeu R$'..amount..' no seu inventário.', type = 'success'})
-- end)
