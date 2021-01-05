ESX = nil

Enableshow = false
CloseForNow = false
Testvehicle = nil
local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end
GeneratePlate = function() local generatedPlate local doBreak = false while true do Citizen.Wait(2) math.randomseed(GetGameTimer()) generatedPlate = string.upper(GetRandomLetter(Config.PlateLetters) .. ' ' .. GetRandomNumber(Config.PlateNumbers)) ESX.TriggerServerCallback('esx_vehicleshop:isPlateTaken', function (isPlateTaken) if not isPlateTaken then doBreak = true end end, generatedPlate) if doBreak then break end end return generatedPlate end
IsPlateTaken = function(plate) local callback = 'waiting' ESX.TriggerServerCallback('utk_c:platecheck', function(isPlateTaken) callback = isPlateTaken end, plate) while type(callback) == 'string' do Citizen.Wait(0) end return callback end
GetRandomNumber = function(length) Citizen.Wait(1) math.randomseed(GetGameTimer()) if length > 0 then return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)] else return '' end end
GetRandomLetter = function(length) Citizen.Wait(1) math.randomseed(GetGameTimer()) if length > 0 then return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)] else return '' end end
Citizen.CreateThread(function() while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) end end)
RegisterNetEvent("utk_c:playerfound")
AddEventHandler("utk_c:playerfound", function()
    ESX.TriggerServerCallback("utk_c:getcredit", function(output)
        Credit = tonumber(output)
        Enableshow = true
    end)
end)

RegisterNetEvent("utk_c:creditfeed")
AddEventHandler("utk_c:creditfeed", function(amount)
    Credit = amount
end)

Citizen.CreateThread(function() -- menu locations and markers
    while true do
        local coords = GetEntityCoords(PlayerPedId())

        for i = 1, #Config.Locations, 1 do
            local dst = GetDistanceBetweenCoords(coords, Config.Locations[i].x, Config.Locations[i].y, Config.Locations[i].z, true)
            if dst <= Config.Locations[i].dst and not CloseForNow then
                DrawText3D(Config.Locations[i].x, Config.Locations[i].y, Config.Locations[i].z - 0.30, Config.Locations[i].text, 0.40)
                DrawMarker(1, Config.Locations[i].x, Config.Locations[i].y, Config.Locations[i].z - 1, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 1.2, 236, 236, 80, 155, false, false, 2, false, 0, 0, 0, 0)
                if dst <= 1 and IsControlJustReleased(0, 38) then
                    CurrentLoc = vector3(Config.Locations[i].x, Config.Locations[i].y, Config.Locations[i].z)
                    _G[Config.Locations[i].func]()
                    CloseForNow = true
                end
            end
        end
        Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function() -- onscreen credit
    while true do
        if Enableshow then
            if Credit ~= nil then
                ShowCreditScreen(Credit)
            end
        end
        Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function() -- menu proximity check
    while true do
        if MenuOpen then
            local dst = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), CurrentLoc, true)

            if dst >= 1.5 then
                ESX.UI.Menu.CloseAll()
                CloseForNow = false
                MenuOpen= false
            end
        end
        Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do
        if Testvehicle ~= nil then
            DisableControlAction(0, 75,  true)
            DisableControlAction(27, 75, true)
        end
        Citizen.Wait(10)
    end
end)

OpenExchangeMenu = function()
    MenuOpen = true
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "exchange", {
        title = "Credit Exchange",
        align = "top-left",
        elements = {
            {label = "25.000$ | 5 Credit", value = 5, cash = 25000}, -- value is the credit cost | cash is amount players gets
            {label = "125.000$ | 25 Credit", value = 25, cash = 125000},
            {label = "250.000$ | 50 Credit", value = 50, cash = 250000},
            {label = "500.000$ | 100 Credit", value = 100, cash = 500000},
            {label = "1.250.000$ | 250 Credit", value = 250, cash = 1250000},
            {label = "2.500.000$ | 500 Credit", value = 500, cash = 2500000},
        }
    }, function(data, menu)
        if data.current.value == 5 or data.current.value == 25 or data.current.value == 50 or data.current.value == 100 or data.current.value == 250 or data.current.value == 500 then
            local cash = data.current.cash
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "areyousure", {
                title = "Are you sure?",
                align = "top-left",
                elements = {
                    {label = "Yes", value = true},
                    {label = "No", value = false}
                }
            }, function(data2, menu2)
                if data2.current.value then
                    ESX.TriggerServerCallback("utk_c:getcredit", function(curamount)
                        if tonumber(curamount) >= data.current.value then
                            ESX.UI.Menu.CloseAll()
                            CloseForNow = false
                            newamount = curamount - data.current.value
                            TriggerServerEvent("utk_c:updatecredit", newamount, "exchange", cash, data.current.value)
                            TriggerServerEvent("utk_c:updatemoney", "add", cash)
                            exports["mythic_notify"]:SendAlert("success", data.current.value.." Credit exchanged to "..ESX.Math.GroupDigits(cash).."$ .")
                        else
                            exports["mythic_notify"]:SendAlert("error", "You don't have enough credit!")
                        end
                    end)
                elseif not data2.current.value then
                    menu2.close()
                    menu.open()
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        end
    end, function (data, menu)
        menu.close()
        MenuOpen = false
        CloseForNow = false
    end)
end

