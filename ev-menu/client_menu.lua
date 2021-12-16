ESX               = nil
local IsDragged                 = false
myJob = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- Menu state
local showMenu = false

-- Keybind Lookup table
local keybindControls = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18, ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182, ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81, ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178, ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173, ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local MAX_MENU_ITEMS = 9

-- Main thread
Citizen.CreateThread(function()
    local keyBind = "F3"
    while true do
        if IsControlJustPressed(0, keybindControls[keyBind]) and GetLastInputMethod(2) and showMenu then
            showMenu = false
            SetNuiFocus(false, false)
        end
        if IsDisabledControlPressed(0, keybindControls[keyBind]) and GetLastInputMethod(2) --[[and not exports['police']:IsHandcuffed() ]]then
            showMenu = true
            local enabledMenus = {}
            for _, menuConfig in ipairs(rootMenuConfig) do
                if menuConfig:enableMenu() then
                    local dataElements = {}
                    local hasSubMenus = false
                    if menuConfig.subMenus ~= nil and #menuConfig.subMenus > 0 then
                        hasSubMenus = true
                        local previousMenu = dataElements
                        local currentElement = {}
                        for i = 1, #menuConfig.subMenus do
                            if newSubMenus[menuConfig.subMenus[i]] ~= nil and newSubMenus[menuConfig.subMenus[i]].enableMenu ~= nil and not newSubMenus[menuConfig.subMenus[i]]:enableMenu() then
                                else
                                currentElement[#currentElement+1] = newSubMenus[menuConfig.subMenus[i]]
                                currentElement[#currentElement].id = menuConfig.subMenus[i]
                                currentElement[#currentElement].enableMenu = nil
    
                                if i % MAX_MENU_ITEMS == 0 and i < (#menuConfig.subMenus - 1) then
                                    previousMenu[MAX_MENU_ITEMS + 1] = {
                                        id = "_more",
                                        title = "More",
                                        icon = "#more",
                                        items = currentElement
                                    }
                                    previousMenu = currentElement
                                    currentElement = {}
                                end
                            end
                        end
                        if #currentElement > 0 then
                            previousMenu[MAX_MENU_ITEMS + 1] = {
                                id = "_more",
                                title = "More",
                                icon = "#more",
                                items = currentElement
                            }
                        end
                        dataElements = dataElements[MAX_MENU_ITEMS + 1].items

                    end
                    enabledMenus[#enabledMenus+1] = {
                        id = menuConfig.id,
                        title = menuConfig.displayName,
                        functionName = menuConfig.functionName,
                        icon = menuConfig.icon,
                    }
                    if hasSubMenus then
                        enabledMenus[#enabledMenus].items = dataElements
                    end
                end
            end
            SendNUIMessage({
                state = "show",
                resourceName = GetCurrentResourceName(),
                data = enabledMenus,
                menuKeyBind = keyBind
            })
            SetCursorLocation(0.5, 0.5)
            SetNuiFocus(true, true)

            -- Play sound
            PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)


            while showMenu == true do Citizen.Wait(100) end
            Citizen.Wait(100)
            while IsDisabledControlPressed(0, keybindControls[keyBind]) and GetLastInputMethod(2) do Citizen.Wait(100) end
        end
		Citizen.Wait(0)
    end
end)
-- Callback function for closing menu
RegisterNUICallback('closemenu', function(data, cb)
    -- Clear focus and destroy UI
    showMenu = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })

    -- Play sound
   --  PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)

    -- Send ACK to callback function
    cb('ok')
end)

RegisterCommand('closemenu', function()
    showMenu = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })
end)

-- Callback function for when a slice is clicked, execute command
RegisterNUICallback('triggerAction', function(data, cb)
    -- Clear focus and destroy UI
    showMenu = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })

    -- Play sound
    -- PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)

    -- Run command
    --ExecuteCommand(data.action)
    TriggerEvent(data.action, data.parameters)

    -- Send ACK to callback function
    cb('ok')
end)

RegisterNetEvent("menu:menuexit")
AddEventHandler("menu:menuexit", function()
    showMenu = false
    SetNuiFocus(false, false)
end)

RegisterNetEvent('menu:handcuff')
AddEventHandler('menu:handcuff', function()
    local target, distance = ESX.Game.GetClosestPlayer()
    playerheading = GetEntityHeading(GetPlayerPed(-1))
    playerlocation = GetEntityForwardVector(PlayerPedId())
    playerCoords = GetEntityCoords(GetPlayerPed(-1))
    local target_id = GetPlayerServerId(target)
    if closestPlayer == -1 or distance < 4.0 then
        TriggerServerEvent('esx_policejob:requestarrest', target_id, playerheading, playerCoords, playerlocation)
    else
        TriggerEvent('notification', 'No Players Nearby', 2)
    end
end)

RegisterNetEvent('menu:unhandcuff')
AddEventHandler('menu:unhandcuff', function()
    local target, distance = ESX.Game.GetClosestPlayer()
    playerheading = GetEntityHeading(GetPlayerPed(-1))
    playerlocation = GetEntityForwardVector(PlayerPedId())
    playerCoords = GetEntityCoords(GetPlayerPed(-1))
    local target_id = GetPlayerServerId(target)
    if closestPlayer == -1 or distance < 4.0 then
        TriggerServerEvent('esx_policejob:requestrelease', target_id, playerheading, playerCoords, playerlocation)
    else
        TriggerEvent('notification', 'No Players Nearby', 2)
    end
end)

function GetClosestPlayer(radius)

    local players = GetPlayers()

    local closestDistance = -1

    local closestPlayer = -1

    local ply = GetPlayerPed(-1)

    local plyCoords = GetEntityCoords(ply, 0)
    
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)

        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)

            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end

    if closestDistance <= radius then
        return closestPlayer
    else
        return nil
    end
