local MugShots = {}
RegisterNetEvent('cqc-mugshot:server:triggerSuspect', function(suspect)
    TriggerClientEvent('cqc-mugshot:client:trigger', suspect, suspect)
end)

RegisterNetEvent('cqc-mugshot:server:MDTupload', function(citizenid, MugShotURLs)
    MugShots[citizenid] = MugShotURLs
end)