OpenBlackMarket = function()
    MenuOpen = true
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "wep-shop", {
        title = "Black Market",
        align = "top-left",
        elements = {
            {label = "Plaka Değiştirme", value = "plaka", price = 50},
            {label = "Lockpick", value = "lockpick", price = 5}, -- label is menu option | value is weapon code | price is credit cost
            {label = "Hacker Laptop", value = "laptop_h", price = 50}
        }
    }, function(data, menu)
        local selection = data.current

        if selection.value == "plaka" then
            local carlist = nil

            ESX.TriggerServerCallback("utk_c:getVehList", function(result)
                if result ~= nil then
                    carlist = result
                    ESX.TriggerServerCallback("utk_c:getcredit", function(curamount)
                        if tonumber(curamount) >= 20 then
                            local thetable = {}
                            local temp = {}
                            local carhash
                            local name

                            for i = 1, #carlist, 1 do
                                carhash = json.decode(carlist[i].vehicle)
                                if GetDisplayNameFromVehicleModel(carhash.model) ~= "CARNOTFOUND" then
                                    name = GetDisplayNameFromVehicleModel(carhash.model)
                                else
                                    name = GetVehicleName(carhash.model)
                                end

                                temp = {label = name.." | "..carlist[i].plate, value = carlist[i].plate}
                                table.insert(thetable, temp)
                            end
                            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "platelist", {
                                title = "Owned Vehicles",
                                align = "top-left",
                                elements = thetable
                            }, function(data2, menu2)
                                if data2.current.value ~= nil then
                                    local oldplate = data2.current.value

                                    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "plate", {
                                        title = "New Plate"
                                    }, function(data3, menu3)
                                        local newplate = nil
                                        local newamount = nil

                                        if tostring(data3.value):len() <= 8 and tostring(data3.value):len() >= 4 then
                                            newplate = tostring(data3.value)
                                            ESX.TriggerServerCallback("utk_c:platecheck", function(oc)
                                                if not oc then
                                                    newamount = curamount - 20
                                                    TriggerServerEvent("utk_c:updatecredit", newamount)
                                                    TriggerServerEvent("utk_c:changePlate", oldplate, newplate)
                                                    TriggerServerEvent("utk_c:savecustomlog", "__"..oldplate.."__ plakalı aracın plakası __"..string.upper(newplate).."__ plakasına değiştirildi.", "Plaka Değiştirme")
                                                    ESX.UI.Menu.CloseAll()
                                                    FreezeEntityPosition(PlayerPedId(), false)
                                                    CloseForNow = false
                                                    exports["mythic_notify"]:SendAlert("success", "Your new plate: "..string.upper(newplate).." .")
                                                else
                                                    exports["mythic_notify"]:SendAlert("error", "This plate is taken!")
                                                    ESX.UI.Menu.CloseAll()
                                                    CloseForNow = false
                                                end
                                            end, string.upper(data3.value))
                                        else
                                            exports["mythic_notify"]:SendAlert("error", "Character numbers must be between four and eight.")
                                        end
                                    end, function(data3, menu3)
                                        menu3.close()
                                    end)
                                end
                            end, function(data2, menu2)
                                menu2.close()
                            end)
                        else
                            exports["mythic_notify"]:SendAlert("error", "You don't have enough Credit!")
                        end
                    end)
                else
                    exports["mythic_notify"]:SendAlert("error", "You don't own any vehicle!")
                end
            end)
        else
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "areyousure", {
                title = "Onaylıyor musunuz?",
                align = "top-left",
                elements = {
                    {label = "Evet", value = "evet"},
                    {label = "Hayır", value = "hayır"}
                }
            }, function(data2, menu2)
                if data2.current.value == "evet" then
                    ESX.TriggerServerCallback("utk_c:getcredit", function(result)
                        if tonumber(result) >= selection.price then
                            newamount = result - selection.price
                            TriggerServerEvent("utk_c:updatecredit", newamount, nil, nil, nil)
                            TriggerServerEvent("utk_c:giveitem", selection.value, selection.label, selection.price, newamount)
                            exports["mythic_notify"]:SendAlert("success", selection.label.." itemini "..selection.price.." bitcoine satın aldın.")
                            menu2.close()
                        else
                            exports["mythic_notify"]:SendAlert("error", "Yeteri kadar bitcoinin yok!")
                            menu2.close()
                        end
                    end)
                elseif data2.current.value == "hayır" then
                    menu2.close()
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        end
    end, function(data, menu)
        menu.close()
    end)
end

