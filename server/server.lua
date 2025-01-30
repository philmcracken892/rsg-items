local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterNetEvent('rewards:GiveItem', function(itemName)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    -- Add item to player's inventory
    Player.Functions.AddItem(itemName, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[itemName], 'add')
end)


