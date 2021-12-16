ESX = nil   
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

local isJudge = false
local isPolice = false
local isMedic = false
local isDoctor = false
local isNews = false
local isDead = false
local isInstructorMode = false
local myJob = "unemployed"
local isHandcuffed = false
local isHandcuffedAndWalking = false
local hasOxygenTankOn = false
local gangNum = 0
local cuffStates = {}


rootMenuConfig =  {
    

    {
        id = "general",
        displayName = "Generelt",
        icon = "#globe-europe",
        enableMenu = function()
            return not isDead
        end,
        subMenus = {"general:emotes", "general:bills", 'cuffing:searchDeath'}
    },

 

    {
        id = "animations",
        displayName = "Animationer",
        icon = "#walking",
        enableMenu = function()
            return not isDead
        end,
        subMenus = { "animations:brave", "animations:hurry", "animations:business", "animations:tipsy", "animations:injured","animations:tough", "animations:default", "animations:hobo", "animations:money", "animations:swagger", "animations:shady", "animations:maneater", "animations:chichi", "animations:sassy", "animations:sad", "animations:posh", "animations:alien" }
    },

    {
        id = "expressions",
        displayName = "Ansigts Udtryk",
        icon = "#expressions",
        enableMenu = function()
            return not isDead
        end,
        subMenus = { "expressions:normal", "expressions:drunk", "expressions:angry", "expressions:dumb", "expressions:electrocuted", "expressions:grumpy", "expressions:happy", "expressions:injured", "expressions:joyful", "expressions:mouthbreather", "expressions:oneeye", "expressions:shocked", "expressions:sleeping", "expressions:smug", "expressions:speculative", "expressions:stressed", "expressions:sulking", "expressions:weird", "expressions:weird2"}
    },

    {
        id = "mechanic",
        displayName = "Mekaniker",
        icon = "#mechanic",
        enableMenu =function()
            local Data = ESX.GetPlayerData()
            return (not isDead and Data.job ~= nil and (Data.job.name == "mechanic" or Data.job.name == "tuner"))
        end,
        subMenus = { "police:impound", "mechanic:bill", "mechanic:repair","mechanic:hijack" }
    },

    {
        id = "police",
        displayName = "Politi",
        icon = "#police",
        enableMenu =function()
            local Data = ESX.GetPlayerData()
            return (not isDead and Data.job ~= nil and Data.job.name == "police" or Data.job.name == "ambulance")
        end,
        subMenus = { "police:bill", "police:putinvehicle", "police:outofvehicle", "police:impound", "police:cuff", "police:uncuff", "police:drag", "mechanic:hijack"}
    },
    
    {
        id = "police-check",
        displayName = "Politi Oplysninger",
        icon = "#police-check",
        enableMenu = function()
            local Data = ESX.GetPlayerData()
            return (not isDead and Data.job ~= nil and Data.job.name == "police")
        end,
        subMenus = {"police:checkbank", "police:search", 'police:mdt', "police:bills", "police:cone", "police:barier", "police:light", 'police:deleteObject' }
    },

    {
        id = "gang",
        displayName = 'Mafia',
        icon = "#gang",
        enableMenu =function()
            local Data = ESX.GetPlayerData()
            return (not isDead and Data.job ~= nil and (Data.job.name == "biton" or Data.job.name == "peaky" or Data.job.name == "bloods" or Data.job.name == "blackmarket" ))
        end,
        subMenus = { "police:putinvehicle", "police:outofvehicle",  "police:cuff", "police:uncuff", "police:drag","mechanic:hijack", "cuffing:steal"}
    },

    --[[{
        id = "police-objects",
        displayName = "Police Objects",
        icon = "#police-objects",
        enableMenu =function()
            local Data = ESX.GetPlayerData()
            return (not isDead and Data.job ~= nil and Data.job.name == "police")
        end,
        subMenus = { "police:cone", "police:barier", "police:light", 'police:deleteObject'}
    },]]--


    {
        id = "sell_vehicle",
        displayName = "Sælg Køretøj",
        icon = "#vehicle-sell",
        enableMenu =function()
            return (not isDead and IsPedInAnyVehicle(PlayerPedId()))
        end,
        functionName = "MF_VehSales:SellCar"
    },


    {
        id = "ems",
        displayName = "Læge",
        icon = "#ems-ambulance",
        enableMenu = function()
            local Data = ESX.GetPlayerData()
            return (not isDead and Data.job ~= nil and Data.job.name == "ambulance")
        end,
        subMenus = { "ems:bill", "ems:revive", 'ems:heal', "police:putinvehicle", "police:outofvehicle", 'police:drag'  }
    }
}