OpenMarket = function()
    --MenuOpen = true
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "vehicle-shop", {
        title = "Credit Vehicle Shop",
        align = "top-left",
        elements = {
            {label = "50 Credit Category", value = "50"}, -- These are categories, VALUE is the credit cost
            {label = "100 Credit Category", value = "100"},
            {label = "150 Credit Category", value = "150"},
            {label = "200 Credit Category", value = "200"},
            {label = "250 Credit Category", value = "250"},
            {label = "300 Credit Category", value = "300"},
            {label = "400 Credit Volatus Helicopter", value = "400"}, -- This is a single vehicle for example
            {label = "20 Credit Change Plate", value = "20"} -- This is plate change
        }
    }, function(data, menu)
        if data.current.value == "50" then
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "50-shop", {
                title = "50 Credit Vehicles",
                align = "top-left",
                elements = {
                    {label = "Sultan RS", value = "sultanrs"}, -- label is menu name | value is spawn name DON'T FORGET TO CHANGE THESE TO YOUR LIKING, YOU CAN PUT ADD-ON CARS
                    {label = "Impala", value = "impala59c"},
                    {label = "Mustang Boss 302", value = "boss302"},
                    {label = "Dodge Challanger", value = "16challenger"}
                }
            }, function(data2, menu2)
                if data2.current.value == "sultanrs" or data2.current.value == "impala59c" or data2.current.value == "boss302" or data2.current.value == "16challenger" then
                    local notify = data2.current.label
                    local spawnname = data2.current.value

                    ESX.Game.SpawnLocalVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function(vehicle)
                        Testvehicle = vehicle
                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                        FreezeEntityPosition(vehicle, true)
                    end)
                    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "areyousure", {
                        title = "Are you sure?",
                        align = "top-left",
                        elements = {
                            {label = "Yes", value = true},
                            {label = "No", value = false}
                        }
                    }, function(data3, menu3)
                        if data3.current.value then
                            ESX.TriggerServerCallback("utk_c:getcredit", function(curamount)
                                if tonumber(curamount) >= 50 then
                                    ESX.Game.DeleteVehicle(Testvehicle)
                                    Testvehicle = nil
                                    newamount = curamount - 50
                                    TriggerServerEvent("utk_c:updatecredit", newamount)
                                    ESX.Game.SpawnVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function(vehicle)
                                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                        local newPlate = GeneratePlate()
                                        SetVehicleNumberPlateTextIndex(vehicle, Config.platecolor)
                                        SetVehicleColours(vehicle, Config.vehcolor, Config.vehcolor)
                                        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

                                        vehicleProps.plate = newPlate
                                        SetVehicleNumberPlateText(vehicle, newPlate)
                                        TriggerServerEvent('utk_c:registervehicle', vehicleProps, notify, 50)
                                        exports['mythic_notify']:SendAlert("success", "50 Credit spend on "..notify.." !")
                                    end)
                                    ESX.UI.Menu.CloseAll()
                                    CloseForNow = false
                                    FreezeEntityPosition(playerPed, false)
                                else
                                    exports['mythic_notify']:SendAlert("error", "You don't have enough Credit!")
                                end
                            end)
                        elseif not data3.current.value then
                            SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                            ESX.Game.DeleteVehicle(Testvehicle)
                            Testvehicle = nil
                            menu3.close()
                            menu2.open()
                        end
                    end, function(data3, menu3)
                        SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                        ESX.Game.DeleteVehicle(Testvehicle)
                        Testvehicle = nil
                        menu3.close()
                    end)
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif data.current.value == "100" then
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "100-shop", {
                title = "100 Credit Vehicles",
                align = "top-left",
                elements = {
                    {label = "Cadillac CTS", value = "ctsv16"},
                    {label = "VW Scirocco", value = "lwscir"},
                    {label = "Mitsubishi Evolution", value = "fq360"}
                }
            }, function(data2, menu2)
                if data2.current.value == "ctsv16" or data2.current.value == "lwscir" or data2.current.value == "fq360" then
                    local notify = data2.current.label
                    local spawnname = data2.current.value

                    ESX.Game.SpawnLocalVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function(vehicle)
                        Testvehicle = vehicle
                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                        FreezeEntityPosition(vehicle, true)
                    end)
                    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "areyousure", {
                        title = "Are you sure?",
                        align = "top-left",
                        elements = {
                            {label = "Yes", value = true},
                            {label = "No", value = false}
                        }
                    }, function(data3, menu3)
                        if data3.current.value then
                            ESX.TriggerServerCallback("utk_c:getcredit", function(curamount)
                                if tonumber(curamount) >= 100 then
                                    ESX.Game.DeleteVehicle(Testvehicle)
                                    Testvehicle = nil
                                    newamount = curamount - 100
                                    TriggerServerEvent("utk_c:updatecredit", newamount)
                                    ESX.Game.SpawnVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function (vehicle)
                                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                        local newPlate = GeneratePlate()
                                        SetVehicleNumberPlateTextIndex(vehicle, 2)
                                        SetVehicleColours(vehicle, 53, 53)
                                        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

                                        vehicleProps.plate = newPlate
                                        SetVehicleNumberPlateText(vehicle, newPlate)
                                        TriggerServerEvent('utk_c:registervehicle', vehicleProps, notify, 100)
                                        exports['mythic_notify']:SendAlert("success", "100 Credit spend on "..notify.." !")
                                    end)
                                    ESX.UI.Menu.CloseAll()
                                    CloseForNow = false
                                    FreezeEntityPosition(playerPed, false)
                                else
                                    exports['mythic_notify']:SendAlert("error", "You don't have enough Credit!")
                                end
                            end)
                        elseif not data3.current.value then
                            SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                            ESX.Game.DeleteVehicle(Testvehicle)
                            Testvehicle = nil
                            menu3.close()
                            menu2.open()
                        end
                    end, function(data3, menu3)
                        SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                        ESX.Game.DeleteVehicle(Testvehicle)
                        Testvehicle = nil
                        menu3.close()
                    end)
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif data.current.value == "150" then
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "150-shop", {
                title = "150 Credit Vehicles",
                align = "top-left",
                elements = {
                    {label = "Mercedes G65", value = "g65amg"},
                    {label = "Maserati Alfieri", value = "alfieri"},
                    {label = "Nissan Skyline GTR", value = "gtr"},
                }
            }, function(data2, menu2)
                if data2.current.value == "g65amg" or data2.current.value == "alfieri" or data2.current.value == "gtr" then
                    local notify = data2.current.label
                    local spawnname = data2.current.value

                    ESX.Game.SpawnLocalVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function(vehicle)
                        Testvehicle = vehicle
                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                        FreezeEntityPosition(vehicle, true)
                    end)
                    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "areyousure", {
                        title = "Are you sure?",
                        align = "top-left",
                        elements = {
                            {label = "Yes", value = true},
                            {label = "No", value = false}
                        }
                    }, function(data3, menu3)
                        if data3.current.value then
                            ESX.TriggerServerCallback("utk_c:getcredit", function(curamount)
                                if tonumber(curamount) >= 150 then
                                    ESX.Game.DeleteVehicle(Testvehicle)
                                    Testvehicle = nil
                                    newamount = curamount - 150
                                    TriggerServerEvent("utk_c:updatecredit", newamount)
                                    ESX.Game.SpawnVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function (vehicle)
                                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                        local newPlate = GeneratePlate()
                                        SetVehicleNumberPlateTextIndex(vehicle, 2)
                                        SetVehicleColours(vehicle, 53, 53)
                                        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

                                        vehicleProps.plate = newPlate
                                        SetVehicleNumberPlateText(vehicle, newPlate)
                                        TriggerServerEvent('utk_c:registervehicle', vehicleProps, notify, 150)
                                        exports['mythic_notify']:SendAlert("success", "150 Credit spend on "..notify.." !")
                                    end)
                                    ESX.UI.Menu.CloseAll()
                                    CloseForNow = false
                                    FreezeEntityPosition(playerPed, false)
                                else
                                    exports['mythic_notify']:SendAlert("error", "You don't have enough Credit!")
                                end
                            end)
                        elseif not data3.current.value then
                            SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                            ESX.Game.DeleteVehicle(Testvehicle)
                            Testvehicle = nil
                            menu3.close()
                            menu2.open()
                        end
                    end, function(data3, menu3)
                        SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                        ESX.Game.DeleteVehicle(Testvehicle)
                        Testvehicle = nil
                        menu3.close()
                    end)
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif data.current.value == "200" then
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "200-shop", {
                title = "200 Credit Vehicles",
                align = "top-left",
                elements = {
                    {label = "BMW M5 F90", value = "bmci"},
                    {label = "Audi RS7", value = "rs7"},
                    {label = "Mazda RX7 Veilside", value = "rx7veilside"},
                    {label = "Range Rover SVR", values = "svr16"}
                }
            }, function(data2, menu2)
                if data2.current.value == "bmci" or data2.current.value == "rs7" or data2.current.value == "rx7veilside" or data2.current.value == "svr16" then
                    local notify = data2.current.label
                    local spawnname = data2.current.value

                    ESX.Game.SpawnLocalVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function(vehicle)
                        Testvehicle = vehicle
                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                        FreezeEntityPosition(vehicle, true)
                    end)
                    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "areyousure", {
                        title = "Are you sure?",
                        align = "top-left",
                        elements = {
                            {label = "Yes", value = true},
                            {label = "No", value = false}
                        }
                    }, function(data3, menu3)
                        if data3.current.value then
                            ESX.TriggerServerCallback("utk_c:getcredit", function(curamount)
                                if tonumber(curamount) >= 200 then
                                    ESX.Game.DeleteVehicle(Testvehicle)
                                    Testvehicle = nil
                                    newamount = curamount - 200
                                    TriggerServerEvent("utk_c:updatecredit", newamount)
                                    ESX.Game.SpawnVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function (vehicle)
                                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                        local newPlate = GeneratePlate()
                                        SetVehicleNumberPlateTextIndex(vehicle, 2)
                                        SetVehicleColours(vehicle, 53, 53)
                                        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

                                        vehicleProps.plate = newPlate
                                        SetVehicleNumberPlateText(vehicle, newPlate)
                                        TriggerServerEvent('utk_c:registervehicle', vehicleProps, notify, 200)
                                        exports['mythic_notify']:SendAlert("success", "200 Credit spend on "..notify.." !")
                                    end)
                                    ESX.UI.Menu.CloseAll()
                                    CloseForNow = false
                                    FreezeEntityPosition(playerPed, false)
                                else
                                    exports['mythic_notify']:SendAlert("error", "You don't have enough Credit!")
                                end
                            end)
                        elseif not data3.current.value then
                            SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                            ESX.Game.DeleteVehicle(Testvehicle)
                            Testvehicle = nil
                            menu3.close()
                            menu2.open()
                        end
                    end, function(data3, menu3)
                        SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                        ESX.Game.DeleteVehicle(Testvehicle)
                        Testvehicle = nil
                        menu3.close()
                    end)
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif data.current.value == "250" then
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "250-shop", {
                title = "250 Credit Vehicles",
                align = "top-left",
                elements = {
                    {label = "Mercedes Benz Limo", value = "cognoscenti"},
                    {label = "Mercedes Benz S65 AMG", value = "s65amg"},
                    {label = "Ford Mustang GT", value = "mst"},
                }
            }, function(data2, menu2)
                if data2.current.value == "cognoscenti" or data2.current.value == "s65amg" or data2.current.value == "mst" then
                    local notify = data2.current.label
                    local spawnname = data2.current.value

                    ESX.Game.SpawnLocalVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function(vehicle)
                        Testvehicle = vehicle
                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                        FreezeEntityPosition(vehicle, true)
                    end)
                    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "areyousure", {
                        title = "Are you sure?",
                        align = "top-left",
                        elements = {
                            {label = "Yes", value = true},
                            {label = "No", value = false}
                        }
                    }, function(data3, menu3)
                        if data3.current.value then
                            ESX.TriggerServerCallback("utk_c:getcredit", function(curamount)
                                if tonumber(curamount) >= 250 then
                                    ESX.Game.DeleteVehicle(Testvehicle)
                                    Testvehicle = nil
                                    newamount = curamount - 250
                                    TriggerServerEvent("utk_c:updatecredit", newamount)
                                    ESX.Game.SpawnVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function (vehicle)
                                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                        local newPlate = GeneratePlate()
                                        SetVehicleNumberPlateTextIndex(vehicle, 2)
                                        SetVehicleColours(vehicle, 53, 53)
                                        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

                                        vehicleProps.plate = newPlate
                                        SetVehicleNumberPlateText(vehicle, newPlate)
                                        TriggerServerEvent('utk_c:registervehicle', vehicleProps, notify, 250)
                                        exports['mythic_notify']:SendAlert("success", "250 Credit spend on "..notify.." !")
                                    end)
                                    ESX.UI.Menu.CloseAll()
                                    CloseForNow = false
                                    FreezeEntityPosition(playerPed, false)
                                else
                                    exports['mythic_notify']:SendAlert("error", "You don't have enough Credit!")
                                end
                            end)
                        elseif not data3.current.value then
                            SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                            ESX.Game.DeleteVehicle(Testvehicle)
                            Testvehicle = nil
                            menu3.close()
                            menu2.open()
                        end
                    end, function(data3, menu3)
                        SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                        ESX.Game.DeleteVehicle(Testvehicle)
                        Testvehicle = nil
                        menu3.close()
                    end)
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif data.current.value == "300" then
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "300-shop", {
                title = "300 Credit Vehicles",
                align = "top-left",
                elements = {
                    {label = "Ford Mustang GT Premium", value = "rmodmustang"},
                    {label = "BMW i8", value = "i8"},
                    {label = "Toyota Supra", value = "supra2"},
                    {label = "Lamborghini Aventador", value = "lamboavj"},
                    {label = "Ferrari California", value = "fc15"}
                }
            }, function(data2, menu2)
                if data2.current.value == "rmodmustang" or data2.current.value == "i8" or data2.current.value == "lamboavj" or data2.current.value == "fc15" or data2.current.value == "supra2" then
                    local notify = data2.current.label
                    local spawnname = data2.current.value

                    ESX.Game.SpawnLocalVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function(vehicle)
                        Testvehicle = vehicle
                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                        FreezeEntityPosition(vehicle, true)
                    end)
                    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "areyousure", {
                        title = "Are you sure?",
                        align = "top-left",
                        elements = {
                            {label = "Yes", value = true},
                            {label = "No", value = false}
                        }
                    }, function(data3, menu3)
                        if data3.current.value then
                            ESX.TriggerServerCallback("utk_c:getcredit", function(curamount)
                                if tonumber(curamount) >= 300 then
                                    ESX.Game.DeleteVehicle(Testvehicle)
                                    Testvehicle = nil
                                    newamount = curamount - 300
                                    TriggerServerEvent("utk_c:updatecredit", newamount)
                                    ESX.Game.SpawnVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function (vehicle)
                                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                        local newPlate = GeneratePlate()
                                        SetVehicleNumberPlateTextIndex(vehicle, 2)
                                        SetVehicleColours(vehicle, 53, 53)
                                        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

                                        vehicleProps.plate = newPlate
                                        SetVehicleNumberPlateText(vehicle, newPlate)
                                        TriggerServerEvent('utk_c:registervehicle', vehicleProps, notify, 300)
                                        exports['mythic_notify']:SendAlert("success", "300 Credit spend on "..notify.." !")
                                    end)
                                    ESX.UI.Menu.CloseAll()
                                    CloseForNow = false
                                    FreezeEntityPosition(playerPed, false)
                                else
                                    exports['mythic_notify']:SendAlert("error", "You don't have enough Credit!")
                                end
                            end)
                        elseif not data3.current.value then
                            SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                            ESX.Game.DeleteVehicle(Testvehicle)
                            Testvehicle = nil
                            menu3.close()
                            menu2.open()
                        end
                    end, function(data3, menu3)
                        SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                        ESX.Game.DeleteVehicle(Testvehicle)
                        Testvehicle = nil
                        menu3.close()
                    end)
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif data.current.value == "400" then
            local notify = "Volatus Helicopter"
            local spawnname = "volatus"

            ESX.Game.SpawnLocalVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function(vehicle)
                Testvehicle = vehicle
                TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                FreezeEntityPosition(vehicle, true)
            end)
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "areyousure", {
                title = "Are you sure?",
                align = "top-left",
                elements = {
                    {label = "Yes", value = true},
                    {label = "No", value = false}
                }
            }, function(data3, menu3)
                if data3.current.value then
                    ESX.TriggerServerCallback("utk_c:getcredit", function(curamount)
                        if tonumber(curamount) >= 400 then
                            ESX.Game.DeleteVehicle(Testvehicle)
                            Testvehicle = nil
                            newamount = curamount - 400
                            TriggerServerEvent("utk_c:updatecredit", newamount)
                            ESX.Game.SpawnVehicle(spawnname, Config.Locations[2].spawnloc, Config.Locations[2].heading, function (vehicle)
                                TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                local newPlate = GeneratePlate()
                                SetVehicleNumberPlateTextIndex(vehicle, 2)
                                SetVehicleColours(vehicle, 53, 53)
                                local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

                                vehicleProps.plate = newPlate
                                SetVehicleNumberPlateText(vehicle, newPlate)
                                TriggerServerEvent('utk_c:registervehicle', vehicleProps, notify, 400)
                                exports['mythic_notify']:SendAlert("success", "400 Credit spend on "..notify.." !")
                            end)
                            ESX.UI.Menu.CloseAll()
                            CloseForNow = false
                            FreezeEntityPosition(playerPed, false)
                        else
                            exports['mythic_notify']:SendAlert("error", "You don't have enough Credit!")
                        end
                    end)
                elseif not data3.current.value then
                    SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                    ESX.Game.DeleteVehicle(Testvehicle)
                    Testvehicle = nil
                    menu3.close()
                    menu.open()
                end
            end, function(data3, menu3)
                SetEntityCoords(playerPed, Config.Locations[2].x, Config.Locations[2].y, Config.Locations[2].z - 1, 0.0, 0.0, 0.0, false)
                ESX.Game.DeleteVehicle(Testvehicle)
                Testvehicle = nil
                menu3.close()
            end)
        elseif data.current.value == "20" then
            local carlist = nil

            ESX.TriggerServerCallback("utk_c:getVehList", function(result)
                if result ~= nil then
                    carlist = result
                    ESX.TriggerServerCallback("utk_c:getcredit", function(curamount)
                        if tonumber(curamount) >= 20 then
                            local thetable = {}
                            local temp = {}
                            local carhash
                            local name

                            for i = 1, #carlist, 1 do
                                carhash = json.decode(carlist[i].vehicle)
                                if GetDisplayNameFromVehicleModel(carhash.model) ~= "CARNOTFOUND" then
                                    name = GetDisplayNameFromVehicleModel(carhash.model)
                                else
                                    name = GetVehicleName(carhash.model)
                                end

                                temp = {label = name.." | "..carlist[i].plate, value = carlist[i].plate}
                                table.insert(thetable, temp)
                            end
                            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "platelist", {
                                title = "Owned Vehicles",
                                align = "top-left",
                                elements = thetable
                            }, function(data2, menu2)
                                if data2.current.value ~= nil then
                                    local oldplate = data2.current.value

                                    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "plate", {
                                        title = "New Plate"
                                    }, function(data3, menu3)
                                        local newplate = nil
                                        local newamount = nil

                                        if tostring(data3.value):len() <= 8 and tostring(data3.value):len() >= 4 then
                                            newplate = tostring(data3.value)
                                            ESX.TriggerServerCallback("utk_c:platecheck", function(oc)
                                                if not oc then
                                                    newamount = curamount - 20
                                                    TriggerServerEvent("utk_c:updatecredit", newamount)
                                                    TriggerServerEvent("utk_c:changePlate", oldplate, newplate)
                                                    TriggerServerEvent("utk_c:savecustomlog", "__"..oldplate.."__ plated vehicles has been changed to __"..string.upper(newplate).."__ plate.", "Plate Change")
                                                    ESX.UI.Menu.CloseAll()
                                                    FreezeEntityPosition(PlayerPedId(), false)
                                                    CloseForNow = false
                                                    exports["mythic_notify"]:SendAlert("success", "Your new plate: "..string.upper(newplate).." .")
                                                else
                                                    exports["mythic_notify"]:SendAlert("error", "This plate is taken!")
                                                    ESX.UI.Menu.CloseAll()
                                                    CloseForNow = false
                                                end
                                            end, string.upper(data3.value))
                                        else
                                            exports["mythic_notify"]:SendAlert("error", "Character numbers must be between four and eight.")
                                        end
                                    end, function(data3, menu3)
                                        menu3.close()
                                    end)
                                end
                            end, function(data2, menu2)
                                menu2.close()
                            end)
                        else
                            exports["mythic_notify"]:SendAlert("error", "You don't have enough Credit!")
                        end
                    end)
                else
                    exports["mythic_notify"]:SendAlert("error", "You don't own any vehicle!")
                end
            end)
        end
    end, function(data, menu)
        FreezeEntityPosition(playerPed, false)
        MenuOpen = false
        menu.close()
        CloseForNow = false
    end)
