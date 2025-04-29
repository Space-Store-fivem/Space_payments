local ox = exports.ox_lib

local phoneProp = nil

-- Função para iniciar animação + spawnar celular
local function StartPhoneAnim()
    local ped = PlayerPedId()
    RequestAnimDict('cellphone@')
    while not HasAnimDictLoaded('cellphone@') do
        Wait(10)
    end
    TaskPlayAnim(ped, 'cellphone@', 'cellphone_text_in', 8.0, -8.0, -1, 50, 0, false, false, false)

    Wait(500)
    local model = GetHashKey('prop_phone_ing')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    phoneProp = CreateObject(model, GetEntityCoords(ped), true, true, true)
    AttachEntityToEntity(phoneProp, ped, GetPedBoneIndex(ped, 28422),
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        true, true, false, true, 1, true)
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

    local data = lib.inputDialog('Pagamento', {
        {type = 'number', label = 'ID do Jogador', placeholder = 'Ex: 5', icon = 'user'},
        {type = 'number', label = 'Valor a pagar', placeholder = 'Ex: 500', icon = 'dollar-sign'}
    })

    StopPhoneAnim() -- <-- quando fechar, para animação e remove prop

    print(json.encode(data), 'data')
    if not data then return end

    local targetId = data[1]
    local amount = data[2]
    
    if not targetId or not amount or amount <= 0 then
        lib.notify({description = 'ID ou valor inválido.', type = 'error'})
        return
    end

    local result = lib.callback.await("space_payments:payPlayer", false, targetId, amount)
end

-- Comando para abrir
RegisterCommand('pagar', function()
    paypal()
end)