end

RegisterNetEvent('menu:vehicle:toggleMenu')
AddEventHandler('menu:vehicle:toggleMenu', function()
    exports['carcontrol']:OpenUI()
end)

function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do

        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)    
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)
        offset = offset - 1

        if vehicle ~= 0 then break end
    end

    local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))

    if distance > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

function GetPlayers()
    local players = {}

    for _, i in ipairs(GetActivePlayers()) do
        table.insert(players, i)
    end

    return players
end

local IsEMSBusy = false
RegisterNetEvent('menu:ems')
AddEventHandler('menu:ems', function( caction)
    local src = source
    local currentAction = caction[1]
    if IsEMSBusy then return end

    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestDistance > 5.0 then
        TriggerEvent('notification', 'No players nearby', 2)
    else
        if currentAction == "revive" then
            IsEMSBusy = true
            ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
                if quantity > 0 then
                    local closestPlayerPed = GetPlayerPed(closestPlayer)
        
                    if IsPedDeadOrDying(closestPlayerPed, 1) then
                        local playerPed = PlayerPedId()
        
                        TriggerEvent('notification', 'Started reviving the player', 1)
        
                        local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
        
                        for i=1, 15, 1 do
                            Citizen.Wait(900)
                    
                            ESX.Streaming.RequestAnimDict(lib, function()
                                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
                            end)
                        end
        
                        TriggerServerEvent('esx_ambulancejob:removeItem', 'medkit')
                        TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
        
                        TriggerEvent('notification', 'You revived '..GetPlayerName(closestPlayer)..' and earned 50!', 1)
                    else
                        TriggerEvent('notification', 'That player is not conscious!', 2)
                    end
                else
                    TriggerEvent('notification', 'You dont have medkit', 2)
                end
                IsEMSBusy = false
            end, 'medkit')

        elseif currentAction == "heal" then
            ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
                if quantity > 0 then
                    local closestPlayerPed = GetPlayerPed(closestPlayer)
                    local health = GetEntityHealth(closestPlayerPed)

                    if health > 0 then
                        local playerPed = PlayerPedId()

                        IsEMSBusy = true
                        TriggerEvent('notification', 'You are healing!', 1)
                        TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                        Citizen.Wait(10000)
                        ClearPedTasks(playerPed)

                        TriggerServerEvent('esx_ambulancejob:removeItem', 'bandage')
                        TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')
                        TriggerEvent('notification', 'You have healed ' .. GetPlayerName(closestPlayer), 1)
                        IsEMSBusy = false
                    else
                        TriggerEvent('notification', 'That player is not conscious!', 2)
                    end
                else
                    TriggerEvent('notification', 'You do not have bandage', 2)
                end
            end, 'bandage')

        elseif currentAction == "bill" then
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
                title = 'Bill Amount'
            },function(data, menu)
                local amount = tonumber(data.value)

                if amount == nil or amount < 0 then
                    TriggerEvent('notification', 'Invalid Amount', 2)
                else
                    menu.close()
                    TriggerEvent('notification', 'Sent the bill to the player', 1)
                    TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_ambulance', 'EMS', amount)
                end
            end, function(data, menu)
                menu.close()
            end)
        end
    end
end) 

local isInVehicle = false
RegisterNetEvent('menu:police')
AddEventHandler('menu:police', function(caction)
    local src = source
    local currentAction = caction[1]

    if IsEMSBusy then return end
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestDistance > 5.0 then
        TriggerEvent('notification', 'No players nearby.', 2)
    else
        if currentAction == "bill" then
            TriggerEvent('menu:police:fines', closestPlayer)
        elseif currentAction == "vio" then
            if isInVehicle then
                TriggerServerEvent('esx_policejob:OutVehicle', GetPlayerServerId(closestPlayer))
                isInVehicle = false
            else
                TriggerServerEvent('esx_policejob:putInVehicle', GetPlayerServerId(closestPlayer))
                isInVehicle = true
            end
        elseif currentAction == "bills" then
            TriggerEvent('menu:police:bills', closestPlayer)
        end
    end
end) 

RegisterNetEvent('menu:police:mdt')
AddEventHandler('menu:police:mdt', function()
    TriggerServerEvent("mdt:hotKeyOpen")
end)

RegisterNetEvent('menu:general:callmechanic')
AddEventHandler('menu:general:callmechanic', function()
    ESX.TriggerServerCallback('menu:checkMoney', function(hasMoney)
        if hasMoney == true then
            TriggerEvent('notification', 'You paid 245, The mechanic is on the way', 1)
            TriggerEvent('menu:callMechanic')
        else
            TriggerEvent('notification', 'You dont have enough money', 2)
        end
    end, 245)
end)

RegisterNetEvent('vehicle:clean')
AddEventHandler('vehicle:clean', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = nil
    if not IsPedInAnyVehicle(ped, false) then vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71) end
        if DoesEntityExist(vehicle) then
        local finished = exports["taskbar"]:taskBar(5000,"Cleaning")
        if Vdist2(GetEntityCoords(PlayerPedId()), GetEntityCoords(vehicle)) < 5 then
            local playerped = PlayerPedId()
            local coordA = GetEntityCoords(playerped, 1)
            local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
            local targetVehicle = getVehicleInDirection(coordA, coordB)
            SetVehicleDirtLevel(targetVehicle,0)
        else
            TriggerEvent('notification', 'Where is the fucking vehicle??')
        end
    else
        TriggerEvent('notification', "No vehicle nearby.", 2) 
    end
end)