end

OpenWepShop = function() -- This is a bit complicated because I had something different in my mind while creating this menu. If you need a clean item or weapons menu come Discord.
    MenuOpen = true
    ESX.UI.Menu.CloseAll()
    local playerPed = PlayerPedId()

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "wep-shop", {
        title = "Credit Weapon Shop",
        align = "top-left",
        elements = {
            {label = "50 Credit | Desert Eagle .50", value = "weapon_pistol50", price = 50, method = 1, notify = "Desert Eagle .50"}, -- label is menu option | value is weapon code | price is credit cost
            {label = "50 Credit | Golden Revolver", value = "weapon_doubleaction", price = 50, method = 1, notify = "Golden Revolver"},
            {label = "140 Credit | Micro SMG", value = "weapon_microsmg", price = 140, method = 1, notify = "Micro SMG"},
            {label = "200 Credit | Assault Rifle", value = "weapon_assaultrifle", price = 200, method = 1, notify = "Assault Rifle"},
            {label = "400 Credit | Sniper Rifle", value = "weapon_sniperrifle", price = 400, method = 1, notify = "Sniper Rifle"},
            {label = "10 Credit | Platinium Plating ", value = "platin50", check = {"weapon_pistol50"}, price = 10, method = 2, notify = "Platinium Plating"}, -- This is an item example | you can sell any item in this shop if you want
            {label = "10 Credit | Gold Plating", value = "yusuf", check = {"weapon_microsmg", "weapon_assaultrifle"}, price = 10, method = 2, notify = "Gold Plating"}, -- checks are item checks, if the player don't own the weapon he/she cannot buy the item
            {label = "5 Credit | 500 Bullets", value =  500, price = 5, method = 3, notify = "500 Bullets"}, -- Has to hold a weapon while buying (AMMO)
            {label = "1 Credit | 100 Bullets", value = 100, price = 1, method = 3, notify = "100 Bullets"}
        }
    }, function(data, menu)
        if data.current.value == "weapon_pistol50" or data.current.value == "platin50" or data.current.value == "yusuf" or data.current.value == "weapon_doubleaction" or data.current.value == "weapon_microsmg" or data.current.value == "weapon_assaultrifle" or data.current.value == "weapon_sniperrifle" then
            local choice = data.current

            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "areyousure2", {
                title = "Are you sure? | "..tostring(choice.price).." Credit",
                align = "top-left",
                elements = {
                    {label = "Yes", value = true},
                    {label = "No", value = false}
                }
            }, function(data2, menu2)
                if data2.current.value then
                    if choice.method == 1 then
                        if not HasPedGotWeapon(playerPed, GetHashKey(choice.value), false) then
                            ESX.TriggerServerCallback("utk_c:getcredit", function(output)
                                if tonumber(output) >= choice.price then
                                    newamount = tonumber(output) - choice.price
                                    TriggerServerEvent("utk_c:updatecredit", newamount)
                                    TriggerServerEvent("utk_c:savecustomlog", "**"..choice.notify.."** item has been bought for **"..choice.price.."** Credit.", "Market Usage")
                                    GiveWeaponToPed(playerPed, GetHashKey(choice.value), 500, false, false)
                                    exports["mythic_notify"]:SendAlert("success", tostring(choice.price).." Credit spend on "..choice.notify..".")
                                    menu2.close()
                                    menu.open()
                                else
                                    exports["mythic_notify"]:SendAlert("error", "You don't have enough Credit.")
                                    menu2.close()
                                    menu.open()
                                end
                            end)
                        else
                            exports["mythic_notify"]:SendAlert("error", "You already have "..choice.notify..".")
                            menu2.close()
                            menu.open()
                        end
                    elseif choice.method == 2 then
                        local control = 0
                        local hasitem
                        ESX.TriggerServerCallback("utk_c:checkitem", function(output)
                            hasitem = output
                            if not hasitem then
                                for i = 1, #choice.check, 1 do
                                    if HasPedGotWeapon(playerPed, GetHashKey(choice.check[i]), false) then
                                        ESX.TriggerServerCallback("utk_c:getcredit", function(output)
                                            if tonumber(output) >= choice.price then
                                                newamount = tonumber(output) - choice.price
                                                TriggerServerEvent("utk_c:updatecredit", newamount)
                                                TriggerServerEvent("utk_c:giveitem", choice.value)
                                                TriggerServerEvent("utk_c:savecustomlog", "**"..choice.notify.."** item has been bought for **"..choice.price.."** Credit.", "Market Usage")
                                                exports["mythic_notify"]:SendAlert("success", tostring(choice.price).." Credit spend on "..choice.notify..".")
                                                exports["mythic_notify"]:SendAlert("success", "To plate, hold your weapon while using the item.")
                                                menu2.close()
                                            else
                                                exports["mythic_notify"]:SendAlert("error", "You don't have enough Credit.")
                                                menu2.close()
                                            end
                                        end)
                                        break
                                    else
                                        control = control + 1
                                        if control == 2 and choice.value == "yusuf" then
                                            exports["mythic_notify"]:SendAlert("error", "You don't have a suitable weapon for this plating.")
                                            menu2.close()
                                            break
                                        elseif control == 1 and choice.value == "platin50" then
                                            exports["mythic_notify"]:SendAlert("error", "You don't have a suitable weapon for this plating.")
                                            menu2.close()
                                            break
                                        end
                                    end
                                end
                            elseif hasitem then
                                exports["mythic_notify"]:SendAlert("error", "You already have "..choice.notify..".")
                                menu2.close()
                            end
                        end, choice.value)
                    end
                else
                    menu2.close()
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif data.current.value == 500 or data.current.value == 100 then
            local choice = data.current

            if choice.method == 3 then
                ESX.UI.Menu.Open("default", GetCurrentResourceName(), "ammo-shop", {
                    title = "Weapon Choice | "..choice.value.."  Ammo",
                    align = "top-left",
                    elements = {
                        {label = "Desert Eagle .50", value = "weapon_pistol50"}, -- you can add other weapons here
                        {label = "Golden Revolver", value = "weapon_doubleaction"},
                        {label = "Micro SMG", value = "weapon_microsmg"},
                        {label = "Assault Rifle", value = "weapon_assaultrifle"},
                        {label = "Sniper Rifle", value = "weapon_sniperrifle"}
                    }
                }, function(data2, menu2)
                    if data2.current.value == "weapon_pistol50" or data2.current.value == "weapon_doubleaction" or data2.current.value == "weapon_microsmg" or data2.current.value == "weapon_assaultrifle" or data2.current.value == "weapon_sniperrifle" then
                        local choice2 = data2.current

                        if HasPedGotWeapon(playerPed, GetHashKey(choice2.value), false) then
                            local a, max = GetMaxAmmo(playerPed, GetHashKey(choice2.value))
                            if max > (GetAmmoInPedWeapon(playerPed, GetHashKey(choice2.value)) + choice.value) then
                                ESX.TriggerServerCallback("utk_c:getcredit", function(output)
                                    if tonumber(output) >= choice.price then
                                        newamount = tonumber(output) - choice.price
                                        TriggerServerEvent("utk_c:updatecredit", newamount)
                                        TriggerServerEvent("utk_c:savecustomlog", "**"..choice.notify.. "** ammo, has been bought for**"..choice2.label.."** weapon for **"..choice.price.."** Credit.", "Market Usage")
                                        AddAmmoToPed(playerPed, GetHashKey(choice2.value), choice.value)
                                        exports["mythic_notify"]:SendAlert("success", "Bought "..choice.value.." for "..choice2.label..".")
                                    else
                                        exports["mythic_notify"]:SendAlert("error", "You don't have enough Credit.")
                                    end
                                end)
                            else
                                exports["mythic_notify"]:SendAlert("error", "You don't have enough capacity for this ammo.")
                            end
                        else
                            exports["mythic_notify"]:SendAlert("error", "You don't have "..choice2.label..".")
                        end
                    end
                end, function(data2, menu2)
                    menu2.close()
                end)
            end
        end
    end, function(data, menu)
        menu.close()
        MenuOpen = false
        CloseForNow = false
    end)
