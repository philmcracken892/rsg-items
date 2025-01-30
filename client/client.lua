local RSGCore = exports['rsg-core']:GetCoreObject()
local active = false
local cooldowns = {}

local function getRemainingCooldown(itemType)
    if not cooldowns[itemType] then return 0 end
    local timeElapsed = GetGameTimer() - cooldowns[itemType]
    local remainingTime = math.ceil((20000 - timeElapsed) / 1000) 
    return remainingTime > 0 and remainingTime or 0
end

local function isOnCooldown(itemType)
    if not cooldowns[itemType] then return false end
    return (GetGameTimer() - cooldowns[itemType]) < 20000 -- 20 second cooldown
end

local function setCooldown(itemType)
    cooldowns[itemType] = GetGameTimer()
end

local function goCollect(interaction)
    if active then return end
    
    if isOnCooldown(interaction.rewardItem) then
        local remainingSeconds = getRemainingCooldown(interaction.rewardItem)
        TriggerEvent('rNotify:NotifyLeft', "COLLECTION COOLDOWN", "Wait " .. remainingSeconds .. " seconds", "generic_textures", "tick", 4000)
        return
    end

    active = true
    local playerPed = PlayerPedId()
    
    RequestAnimDict(interaction.animDict or "mech_pickup@plant@yarrow")
    while not HasAnimDictLoaded(interaction.animDict or "mech_pickup@plant@yarrow") do
        Wait(100)
    end
    
    TaskPlayAnim(playerPed, 
        interaction.animDict or "mech_pickup@plant@yarrow", 
        interaction.enterAnim or "enter_lf", 
        8.0, -0.5, -1, 0, 0, true, 0, false, 0, false
    )
    Wait(800)
    
    TaskPlayAnim(playerPed, 
        interaction.animDict or "mech_pickup@plant@yarrow", 
        interaction.baseAnim or "base", 
        8.0, -0.5, -1, 0, 0, true, 0, false, 0, false
    )
    Wait(2300)
    
    
    TriggerServerEvent('rewards:GiveItem', interaction.rewardItem)
    
    setCooldown(interaction.rewardItem)
    ClearPedTasks(playerPed)
    active = false
end

RegisterNetEvent('rewards:ItemCollected', function(itemName, quantity)
    TriggerEvent('rNotify:NotifyLeft', "ITEM COLLECTED", "You found " .. quantity .. "x " .. itemName, "generic_textures", "tick", 4000)
end)

local function SetupRewardInteractions()
    -- Define icons for different item types
    local itemIcons = {
        apple = {
            start = '๐',  -- apple
            end_icon = '๐งบ'  -- basket
        },
        herbs = {
            start = '๐ฟ',  -- herb
            end_icon = 'โจ'  -- sparkles
        },
        tobacco = {
            start = '๐ฑ',  -- seedling
            end_icon = '๐'  -- leaf
        },
        sugar = {
            start = '๐',  -- bamboo (representing sugarcane)
            end_icon = '๐งบ'  -- basket
        },
        carrot = {
            start = '๐ฅ•',  -- carrot
            end_icon = '๐งบ'  -- basket
        },
        broccoli = {
            start = '๐ฅฆ',  -- broccoli
            end_icon = '๐งบ'  -- basket
        },
        potato = {
            start = '๐ฅ”',  -- potato
            end_icon = '๐งบ'  -- basket
        },
        water = {
            start = '๐’ง',  -- water drop
            end_icon = '๐ต'  -- cactus
        },
        corn = {
            start = '๐ฝ',  -- corn
            end_icon = '๐งบ'  -- basket
        }
    }
    
    local defaultIcons = {
        start = '๐”',
        end_icon = '๐“ฅ'
    }
    for _, interaction in ipairs(Config.RewardInteractions) do
        if not interaction.rewardItem then
            print("Warning: Interaction missing rewardItem")
            goto continue
        end
        
        local icons = itemIcons[interaction.rewardItem] or defaultIcons
        
        exports.ox_target:addModel(interaction.models, {
            {
                name = interaction.rewardItem .. '_pickup',
                label = interaction.label or "Collect Item",
                icon = interaction.icon,
                onSelect = function(data)
                    if isOnCooldown(interaction.rewardItem) then
                        local remainingSeconds = getRemainingCooldown(interaction.rewardItem)
                        TriggerEvent('rNotify:NotifyLeft', "COLLECTION COOLDOWN", "Wait " .. remainingSeconds .. " seconds", "generic_textures", "tick", 4000)
                        return
                    end
                    
                    if lib.progressBar({
                        duration = 1000,
                        label = icons.start .. ' ' .. (interaction.label or "Collecting") .. ' ' .. icons.end_icon,
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = true,
                            combat = true
                        }
                    }) then
                        goCollect(interaction)
                    end
                end,
                distance = interaction.distance or 2.0
            }
        })
        
        ::continue::
    end
end

Citizen.CreateThread(function()
    SetupRewardInteractions()
end)
