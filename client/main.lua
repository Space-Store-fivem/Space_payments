local ox = exports.ox_lib

local phoneProp = nil

-- Função para iniciar animação + spawnar celular
local function StartPhoneAnim()
    local ped = PlayerPedId()
    RequestAnimDict("cellphone@")
    while not HasAnimDictLoaded("cellphone@") do
        Wait(10)
    end
    TaskPlayAnim(ped, "cellphone@", "cellphone_text_in", 8.0, -8.0, -1, 50, 0, false, false, false)

    Wait(500)
    local model = GetHashKey("prop_phone_ing")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    phoneProp = CreateObject(model, GetEntityCoords(ped), true, true, true)
    AttachEntityToEntity(
        phoneProp,
        ped,
        GetPedBoneIndex(ped, 28422),
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        true,
        true,
        false,
        true,
        1,
        true
    )
end

-- Função para parar animação e remover prop
local function StopPhoneAnim()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    if phoneProp then
        DeleteEntity(phoneProp)
        phoneProp = nil
    end
end

-- Função principal de pagamento
local function paypal()
    StartPhoneAnim() -- <-- começa a animação e prop

    local data =
        lib.inputDialog(
        "Pagamento",
        {
            {type = "number", label = "ID do Jogador", placeholder = "Ex: 5", icon = "user"},
            {type = "number", label = "Valor a pagar", placeholder = "Ex: 500", icon = "dollar-sign"},
            {
                type = "select",
                label = "Método de pagamento",
                icon = "credit-card",
                options = {
                    {label = "Dinheiro (cash)", value = "cash"},
                    {label = "Banco (bank)", value = "bank"}
                }
            }
        }
    )

    StopPhoneAnim() -- <-- quando fechar, para animação e remove prop

    if Config.Debug then
        print("DEBUG: Dados inseridos no menu:", json.encode(data, {indent = true}))
    end
    if not data then
        return
    end

    local targetId = data[1]
    local amount = data[2]
    local paymentType = data[3]

    if not targetId or not amount or amount <= 0 or not paymentType then
        lib.notify({description = "Informações inválidas.", type = "error"})
        return
    end

    local result = lib.callback.await("space_payments:payPlayer", false, targetId, amount, paymentType)
end

-- Comando para abrir
RegisterCommand(
    "pagar",
    function()
        paypal()
    end
)

RegisterCommand(
    "cobrar",
    function()
        StartPhoneAnim()

        local data =
            lib.inputDialog(
            "Cobrança",
            {
                {type = "number", label = "ID do Jogador", placeholder = "Ex: 5", icon = "user"},
                {type = "number", label = "Valor a cobrar", placeholder = "Ex: 500", icon = "dollar-sign"},
                {
                    type = "select",
                    label = "Método de pagamento",
                    icon = "credit-card",
                    options = {
                        {label = "Dinheiro (cash)", value = "cash"},
                        {label = "Banco (bank)", value = "bank"}
                    }
                }
            }
        )

        StopPhoneAnim()

        if Config.Debug then
            print("DEBUG: Dados inseridos no menu:", json.encode(data, {indent = true}))
        end

        if not data then
            return
        end

        local targetId = data[1]
        local amount = data[2]
        local paymentType = data[3]

        if not targetId or not amount or amount <= 0 or not paymentType then
            lib.notify({description = "Informações inválidas.", type = "error"})
            if Config.Debug then
                print("DEBUG: Informações inválidas.")
            end
            return
        end

        lib.callback.await("space_payments:requestPayment", false, targetId, amount, paymentType)
    end
)

RegisterNetEvent(
    "space_payments:client:receivePaymentRequest",
    function(fromId, senderName, amount, paymentType)
        if Config.Debug then
            print("DEBUG: Recebida cobrança de:", senderName, amount, paymentType)
        end

        local alert =
            lib.alertDialog(
            {
                header = "Pedido de Pagamento",
                content = senderName ..
                    " está te cobrando R$" ..
                        amount .. " via " .. (paymentType == "cash" and "Dinheiro" or "Banco") .. ". Aceitar?",
                centered = true,
                cancel = true,
                labels = {confirm = "Pagar", cancel = "Negar"}
            }
        )
        if alert == "confirm" then
            if Config.Debug then
                print("DEBUG: Jogador aceitou pagar.")
            end
            TriggerServerEvent("space_payments:server:confirmPayment", fromId, amount, paymentType)
        else
            if Config.Debug then
                print("DEBUG: Jogador recusou a cobrança.")
            end
            lib.notify({description = "Você recusou a cobrança.", type = "error"})
        end
    end
)