end

function GetCredit()
    local amount = nil

    ESX.TriggerServerCallback("utk_c:getcredit", function(output)
        amount = tonumber(output)
    end)
    while amount == nil do Citizen.Wait(1) end
    return amount
end

RegisterCommand(Config.showcommand, function()
    if Enableshow then
        Enableshow = false
    elseif not Enableshow then
        Enableshow = true
    end
end)

-- esx_vehicleshop functions --

function GetVehicleName(hash)
    if Vehicles[tostring(hash)] ~= nil then
        return Vehicles[tostring(hash)]
    else
        return "Unregistered vehicle name"
    end
end

function DeleteShopInsideVehicles()
	while #LastVehicles > 0 do
		local vehicle = LastVehicles[1]

		ESX.Game.DeleteVehicle(vehicle)
		if LastVehiclesHash ~= nil then
			SetModelAsNoLongerNeeded(LastVehiclesHash)
			LastVehiclesHash = nil
		end
		table.remove(LastVehicles, 1)
	end
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)

			DisableControlAction(0, 32, true) -- W
			DisableControlAction(0, 33, true) -- S
			DisableControlAction(0, 34, true) -- A
			DisableControlAction(0, 35, true) -- D
			DisableControlAction(0, 176, true) -- Enter
			DisableControlAction(0, 177, true) -- Backspace
		end
	end
