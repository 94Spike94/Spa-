local isDrunk = false

-- Event-Handler für das zufällige Ereignis
RegisterNetEvent('spass:start')
AddEventHandler('spass:start', function(event)
    local playerPed = PlayerPedId()

    if event == 'drunk' then
        TriggerEvent('spass:makeDrunk')
    elseif event == 'fall' then
        TriggerEvent('spass:fallDown')
    elseif event == 'jump' then
        TriggerEvent('spass:jumpInAir')
    elseif event == 'teleport' then
        TriggerEvent('spass:teleportRandom')
    elseif event == 'car' then
        TriggerEvent('spass:carOnPlayer')
    elseif event == 'exit_vehicle' then
        TriggerEvent('spass:exitVehicle')
    end
end)

-- Betrunken-Event
RegisterNetEvent('spass:makeDrunk')
AddEventHandler('spass:makeDrunk', function()
    local playerPed = PlayerPedId()
    isDrunk = true
    RequestAnimSet("move_m@drunk@verydrunk")
    while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
        Citizen.Wait(100)
    end
    SetPedMovementClipset(playerPed, "move_m@drunk@verydrunk", true)
    ShakeGameplayCam("DRUNK_SHAKE", 1.0)

    -- Nach 30 Sekunden aufhören betrunken zu sein
    Citizen.Wait(30000)
    ClearTimecycleModifier()
    ResetPedMovementClipset(playerPed, 0)
    ShakeGameplayCam("DRUNK_SHAKE", 0.0)
    isDrunk = false
end)

-- Hinfallen-Event
RegisterNetEvent('spass:fallDown')
AddEventHandler('spass:fallDown', function()
    local playerPed = PlayerPedId()
    SetPedToRagdoll(playerPed, 5000, 5000, 0, true, true, false)
end)

-- Springen-Event
RegisterNetEvent('spass:jumpInAir')
AddEventHandler('spass:jumpInAir', function()
    local playerPed = PlayerPedId()
    SetPedToRagdoll(playerPed, 0, 0, 0, true, true, false)
    ApplyForceToEntity(playerPed, 1, 0, 0, 10.0, 0, 0, 0, true, true, true, true, true, true)
    
    -- Kein Fallschaden
    Citizen.CreateThread(function()
        while IsPedFalling(playerPed) do
            SetPedCanRagdoll(playerPed, false)
            Citizen.Wait(0)
        end
        Citizen.Wait(1000)
        SetPedCanRagdoll(playerPed, true)
    end)
end)

-- Teleportieren-Event
RegisterNetEvent('spass:teleportRandom')
AddEventHandler('spass:teleportRandom', function()
    local randomLoc = Config.TeleportLocations[math.random(#Config.TeleportLocations)]
    SetEntityCoords(PlayerPedId(), randomLoc.x, randomLoc.y, randomLoc.z)
end)

-- Auto auf den Spieler fallen lassen
RegisterNetEvent('spass:carOnPlayer')
AddEventHandler('spass:carOnPlayer', function()
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    
    local vehicleHash = GetHashKey('adder') -- Beispiel Auto
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Citizen.Wait(0)
    end
    
    local veh = CreateVehicle(vehicleHash, playerPos.x, playerPos.y, playerPos.z + 10.0, 0.0, true, false)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleOnGroundProperly(veh)
end)

-- Automatisch aussteigen lassen
RegisterNetEvent('spass:exitVehicle')
AddEventHandler('spass:exitVehicle', function()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        TaskLeaveVehicle(playerPed, GetVehiclePedIsIn(playerPed, false), 0)
    end
end)

-- Event, bei dem der Spieler durch die Gegend fliegt
RegisterNetEvent('spass:flyAround')
AddEventHandler('spass:flyAround', function()
    local playerPed = PlayerPedId()
    local flyingTime = 10000 -- Spieler fliegt für 10 Sekunden

    -- Die Schleife, die den Spieler für eine bestimmte Zeit zufällig durch die Gegend schleudert
    Citizen.CreateThread(function()
        local endTime = GetGameTimer() + flyingTime
        while GetGameTimer() < endTime do
            -- Zufällige Richtung und Geschwindigkeit
            local forceX = math.random(-10, 10)
            local forceY = math.random(-10, 10)
            local forceZ = math.random(5, 15)  -- Leichte Anhebung, damit der Spieler nicht nur horizontal fliegt

            -- Kraft auf den Spieler anwenden
            ApplyForceToEntity(playerPed, 1, forceX, forceY, forceZ, 0, 0, 0, true, true, true, true, true, true)
            
            -- Kleine Wartezeit zwischen den Kräften
            Citizen.Wait(100)
        end
    end)
end)

-- Command /spaß erweitert um das neue Event
RegisterCommand('spaß', function()
    local randomEvent = Config.RandomEvents[math.random(#Config.RandomEvents)]
    TriggerServerEvent('spass:triggerEvent', randomEvent)
end)