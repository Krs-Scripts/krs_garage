lib.versionCheck('Krs-Scripts/krs_garage')


lib.callback.register('krs_garage:checkVehicles', function(source)
    local playerData = ESX.GetPlayerFromId(source)
    local identifier = playerData.identifier
    local garage = MySQL.query.await('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `stored` = 1', {
        identifier
    })
    -- print(json.encode(garage))
    return garage
end)


RegisterNetEvent('krs_garage:vehicleTakenOut', function(plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.update.await('UPDATE owned_vehicles SET stored = 0 WHERE plate = ? and (owner = ?)', { plate, xPlayer.identifier })
end)

local recentVehicles = {}

lib.callback.register('krs_garage:saveVehicle', function(source, props)

    local xPlayer = ESX.GetPlayerFromId(source)

    local vehicle = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ? and (owner = ?)', { props.plate, xPlayer.identifier })

    if #vehicle == 0 then
        return false
    end

    if json.decode(vehicle[1].vehicle).model == props.model then

        MySQL.update.await('UPDATE owned_vehicles SET stored = 1 WHERE plate = ?', { props.plate })
        MySQL.query.await("UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?", {json.encode(props), props.plate})

        recentVehicles[props.plate] = nil
        return true
    else
        print('Cheater is trying to change vehicle hash, identifier: ' .. xPlayer.identifier)
        return false
    end
end)

RegisterNetEvent('krs_garage:impoundVehicle', function(data)
    print(json.encode(data))
    local netID = data.netID
    local plate = data.plate
    local Vehicle = NetworkGetEntityFromNetworkId(netID)
    local stored = 2
    if DoesEntityExist(Vehicle) then
        DeleteEntity(Vehicle)
        local update, er = MySQL.update.await('UPDATE owned_vehicles SET stored = ? WHERE plate = ?', {
            stored, plate
        })
        if update then
            print('query inserita correttamente!')
        else
            print(er)
        end
    else
        print(string.format('vehicle with netID %s is Not Networked', netID))
    end
end)

RegisterNetEvent('krs_garage:impoundPayment', function(id, price, plate)
    local stored = 0
    local update, er = MySQL.update.await('UPDATE owned_vehicles SET stored = ? WHERE plate = ?', {
        stored, plate
    })
    if update then
        exports.ox_inventory:RemoveItem(id, 'money', price)
        print('query inserita correttamente!')
    else
        print(er)
    end
end)

lib.callback.register('krs_garage:getVehicleImpound', function(source)
    local playerData = ESX.GetPlayerFromId(source)
    local identifier = playerData.identifier
    local impound = MySQL.query.await('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `stored` = 2', {
        identifier
    })
    -- print(json.encode(impound))
    return impound
end)