newSubMenus = {
    ['general:emotes'] = {
        title = "Emotes",
        icon = "#emotes",
        functionName = "emotes:OpenMenu"
    },

    ['general:bills'] = {
        title = "Fakture",
        icon = "#police-bills",
        functionName = "esx_billing:openMenu"
    },

    -- Cuff
    ['cuffing:searchDeath'] = {
        title = "Håndjern",
        icon = "#cuffs-rob",
        functionName = "robPlayer",
    },

    ['cuffing:drag'] = {
        title = "Drag person",
        icon = "#cuffs-drag",
        enableMenu = function()
            local Data = ESX.GetPlayerData()
            return (not isDead and Data.job ~= nil and Data.job.name ~= "ambulance" and Data.job.name ~= "police" and not IsPedInAnyVehicle(ped, true))
        end,
        functionName = "police:client:GetEscorted",
    },

    ['cuffing:steal'] = {
        title = "Røv person",
        icon = "#cuffs-steal",
        functionName = "robPlayer",
    },

    ['cuffing:cuff'] = {
        title = "Strips",
        icon = "#cuffs-cuff",
        enableMenu = function()
            local Data = ESX.GetPlayerData()
            return (not isDead and Data.job ~= nil and Data.job.name ~= "ambulance" and Data.job.name ~= "police" and not IsPedInAnyVehicle(ped, true))
        end,
        functionName = "police:client:CuffPlayer",
    },

    ['cuffing:uncuff'] = {
        title = "Håndjern af",
        icon = "#cuffs-uncuff",
        enableMenu = function()
            local Data = ESX.GetPlayerData()
            return (not isDead and Data.job ~= nil and Data.job.name ~= "ambulance" and Data.job.name ~= "police" and not IsPedInAnyVehicle(ped, true))
        end,
        functionName = "police:client:UnCuffPlayer",
    },

    --------------------------------------
    ['animations:brave'] = {
        title = "Stolt",
        icon = "#animation-brave",
        functionName = "AnimSet:Brave"
    },

    ['animations:hurry'] = {
        title = "Skynd dig",
        icon = "#animation-hurry",
        functionName = "AnimSet:Hurry"
    },

    ['animations:business'] = {
        title = "Buisness",
        icon = "#animation-business",
        functionName = "AnimSet:Business"
    },

    ['animations:tipsy'] = {
        title = "Fuld",
        icon = "#animation-tipsy",
        functionName = "AnimSet:Tipsy"
    },

    ['animations:injured'] = {
        title = "Skadet",
        icon = "#animation-injured",
        functionName = "AnimSet:Injured"
    },

    ['animations:tough'] = {
        title = "Sej/stor",
        icon = "#animation-tough",
        functionName = "AnimSet:ToughGuy"
    },

    ['animations:sassy'] = {
        title = "Sassy",
        icon = "#animation-sassy",
        functionName = "AnimSet:Sassy"
    },

    ['animations:sad'] = {
        title = "ked af det",
        icon = "#animation-sad",
        functionName = "AnimSet:Sad"
    },

    ['animations:posh'] = {
        title = "Posh",
        icon = "#animation-posh",
        functionName = "AnimSet:Posh"
    },

    ['animations:alien'] = {
        title = "Alien",
        icon = "#animation-alien",
        functionName = "AnimSet:Alien"
    },

    ['animations:nonchalant'] = {
        title = "Non Chalant",
        icon = "#animation-nonchalant",
        functionName = "AnimSet:NonChalant"
    },

    ['animations:hobo'] = {
        title = "Hobo",
        icon = "#animation-hobo",
        functionName = "AnimSet:Hobo"
    },

    ['animations:money'] = {
        title = "Money",
        icon = "#animation-money",
        functionName = "AnimSet:Money"
    },

    ['animations:swagger'] = {
        title = "Swagger",
        icon = "#animation-swagger",
        functionName = "AnimSet:Swagger"
    },

    ['animations:shady'] = {
        title = "Shady",
        icon = "#animation-shady",
        functionName = "AnimSet:Shady"
    },

    ['animations:maneater'] = {
        title = "Man Eater",
        icon = "#animation-maneater",
        functionName = "AnimSet:ManEater"
    },

    ['animations:chichi'] = {
        title = "ChiChi",
        icon = "#animation-chichi",
        functionName = "AnimSet:ChiChi"
    },

    ['animations:default'] = {
        title = "Standard",
        icon = "#animation-default",
        functionName = "AnimSet:default"
    },

    ["expressions:angry"] = {
        title="Sur",
        icon="#expressions-angry",
        functionName = "expressions",
        functionParameters =  { "mood_angry_1" }
    },

    ["expressions:drunk"] = {
        title="Fuld",
        icon="#expressions-drunk",
        functionName = "expressions",
        functionParameters =  { "mood_drunk_1" }
    },

    ["expressions:dumb"] = {
        title="Dum",
        icon="#expressions-dumb",
        functionName = "expressions",
        functionParameters =  { "pose_injured_1" }
    },

    ["expressions:electrocuted"] = {
        title="electrocuted",
        icon="#expressions-electrocuted",
        functionName = "expressions",
        functionParameters =  { "electrocuted_1" }
    },

    ["expressions:grumpy"] = {
        title="Grumpy",
        icon="#expressions-grumpy",
        functionName = "expressions", 
        functionParameters =  { "mood_drivefast_1" }
    },

    ["expressions:happy"] = {
        title="Glad",
        icon="#expressions-happy",
        functionName = "expressions",
        functionParameters =  { "mood_happy_1" }
    },

    ["expressions:injured"] = {
        title="Skadet",
        icon="#expressions-injured",
        functionName = "expressions",
        functionParameters =  { "mood_injured_1" }
    },

    ["expressions:joyful"] = {
        title="Joyful",
        icon="#expressions-joyful",
        functionName = "expressions",
        functionParameters =  { "mood_dancing_low_1" }
    },

    ["expressions:mouthbreather"] = {
        title="Alkohol Test",
        icon="#expressions-mouthbreather",
        functionName = "expressions",
        functionParameters = { "smoking_hold_1" }
    },

    ["expressions:normal"]  = {
        title="Normal",
        icon="#expressions-normal",
        functionName = "expressions:clear"
    },

    ["expressions:oneeye"]  = {
        title="Et øje",
        icon="#expressions-oneeye",
        functionName = "expressions",
        functionParameters = { "pose_aiming_1" }
    },

    ["expressions:shocked"]  = {
        title="Chokeret",
        icon="#expressions-shocked",
        functionName = "expressions",
        functionParameters = { "shocked_1" }
    },

    ["expressions:sleeping"]  = {
        title="Sover",
        icon="#expressions-sleeping",
        functionName = "expressions",
        functionParameters = { "dead_1" }
    },

    ["expressions:smug"]  = {
        title="Smug",
        icon="#expressions-smug",
        functionName = "expressions",
        functionParameters = { "mood_smug_1" }
    },

    ["expressions:speculative"]  = {
        title="Spetakuleret",
        icon="#expressions-speculative",
        functionName = "expressions",
        functionParameters = { "mood_aiming_1" }
    },

    ["expressions:stressed"]  = {
        title="Stresset",
        icon="#expressions-stressed",
        functionName = "expressions",
        functionParameters = { "mood_stressed_1" }
    },

    ["expressions:sulking"]  = {
        title="Sulking",
        icon="#expressions-sulking",
        functionName = "expressions",
        functionParameters = { "mood_sulk_1" },
    },

    ["expressions:weird"]  = {
        title="Underlig",
        icon="#expressions-weird",
        functionName = "expressions",
        functionParameters = { "effort_2" }
    },

    ["expressions:weird2"]  = {
        title="Underlig 2",
        icon="#expressions-weird2",
        functionName = "expressions",
        functionParameters = { "effort_3" }
     },    


    --------------------------------------
    ["emotes:smoke"] = {
        title = "Ryger",
        icon = "#emotes-smoke",
        functionName = 'menu:dpemotes:cmd',
        functionParameters =  { "emote" ,"smoke" }
    },

    ["emotes:lean"] = {
        title = "Læng",
        icon = "#emotes-lean",
        functionName = 'menu:dpemotes:cmd',
        functionParameters =  { "emote" ,"lean" }
    },

    ["emotes:sitchair"] = {
        title = "Sid på stol",
        icon = "#emotes-sitchair",
        functionName = 'menu:dpemotes:cmd',
        functionParameters =  { "emote" ,"sitchair" }
    },

    ["emotes:dance"] = {
        title = "Danse",
        icon = "#emotes-dance",
        functionName = 'menu:dpemotes:cmd',
        functionParameters =  { "dance" ,"dance" }
    },
   
    ["emotes:surr"] = {
        title = "Overgiver sig",
        icon = "#emotes-surr",
        functionName = 'menu:dpemotes:cmd',
        functionParameters =  { "emote" , "surrender" }
    },

    --------------------------------------

    ['vehicle:callMechanic'] = {
        title = "Ring efter mekaniker",
        icon = "#vehicle-callmec",
        functionName = "menu:general:callmechanic"
    },

    ['vehicle:engine'] = {
        title = "Motor",
        icon = "#vehicle-engine",
        functionName = "menu:hotwire:openOwner"
    },

    ['vehicle:search'] = {
        title = "Søg i køretøj",
        icon = "#vehicle-search",
        enableMenu = function()
            local Data = ESX.GetPlayerData()
            return (not isDead and Data.job ~= nil and Data.job.name ~= "ambulance" and Data.job.name ~= "police")
        end,
        functionName = "menu:hotwire",
        functionParameters =  { "search" }
    },

    ['vehicle:hotwire'] = {
        title = "Hotwire bil",
        icon = "#vehicle-hotw",
        enableMenu = function()
            local Data = ESX.GetPlayerData()
            return (not isDead and Data.job ~= nil and Data.job.name ~= "ambulance" and Data.job.name ~= "police")
        end,
        functionName = "menu:hotwire",
        functionParameters =  { "hotw" }
    },

    --------------------------------------
    
    ['police:cone'] = {
        title = "sæt kegler",
        icon = "#object-cone",
        functionName = "police:client:spawnCone",
    },
    
    ['police:barier'] = {
        title = "Sæt Barrier",
        icon = "#police",
        functionName = 'police:client:spawnBarier',
    },
    
    ['police:light'] = {
        title = "Sæt lys",
        icon = "#object-light",
        functionName = "police:client:spawnLight",
    },
        
    ['police:deleteObject'] = {
        title = "Fjern Objekt",
        icon = "#object-delete",
        functionName = "police:client:deleteObject",
    },

    ['police:search'] = {
        title = "Visiter",
        icon = "#police-search",
        functionName = "YM:policerob",
    },
    ['police:checkbank'] = {
        title = "Check bank",
        icon = "#police-check-bank",
        functionName = "police:client:checkBank"
    },
    ['police:impound'] = {
        title = "Impound køretøj",
        icon = "#police-jail",
        functionName = "impound"
    },

    ['police:bill'] = {
        title = "Bøder",
        icon = "#ems-bill",
        functionName = "police:client:fineMenu",
    },

    ['police:bills'] = {
        title = "Giv bøde",
        icon = "#police-bills",
        functionName = "police:client:finesMenu",
    },

    ['police:cuff'] = {
        title = "Sæt blødt i håndjern",
        icon = "#police-cuff",
        functionName = "police:client:CuffPlayerSoft"
    },

    ['police:uncuff'] = {
        title = "Tag håndjern af",
        icon = "#police-uncuff",
        functionName = "police:client:UnCuffPlayer"
    },

    ['police:mdt'] = {
        title = "Tablet (kommer)",
        icon = "#police-mdt",
        functionName = "mdt:Open"
    },

    ['police:putinvehicle'] = {
        title = "Sæt i køretøj",
        icon = "#general-put-in-veh",
        functionName = "police:client:PutPlayerInVehicle",
    },

    ['police:outofvehicle'] = {
        title = "Tag ud af køretøj",
        icon = "#general-unseat-nearest",
        functionName = "police:client:SetPlayerOutVehicle",
    },

    ['police:drag'] = {
        title = "Drag person",
        icon = "#police-drag",
        functionName = "police:client:EscortPlayer",
    },

    --------------------------------------

    ['ems:bill'] = {
        title = "Fakture",
        icon = "#ems-bill",
        functionName = "menu:ems",
        functionParameters =  { "bill" }
    },

    ['ems:revive'] = {
        title = "Genopliv",
        icon = "#ems-revive",
        functionName = "menu:ems",
        functionParameters =  { "revive" }
    },

    ['ems:heal'] = {
        title = "Helbred",
        icon = "#ems-heal",
        functionName = "menu:ems",
        functionParameters =  { "heal" }
    },

    ['ems:drag'] = {
        title = "Tag fat i person",
        icon = "#ems-drag",
        functionName = "Carry:Event"
    },

    ['ems:med'] = {
        title = "Tjek vitaler",
        icon = "#ems-heal",
        functionName = "menu:ems",
        functionParameters =  { "medsystem" }
    },

    ['ems:putinvehicle'] = {
        title = "Sæt i køretøj",
        icon = "#ems-putinveh",
        functionName = "menu:ems",
        functionParameters =  { "piv" }
    },

    --------------------------------------
	['news:boom'] = {
        title = "Boom",
        icon = "#news-boom",
        functionName = "Mic:ToggleBMic"
    },

    ['news:cam'] = {
        title = "Camera",
        icon = "#news-cam",
        functionName = "Cam:ToggleCam"
    },

    ['news:mic'] = {
        title = "Mikrofon",
        icon = "#news-mic",
        functionName = "Mic:ToggleMic"
    },


    --------------------------------------
    ["mechanic:bill"] = {
        title = "Fakture",
        icon = "#ems-bill",
        functionName = "mechanic:bill"
    },

    ["mechanic:lookupvehicle"] = {
        title = "Tjek køretøj",
        icon = "#general-search",
        functionName = "menu:police:lookupvehicle"
    },

    ["mechanic:hijack"] = {
        title = "Lås køretøj op",
        icon = "#mechanic-hijack",
        functionName = "mechanic:onHijack",
    },

    ["mechanic:repair"] = {
        title = "Reparer Bil",
        icon = "#mechanic-repair",
        functionName = "mechanic:repair"
    },

    ["mechanic:wash"] = {
        title = "Vask bilen",
        icon = "#mechanic-wash",
        functionName = "mechanic:clean"
    },

    ["mechanic:impound"] = {
        title = "Impound køretøj",
        icon = "#mechanic-impound",
        functionName = "menu:impound"
    },

    ["mechanic:flatbed"] = {
        title = "sæt på lad",
        icon = "#mechanic-flatbed",
        functionName = "mechanic:towuntow"
    },

    --------------------------------------
    ["accessories:mask"] = {
        title = "Maske",
        icon = "#accessories-mask",
        functionName = 'esx_accessories:SetUnsetAccessory',
        functionParameters =  { "Mask" }
    },

    ["accessories:glasses"] = {
        title = "Briller",
        icon = "#accessories-glasses",
        functionName = 'esx_accessories:SetUnsetAccessory',
        functionParameters =  { "Glasses" }
    },

    ["accessories:helmet"] = {
        title = "Hjelm",
        icon = "#accessories-helmet",
        functionName = 'esx_accessories:SetUnsetAccessory',
        functionParameters =  { "Helmet" }
    },

    ["accessories:ears"] = {
        title = "אוזניים",
        icon = "#accessories-ears",
        functionName = 'esx_accessories:SetUnsetAccessory',
        functionParameters =  { "Ears" }
    }
}


function GetPlayers()
    local players = {}

    for i = 0, 32 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local closestPed = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        for index,value in ipairs(players) do
            local target = GetPlayerPed(value)
            if(target ~= ply) then
                local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
                local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
                if(closestDistance == -1 or closestDistance > distance) and not IsPedInAnyVehicle(target, false) then
                    closestPlayer = value
                    closestPed = target
                    closestDistance = distance
                end
            end
        end
        return closestPlayer, closestDistance, closestPed
    end
end

