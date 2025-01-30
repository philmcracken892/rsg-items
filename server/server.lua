local RSGCore = exports['rsg-core']:GetCoreObject()


local itemQuantityRanges = {
    
    apple = {1, 3},
    herbs = {1, 4},
    tobacco = {1, 3},
    sugar = {1, 3},
    carrot = {1, 4},
    broccoli = {1, 3},
    potato = {1, 4},
    water = {1, 2},
    corn = {1, 3}
}


local defaultRange = {1, 2}

RegisterNetEvent('rewards:GiveItem', function(itemName)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    
    local range = itemQuantityRanges[itemName] or defaultRange
    
    local quantity = math.random(range[1], range[2])
    
    Player.Functions.AddItem(itemName, quantity)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[itemName], 'add')
    
    TriggerClientEvent('rewards:ItemCollected', src, itemName, quantity)
end)

