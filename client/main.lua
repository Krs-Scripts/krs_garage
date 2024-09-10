
local function GetVehicleTypeFromModel(model)
    local vehicleClass = GetVehicleClassFromName(model)
    if vehicleClass == 15 or vehicleClass == 16 then
        return 'aircraft'
    elseif vehicleClass == 14 then
        return 'boat'
    else
        return 'normal'
    end
end


local function saveVehicle()
    local playerPed = cache.ped
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local props = lib.getVehicleProperties(vehicle)

    lib.callback('krs_garage:saveVehicle', false, function(success)
        if success then
            TaskLeaveVehicle(playerPed, vehicle, 0)
            Wait(1000)
            DeleteEntity(vehicle)
            lib.notify({
                id = 'some_identifier',
                title = locale('title_notify'),
                description = locale('description_deposit_notify'),
                position = 'top',
                style = {
                    backgroundColor = '#141517',
                    color = '#C1C2C5',
                    ['.description'] = {
                        color = '#909296'
                    }
                },
                icon = 'fa-solid fa-warehouse', 
                iconColor = '#F8F9FA'
            })
        else
            lib.notify({
                id = 'some_identifier',
                title = locale('title_notify'),
                description = locale('description_notproperty_notify'),
                position = 'top',
                style = {
                    backgroundColor = '#141517',
                    color = '#C1C2C5',
                    ['.description'] = {
                        color = '#909296'
                    }
                },
                icon = 'fa-solid fa-warehouse', 
                iconColor = '#FA5252'
            })
        end
    end, props)
end


local function SpawnVehicle(props, garageID)
    local garage = Config.Garages[garageID]
    local model = lib.requestModel(props.model)
    if not model then return end

    local vehicle = CreateVehicle(model, garage.SpawnPosition.x, garage.SpawnPosition.y, garage.SpawnPosition.z, garage.SpawnPosition.w, true, false)
    SetVehicleFuelLevel(vehicle, 100.0)
    SetModelAsNoLongerNeeded(model)
    NetworkFadeInEntity(vehicle, 1)
    lib.setVehicleProperties(vehicle, props)
    TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
    TriggerServerEvent('krs_garage:vehicleTakenOut', props.plate)
    
    lib.notify({
        id = 'some_identifier',
        title = locale('title_notify'),
        description = locale('description_taken_notify'),
        position = 'top',
        style = {
            backgroundColor = '#141517',
            color = '#C1C2C5',
            ['.description'] = {
                color = '#909296'
            }
        },
        icon = 'fa-solid fa-warehouse', 
        iconColor = '#F8F9FA'
    })
end


local function SpawnVehicleImpound(props, impoundID)
    local money = exports.ox_inventory:Search('count', 'money')
    local impoundPrice = Config.ImpoundPrice
    if money <= impoundPrice then
        print('You don\'t have enough money.')
        return 
    end

    local model = lib.requestModel(props.model)
    if not model then return end

    local vehicleClass = GetVehicleClassFromName(model)
    local vehicleType = vehicleClass == 16 and "aircraft" or vehicleClass == 15 and "aircraft" or vehicleClass == 14 and "boat" or "normal"

    local impound = Config.Impounds[impoundID]
    if impound.Type == vehicleType then
        local vehicle = CreateVehicle(model, impound.SpawnPosition.x, impound.SpawnPosition.y, impound.SpawnPosition.z, impound.SpawnPosition.w, true, false)
        SetVehicleFuelLevel(vehicle, 100.0)
        SetModelAsNoLongerNeeded(model)
        NetworkFadeInEntity(vehicle, 1)
        lib.setVehicleProperties(vehicle, props)
        TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
        TriggerServerEvent('krs_garage:impoundPayment', cache.serverId, impoundPrice, props.plate)
    end
end

