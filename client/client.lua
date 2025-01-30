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
    
    
    TriggerServerEvent('rewards:GiveItem', interaction.rewardItem, interaction.quantity or 1)
    
    
    local itemName = interaction.rewardItem or "item"
    local itemQuantity = interaction.quantity or 1
    TriggerEvent('rNotify:NotifyLeft', "ITEM COLLECTED", "You collected " .. itemQuantity .. "x " .. itemName, "generic_textures", "tick", 4000)
    
    
    setCooldown(interaction.rewardItem)
    
    
    ClearPedTasks(playerPed)
    active = false
end

local function SetupRewardInteractions()
    
    local itemIcons = {
        apple = {
            start = '🍎',  -- apple
            end_icon = '🧺'  -- basket
        },
        herbs = {
            start = '🌿',  -- herb
            end_icon = '✨'  -- sparkles
        },
        tobacco = {
            start = '🌱',  -- seedling
            end_icon = '🍃'  -- leaf
        },
        sugar = {
            start = '🎋',  -- bamboo (representing sugarcane)
            end_icon = '🧺'  -- basket
        },
        carrot = {
            start = '🥕',  -- carrot
            end_icon = '🧺'  -- basket
        },
        broccoli = {
            start = '🥦',  -- broccoli
            end_icon = '🧺'  -- basket
        },
        potato = {
            start = '🥔',  -- potato
            end_icon = '🧺'  -- basket
        },
        water = {
            start = '💧',  -- water drop
            end_icon = '🌵'  -- cactus
        },
        corn = {
            start = '🌽',  -- corn
            end_icon = '🧺'  -- basket
        }
    }
    
    local defaultIcons = {
        start = '🔄',
        end_icon = '📥'
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