end
-------------------------------
function ShowCreditScreen(number)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.50, 0.50)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextFont(7)
    SetTextEntry("STRING")
    AddTextComponentString(Config.logo..math.floor(number))
    DrawText(0.16, 0.95)
end

function DrawText3D(x, y, z, text, scale)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

	SetTextScale(scale, scale)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(true)
	SetTextColour(255, 255, 255, 215)

	AddTextComponentString(text)
	DrawText(_x, _y)

	local factor = (string.len(text)) / 5000
	DrawRect(_x, _y + 0.0150, 0.095 + factor, 0.03, 41, 11, 41, 100)
end

Citizen.CreateThread(function()
    Citizen.Wait(10000)
    TriggerServerEvent("utk_c:checkplayer")
    for i = 1, #Config.Locations, 1 do
        if not DoesBlipExist(Config.Locations[i].blip) then
            Config.Locations[i].blip = AddBlipForCoord(Config.Locations[i].x, Config.Locations[i].y, Config.Locations[i].z)
            SetBlipSprite(Config.Locations[i].blip, Config.Locations[i].bliptype)
            SetBlipColour(Config.Locations[i].blip, Config.Locations[i].blipcolor)
            SetBlipScale(Config.Locations[i].blip, 1.5)
            BeginTextCommandSetBlipName("STRING")
		    AddTextComponentString(Config.Locations[i].blipname)
	        EndTextCommandSetBlipName(Config.Locations[i].blip)
            SetBlipAsShortRange(Config.Locations[i].blip, true)
        end
    end
end)
