RegisterNetEvent('cqc-mugshot:server:suspectTakeMugShot', function(playerId)
    TriggerClientEvent('cqc-mugshot:client:trigger', playerId, playerId)
end)