local QBCore = nil
local ESX = nil
local PlayerData = {}
local hunger = 100
local thirst = 100

-- Initialize framework
CreateThread(function()
    if Config.Framework == 'qb-core' then
        QBCore = exports['qb-core']:GetCoreObject()
        while not QBCore do
            Wait(100)
        end
    else
        ESX = exports['es_extended']:getSharedObject()
        while not ESX do
            Wait(100)
        end
    end
end)

-- Cache last values to avoid unnecessary updates
local lastValues = {
    health = 0,
    armor = 0,
    food = 0,
    water = 0,
    id = 0,
    location = ""
}

-- Get current location
function GetLocationText()
    if not Config.ShowLocation then return "" end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    return street
end

function updateHUD()
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped)
    local armor = GetPedArmour(ped)
    local currentId = Config.ShowPlayerId and GetPlayerServerId(PlayerId()) or 0
    local location = GetLocationText()
    
    -- Fix health showing negative values when dead
    if health < 100 then
        health = 0
    else
        health = health - 100
    end

    -- Round all values to whole numbers
    health = math.floor(health + 0.5)
    armor = math.floor(armor + 0.5)
    hunger = math.floor(hunger + 0.5)
    thirst = math.floor(thirst + 0.5)

    -- Only send update if values changed
    if health ~= lastValues.health or 
       armor ~= lastValues.armor or 
       hunger ~= lastValues.food or 
       thirst ~= lastValues.water or
       currentId ~= lastValues.id or
       location ~= lastValues.location then
        
        -- Update cache
        lastValues.health = health
        lastValues.armor = armor
        lastValues.food = hunger
        lastValues.water = thirst
        lastValues.id = currentId
        lastValues.location = location
        
        -- Send to UI
        SendNUIMessage({
            type = 'updateStatusHud',
            show = true,
            health = health,
            armor = armor,
            food = hunger,
            water = thirst,
            id = currentId,
            location = location,
            showId = Config.ShowPlayerId,
            showLocation = Config.ShowLocation
        })
    end
end

-- Update HUD every 200ms
CreateThread(function()
    while true do
        updateHUD()
        Wait(Config.UpdateInterval)
    end
end)

-- Framework specific events
if Config.Framework == 'qb-core' then
    -- QB-Core status updates
    RegisterNetEvent('hud:client:UpdateNeeds')
    AddEventHandler('hud:client:UpdateNeeds', function(newHunger, newThirst)
        hunger = math.floor(newHunger + 0.5)
        thirst = math.floor(newThirst + 0.5)
    end)
else
    -- ESX status updates
    RegisterNetEvent('esx_status:onTick')
    AddEventHandler('esx_status:onTick', function(status)
        for _, status in ipairs(status) do
            if status.name == 'hunger' then
                hunger = math.floor(status.percent + 0.5)
            end
            if status.name == 'thirst' then
                thirst = math.floor(status.percent + 0.5)
            end
        end
    end)
end
