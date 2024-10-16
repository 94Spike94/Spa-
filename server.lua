-- Event-Handler für den /spaß Befehl
RegisterNetEvent('spass:triggerEvent')
AddEventHandler('spass:triggerEvent', function(event)
    local src = source
    TriggerClientEvent('spass:start', src, event)
end)
