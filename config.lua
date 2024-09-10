lib.locale()

Config = {}

Config.Garages = {
    ['garage1'] = {
        Type = 'normal',
        Position = vector3(215.9122, -810.0616, 29.7258),
        SpawnPosition = vector4(229.3425, -801.4708, 30.5659, 161.8591),
        DepositVehicle = vector3(216.0801, -787.4680, 29.8257),
        Blip = {name = 'Car Garage', sprite = 357, color = 0, scale = 0.6},
    },
    ['garage2'] = {
        Type = 'aircraft',
        Position = vector3(-1024.9668, -3016.8762, 12.9451),
        SpawnPosition = vector4(-1006.1460, -3015.9568, 13.9451, 62.2137),
        DepositVehicle = vector3(-1002.7515, -2984.7158, 12.9451),
        Blip = {name = 'Air Garage', sprite = 64, color = 2, scale = 0.8},
    },
    ['garage3'] = {
        Type = 'boat',
        Position = vector3(-798.1291, -1419.4056, 0.5952),
        SpawnPosition = vector4(-292.7704, -886.2692, 31.0806, 172.8078),
        DepositVehicle = vector3(-302.8555, -891.6354, 30.0806),
        Blip = {name = 'Boat Garage', sprite = 356, color = 4, scale = 0.8},
    },   
}

Config.ImpoundPrice = 1000

Config.Impounds = {
    ['impound1'] = {
        Type = 'normal',
        Position = vector3(409.5571, -1623.4252, 28.2920),
        SpawnPosition = vector4(401.3035, -1648.2150, 29.2926, 317.1598),
        Blip = {name = 'Vehicle Impound', sprite = 50, color = 1, scale = 0.6},
    },
    ['impound2'] = {
        Type = 'aircraft',
        Position = vector3(-942.0450, -2955.9194, 12.9451),
        SpawnPosition = vector4(-979.5931, -2996.7217, 13.9451, 51.3964),
        Blip = {name = 'Aircraft Impound', sprite = 64, color = 1, scale = 0.8},
    },
    ['impound3'] = {
        Type = 'boat',
        Position = vector3(-844.4507, -1367.0062, 0.6052),
        SpawnPosition = vector4(-846.5288, -1362.6864, -0.4748, 111.0968),
        Blip = {name = 'Boat Impound', sprite = 404, color = 1, scale = 0.8},
    },
}
