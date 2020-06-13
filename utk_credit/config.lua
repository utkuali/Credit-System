Config = {}
Config.logs = true -- DON'T SET FALSE OR IT WILL BREAK!
Config.dcname = "Credit Logger" -- logger name
Config.http = "" -- webhook url
Config.avatar = "" -- avatar url

Config.logo = "🟡 " -- logo on screen
Config.showcommand = "c-show" -- command to close on screen amount
Config.adminadd = "c-add" -- admin command to give coin
Config.adminremove = "c-remove" -- admin command to remove coin
Config.admincheck = "c-search" -- admin command to check coin amount of a player
Config.PlateNumbers = 4 -- number of plate numbers || Plakadaki rakam sayısı
Config.PlateLetters = 2 -- number of plate letters (max is 8 combined with both PlateNumbers and PlateLetters)
Config.platecolor = 2 -- plate type (0 = blue/white, 1 = yellow/black, 2 = yellow/blue, 3 = blue/white2, 4 = blue/white3, 5 = old)
Config.vehcolor = 53 -- vehicle color || This sets the vehicle color of the new vehicle, if you don't want a sepcific one search for "SetVehicleColours" function in client.lua and delete all
Config.Locations = { -- Locations and their functions
    {
        blip,
        blipname = "Credit Exchange",
        bliptype = 500,
        blipcolor = 5,
        x = 253.40, y = 220.57, z = 106.29,
        dst = 23,
        text = "[~g~E~w~] ~r~Credit~w~ Exchange",
        func = "OpenExchangeMenu" -- Menu function
    },
    {
        blip,
        blipname = "Vehicle Shop (Credit)",
        bliptype = 523,
        blipcolor = 5,
        x = 1224.63, y = 2726.59, z = 38.00,
        dst = 10,
        text = "[~g~E~w~] ~r~Credit~w~ Vehicle Shop",
        func = "OpenMarket",
        spawnloc = vector3(1244.27, 2714.02, 38.01), -- vehicle spawn loc
        heading = 90.40 -- vehicle heading
    },
    {
        enableblip = true,
        blip,
        blipname = "Black Market",
        bliptype = 567,
        blipcolor = 5,
        x = -1305.64, y = -394.02, z = 36.70,
        dst = 10,
        text = "[~g~E~w~] ~r~Bitcoin~w~ Weapon Shop",
        func = "OpenWepShop"
    },
    {
        enableblip = false,
        blip,
        blipname = "Black Market",
        bliptype = 500,
        blipcolor = 5,
        x = 253.40, y = 220.57, z = 106.29,
        dst = 23,
        text = "[~g~E~w~] Black Market",
        func = "OpenBlackMarket" -- Menu function
    },
}