local function createBlips()
   
    for k, garage in pairs(Config.Garages) do
        local blip = AddBlipForCoord(garage.Position.x, garage.Position.y, garage.Position.z)
        SetBlipSprite(blip, garage.Blip.sprite)
        SetBlipColour(blip, garage.Blip.color)
        SetBlipScale(blip, garage.Blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(garage.Blip.name)
        EndTextCommandSetBlipName(blip)
    end
   
    for k, impound in pairs(Config.Impounds) do
        local blip = AddBlipForCoord(impound.Position.x, impound.Position.y, impound.Position.z)
        SetBlipSprite(blip, impound.Blip.sprite)
        SetBlipColour(blip, impound.Blip.color)
        SetBlipScale(blip, impound.Blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(impound.Blip.name)
        EndTextCommandSetBlipName(blip)
    end
end


local ProgressColor = {
    GREEN = 'green.5',
    YELLOW = 'yellow.5',
    RED = 'red.5'
}

---@param percent number
---@return string
local function getProgressColor(percent)
    if percent >= 75 then
        return ProgressColor.GREEN
    elseif percent > 25 then
        return ProgressColor.YELLOW
    else
        return ProgressColor.RED
    end
end

local function OpenGarage(garageID)
    local vehicleData = lib.callback.await('krs_garage:checkVehicles', 100)
    local elements = {}
    local garageData = Config.Garages[garageID]

    for _, v in ipairs(vehicleData) do
        local props = json.decode(v.vehicle)
        local vehicleType = GetVehicleTypeFromModel(props.model)

        if garageData.Type == vehicleType then
            local label = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
            if label == 'NULL' then
                label = GetDisplayNameFromVehicleModel(props.model)
            end

            local engineHealth = props.engineHealth or 100 
            local bodyHealth = props.bodyHealth or 100 
            local fuelLevel = props.fuelLevel or 100 

            local engine = ESX.Math.Round(engineHealth / 10, 0) 
            local body = ESX.Math.Round(bodyHealth / 10, 0) 
            local fuel = ESX.Math.Round(fuelLevel, 0) 

            -- Get color based on value
            local engineColor = getProgressColor(engine)
            local bodyColor = getProgressColor(body)
            local fuelColor = getProgressColor(fuel)

            local status = v.stored == 1 and locale('inside_the_garage') or locale('out_of_the_garage')
            local iconVehicle

            if vehicleType == 'aircraft' then 
                iconVehicle = 'fa-solid fa-plane'
            elseif vehicleType == 'boat' then
                iconVehicle = 'fa-solid fa-sailboat'
            elseif vehicleType == 'normal' then
                iconVehicle = 'fa-solid fa-car'
            end

            table.insert(elements, {
                title = locale('model_vehicles') .. ' ' .. label,
                description = string.format(locale('fuel_level'), fuel)..'%',
                progress = fuel or 0,
                colorScheme = fuelColor,
                icon = iconVehicle,
                iconAnimation = 'bounce',
                metadata = { 
                    { label = locale('status_vehicles'), value = status },
                    { label = locale('plate_vehicles'), value = props.plate },
                    { label = locale('body_health'), value = body, color = bodyColor, progress = body }, 
                    { label = locale('engine_health'), value = engine, color = engineColor, progress = engine }, 
                },
                args = props,
                onSelect = function()
                    SpawnVehicle(props, garageID)
                end,
            })
        end
    end

    lib.registerContext({
        id = 'garage',
        title = locale('title_menu_garages'),
        options = elements,
    })

    lib.showContext('garage')
end

local function OpenImpound(impoundID)
    local vehicleData = lib.callback.await('krs_garage:getVehicleImpound', 100)
    print(json.encode(vehicleData, {indent = true}))

    local elements = {}

    for _, v in ipairs(vehicleData) do
        local props = json.decode(v.vehicle)
        
        local label = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
        if label == 'NULL' then 
            label = GetDisplayNameFromVehicleModel(props.model)
        end

        local engineHealth = props.engineHealth or 100 
        local bodyHealth = props.bodyHealth or 100 
        local fuelLevel = props.fuelLevel or 100 

        local engine = ESX.Math.Round(engineHealth / 10, 0) 
        local body = ESX.Math.Round(bodyHealth / 10, 0) 
        local fuel = ESX.Math.Round(fuelLevel, 0) 

        local engineColor = getProgressColor(engine)
        local bodyColor = getProgressColor(body)
        local fuelColor = getProgressColor(fuel)

        local status = v.stored == 2 and locale('vehicle_seized') or locale('vehicle_not_seized')

        table.insert(elements, {
            title = locale('model_vehicles') .. ' ' .. label,
            description = string.format(locale('fuel_level'), fuel)..'%',
            progress = fuel or 0,
            colorScheme = fuelColor,
            icon = 'fa-solid fa-car',
            iconAnimation = 'beatFade',
            metadata = { 
                { label = locale('status_vehicles'), value = status },
                { label = locale('plate_vehicles'), value = props.plate },
                { label = locale('body_health'), value = body, color = bodyColor, progress = body }, 
                { label = locale('engine_health'), value = engine, color = engineColor, progress = engine }, 
                { label = locale('price_impounds'), value = Config.ImpoundPrice },
            },
            args = props,
            onSelect = function()
                SpawnVehicleImpound(props, impoundID)
                lib.notify({
                    id = 'some_identifier',
                    title = locale('title_notify'),
                    description = locale('picked_impounds_paid') .. Config.ImpoundPrice,
                    position = 'top',
                    style = {
                        backgroundColor = '#141517',
                        color = '#C1C2C5',
                        ['.description'] = {
                            color = '#909296'
                        }
                    },
                    icon = 'fa-solid fa-warehouse',
                    iconColor = '#F8F9FA'
                })
            end,
        })
    end

    lib.registerContext({
        id = 'impound',
        title = locale('title_menu_impounds'),
        options = elements,
    })
    lib.showContext('impound')
end

createBlips()


exports.ox_target:addGlobalVehicle({
	
    {
        icon = 'fa-solid fa-key',
        label = 'Seize the vehicle',
        groups = {'mechanic', 1},
        onSelect = function(data)
            print(json.encode(data))
            local vehicle = data.entity
            local plate = lib.getVehicleProperties(vehicle).plate
            local netID = NetworkGetNetworkIdFromEntity(vehicle)
            local vehicleData = {
                plate = plate,
                netID = netID
            }
            print(plate)
            TriggerServerEvent('krs_garage:impoundVehicle', vehicleData)
        end
    },
})


for k, v in pairs(Config.Garages) do
    lib.zones.sphere({
        coords = v.Position,
        spawn = v.SpawnPosition,
        size = vec3(1.6, 1.4, 3.2),
        rotation = 346.25,
        debug = false,
        onExit = function()
            lib.hideTextUI()
        end,
        onEnter = function ()
        lib.showTextUI(locale('open_garages'), {
            position = "right-center",
            icon = 'fa-solid fa-square-parking',
            style = {
                borderRadius = 5,
                backgroundColor = '#25262B',
                color = 'white'
            }
        })
        end,
        inside = function()
            if IsControlJustReleased(0, 38) then
                OpenGarage(k)
            end
        end,
    })
end

for k, v in pairs(Config.Impounds) do
    lib.zones.sphere({
        coords = v.Position,
        spawn = v.SpawnPosition,
        size = vec3(1.6, 1.4, 3.2),
        rotation = 346.25,
        debug = false,
        onExit = function()
            lib.hideTextUI()
        end,
        onEnter = function ()
        lib.showTextUI(locale('open_impounds'), {
            position = "right-center",
            icon = 'fa-solid fa-warehouse', 
            style = {
                borderRadius = 5,
                backgroundColor = '#25262B',
                color = 'white'
            }
        })
        end,
        inside = function()
            if IsControlJustReleased(0, 38) then
                OpenImpound(k)
            end
        end,
    })
end
    
for k, v in pairs(Config.Garages) do
    lib.zones.sphere({
        coords = v.DepositVehicle,
        size = vec3(1.6, 1.4, 3.2),
        rotation = 346.25,
        debug = false,
        onExit = function()
            lib.hideTextUI()
        end,
        onEnter = function ()
        lib.showTextUI(locale('save_vehicles'), {
            position = "right-center",
            icon = 'fa-solid fa-square-parking',
            style = {
                borderRadius = 5,
                backgroundColor = '#25262B',
                color = 'white'
            }
        })
        end,
        inside = function()
            if IsControlJustReleased(0, 38) then
                saveVehicle()
            end
        end,
    })
end