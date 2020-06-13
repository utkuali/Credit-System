ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function UpdateCredit(xPlayer, amount, style, sourceid, amount2, receiver, cash)
    MySQL.Async.execute("UPDATE credit SET amount = @amount WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier,
        ["@amount"] = amount
    })
    if Config.logs then
        if style ~= nil then
            local yPlayer = ESX.GetPlayerFromId(sourceid)
            if style == 1 then
                TriggerClientEvent("utk_c:creditfeed", receiver, amount)
                TriggerClientEvent('chat:addMessage', receiver, { args = { '^1Credit', "^* You recieved ^2"..amount2.."^0 Credit. New amount: ^2"..math.floor(amount)}})
                TriggerClientEvent('chat:addMessage', sourceid, { args = { '^1Credit', " "..yPlayer.name.."^2^* [ID: "..receiver..']^0 given ^2'..amount2.."^0 credit. New amount: ^2"..math.floor(amount)}})
                DiscordLog("Command-Adding", "(Command user: **"..yPlayer.name.."**) Added amount: **"..amount2.."** | New amount: **"..amount.."** \n (Steam name: **"..xPlayer.name.."**, Hex: **"..xPlayer.identifier.."**)", 15844367)
                return
            elseif style == 2 then
                TriggerClientEvent("utk_c:creditfeed", receiver, amount)
                TriggerClientEvent('chat:addMessage', receiver, { args = { '^1Credit', "^* ^1"..amount2.."^0 credit has ben decreased. New amount: ^1"..math.floor(amount)}})
                TriggerClientEvent('chat:addMessage', sourceid, { args = { '^1Credit', " "..yPlayer.name.."^2^* [ID: "..receiver..']^0 decreased ^2'..amount2.."^0 credit. New amount: ^2"..math.floor(amount)}})
                DiscordLog("Command-Removing", "(Command user: **"..yPlayer.name.."**) Removed amount: **"..amount2.."** | New amount: **"..amount.."** \n (Steam name: **"..xPlayer.name.."**, Hex: **"..xPlayer.identifier.."**)", 15844367)
                return
            elseif style == "exchange" then
                TriggerClientEvent("utk_c:creditfeed", sourceid, amount)
                DiscordLog("Exchange", "**"..amount2.."** Credit has been exchanged to **"..ESX.Math.GroupDigits(cash).."$**. | New amount: **"..amount.."** \n (Steam name: **"..xPlayer.name.."**, Hex: **"..xPlayer.identifier.."**)", 15844367)
                return
            end
        end
        TriggerClientEvent("utk_c:creditfeed", sourceid, amount)
    end
end

RegisterServerEvent("utk_c:checkplayer")
AddEventHandler("utk_c:checkplayer", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local result = MySQL.Sync.fetchAll("SELECT identifier FROM credit")
    local found = false
    while xPlayer == nil do
        xPlayer = ESX.GetPlayerFromId(_source)
        Citizen.Wait(1000)
    end
    for i = 1, #result, 1 do
        if result[i].identifier == xPlayer.identifier then
            found = true
            print("^2[UTK-CREDIT]^0 Player Found: "..xPlayer.name..", "..xPlayer.identifier)
            TriggerClientEvent("utk_c:playerfound", _source)
        end
    end
    if not found then
        MySQL.Async.execute("INSERT INTO credit (identifier, amount) VALUES (@identifier, @amount)", {
            ["@identifier"] = xPlayer.identifier,
            ["@amount"] = 0
        })
        DiscordLog("Register", "Steam Name: (**"..xPlayer.name.."**), Hex: **"..xPlayer.identifier.."**", 15844367)
        TriggerClientEvent("utk_c:playerfound", _source)
    end
end)

RegisterServerEvent("utk_c:updatecredit")
AddEventHandler("utk_c:updatecredit", function(amount, style, cash, amount2)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    UpdateCredit(xPlayer, amount, style, source, amount2, nil, cash)
end)

RegisterServerEvent("utk_c:getcredit")
AddEventHandler("utk_c:getcredit", function(output, id)
    if id == nil then
        id = source
    end
    local xPlayer, result = ESX.GetPlayerFromId(id)

    result = MySQL.Sync.fetchAll("SELECT amount FROM credit WHERE identifier = @identifier", {["@identifier"] = xPlayer.identifier})
    output(result[1].amount)
end)

AddEventHandler("utk_c:addcredit", function(id, amount)
    local xPlayer = ESX.GetPlayerFromId(id)
    local oldamount = MySQL.Sync.fetchAll("SELECT amount FROM credit WHERE identifier = @identifier", {["@identifier"] = xPlayer.identifier})[1].amount

    MySQL.Async.execute("UPDATE credit SET amount = @amount WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier,
        ["@amount"] = oldamount + amount
    })
    DiscordLog("External-Adding", amount.." has added to "..xPlayer.name.." (Hex: "..xPlayer.identifier..").", 15844367)
    TriggerClientEvent("utk_c:creditfeed", id, oldamount + amount)
end)

AddEventHandler("utk_c:removecredit", function(id, amount)
    local xPlayer = ESX.GetPlayerFromId(id)
    local oldamount = MySQL.Sync.fetchAll("SELECT amount FROM credit WHERE identifier = @identifier", {["@identifier"] = xPlayer.identifier})[1].amount

    MySQL.Async.execute("UPDATE credit SET amount = @amount WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier,
        ["@amount"] = oldamount - amount
    })
    DiscordLog("External-Removing", amount.." has removed from "..xPlayer.name.." (Hex: "..xPlayer.identifier..").", 15844367)
    TriggerClientEvent("utk_c:creditfeed", id, oldamount - amount)
end)

RegisterServerEvent("utk_c:updatemoney")
AddEventHandler("utk_c:updatemoney", function(method, amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    if method == "add" then
        xPlayer.addMoney(amount)
    elseif method == "remove" then
        xPlayer.removeMoney(amount)
    end
end)

RegisterServerEvent("utk_c:giveitem")
AddEventHandler("utk_c:giveitem", function(item, logprice, logname)
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.addInventoryItem(item, 1)
end)

RegisterServerEvent("utk_c:savecustomlog")
AddEventHandler("utk_c:savecustomlog", function(text, logname)
    local xPlayer = ESX.GetPlayerFromId(source)
    if logname == nil then
        logname = "Custom Log"
    end
    DiscordLog(logname, text.. " \n (Steam name: **"..xPlayer.name.."**, Hex: **"..xPlayer.identifier.."**)", 15844367)
end)

function DiscordLog(name, message, color)
    local connect = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = message.." \n Date: __"..os.date("%d/%m/%Y - %X").."__",
              ["footer"] = {
                ["text"] = "utkforeva",
              },
          }
      }

    PerformHttpRequest(Config.http, function(err, text, headers) end, 'POST', json.encode({username = Config.dcname, embeds = connect, avatar_url = Config.avatar}), { ['Content-Type'] = 'application/json' })
end

ESX.RegisterServerCallback("utk_c:getcredit", function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local amount
    local result

    result = MySQL.Sync.fetchAll("SELECT amount FROM credit WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier
    })
    if result ~= nil then
        amount = result[1].amount
        cb(amount)
    end
end)

ESX.RegisterServerCallback("utk_c:checkitem", function(source, cb, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local check = xPlayer.getInventoryItem(item)["count"]

    if check >= 1 then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('utk_c:platecheck', function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
    }, function(result)
		cb(result[1] ~= nil)
	end)
end)

ESX.RegisterServerCallback("utk_c:getVehList", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @owner", {["@owner"] = xPlayer.identifier}, function(result)
        if result ~= nil then
            cb(result)
        end
    end)
end)

RegisterServerEvent('utk_c:registervehicle')
AddEventHandler('utk_c:registervehicle', function(vehicleProps, vehiclename, price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, job) VALUES (@owner, @plate, @vehicle, @job)', {
		['@owner']   = xPlayer.identifier,
		['@plate']   = vehicleProps.plate,
        ['@vehicle'] = json.encode(vehicleProps),
        ["@job"] = "civ"
    })
	if Config.logs then
        DiscordLog("Vehicle Buy", "Vehicle: **"..vehiclename.."**, Plate: **__"..vehicleProps.plate.."__** Price: **"..price.."** Credit \n (Steam name: **"..xPlayer.name.."**, Hex: **"..xPlayer.identifier.."**)", 15844367)
	end
end)

RegisterServerEvent("utk_c:changePlate")
AddEventHandler("utk_c:changePlate", function(oldplate, newplate)
    local result = MySQL.Sync.fetchAll("SELECT vehicle FROM owned_vehicles WHERE plate = @oldplate", {["@oldplate"] = oldplate})
    local vehsettings = json.decode(result[1].vehicle)

    vehsettings.plate = newplate
    MySQL.Async.execute("UPDATE owned_vehicles SET plate = @newplate, vehicle = @vehicle WHERE plate = @oldplate", {
        ["@oldplate"] = oldplate,
        ["@newplate"] = string.upper(newplate),
        ["@vehicle"] = json.encode(vehsettings)
    })
end)

TriggerEvent('es:addGroupCommand', Config.adminadd, 'superadmin', function(source, args, user)
    local _source = source
    if args[1] ~= nil then
        if args[2] ~= nil then
            if tonumber(args[2]) ~= nil then
                if math.floor(tonumber(args[2])) == tonumber(args[2]) or math.ceil(tonumber(args[2])) == tonumber(args[2]) then
                    if GetPlayerName(tonumber(args[1])) ~= nil then
                        local xPlayer = ESX.GetPlayerFromId(tonumber(args[1]))
                        local result = MySQL.Sync.fetchAll("SELECT amount FROM credit WHERE identifier = @identifier", {
                            ["@identifier"] = xPlayer.identifier
                        })
                        local amount = result[1].amount
                        local newamount = amount + tonumber(args[2])

                        UpdateCredit(xPlayer, newamount, 1, _source, args[2], tonumber(args[1]), nil)
                    else
                        TriggerClientEvent('chat:addMessage', source, { args = { '^1Credit ', 'No player found with the given ID.'}})
                    end
                else
                    TriggerClientEvent('chat:addMessage', _source, { args = { '^1Credit ', 'You need to enter a whole number.' } })
                end
            else
                TriggerClientEvent('chat:addMessage', _source, { args = { '^1Credit ', 'You need to enter a number.' } })
            end
        else
            TriggerClientEvent('chat:addMessage', _source, { args = { '^1Credit ', 'You need to enter an amount.' } })
        end
	else
		TriggerClientEvent('chat:addMessage', _source, { args = { '^1Credit ', 'You need to enter player ID.' } })
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1Credit ', 'Insufficient permission.' } })
end, { help = "Credit add", params = {{ name = 'ID', help = "Player ID." }, {name = "Amount", help = "Amount you want to add."}}})

TriggerEvent('es:addGroupCommand', Config.adminremove, 'superadmin', function(source, args, user)
    local _source = source
    if args[1] ~= nil then
        if args[2] ~= nil then
            if tonumber(args[2]) ~= nil then
                if math.floor(tonumber(args[2])) == tonumber(args[2]) or math.ceil(tonumber(args[2])) == tonumber(args[2]) then
                    if GetPlayerName(tonumber(args[1])) ~= nil then
                        local xPlayer = ESX.GetPlayerFromId(tonumber(args[1]))
                        local result = MySQL.Sync.fetchAll("SELECT amount FROM credit WHERE identifier = @identifier", {
                            ["@identifier"] = xPlayer.identifier
                        })
                        local amount = result[1].amount
                        local newamount = amount - tonumber(args[2])

                        UpdateCredit(xPlayer, newamount, 2, _source, args[2], tonumber(args[1]), nil)
                    else
                        TriggerClientEvent('chat:addMessage', source, { args = { '^1Credit ', 'No player found with the given ID.'}})
                    end
                else
                    TriggerClientEvent('chat:addMessage', _source, { args = { '^1Credit ', 'You need to enter a whole number.' } })
                end
            else
                TriggerClientEvent('chat:addMessage', _source, { args = { '^1Credit ', 'You need to enter a number.' } })
            end
        else
            TriggerClientEvent('chat:addMessage', _source, { args = { '^1Credit ', 'You need to enter an amount.' } })
        end
	else
		TriggerClientEvent('chat:addMessage', _source, { args = { '^1Credit ', 'You need to enter player ID.' } })
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1Credit ', 'Insufficient permission.' } })
end, { help = "Credit remove", params = {{ name = 'ID', help = "Player ID." }, {name = "Amount", help = "Amount you want to remove."}}})

TriggerEvent('es:addGroupCommand', Config.admincheck, 'superadmin', function(source, args, user)
    if args[1] ~= nil then
        if tonumber(args[1]) ~= nil then
            if GetPlayerName(tonumber(args[1])) ~= nil then
                local xPlayer = ESX.GetPlayerFromId(tonumber(args[1]))
                local result = MySQL.Sync.fetchAll("SELECT amount FROM credit WHERE identifier = @identifier", {
                    ["@identifier"] = xPlayer.identifier
                })
                local amount = result[1].amount

                TriggerClientEvent('chat:addMessage', source, { args = { '^1Credit ', xPlayer.name.."^2 [ID: "..args[1].."]^0 Credit: "..amount }})
            else
                TriggerClientEvent('chat:addMessage', source, { args = { '^1Credit ', 'No player found with the given ID.'}})
            end
        else
            TriggerClientEvent('chat:addMessage', source, { args = { '^Credit ', 'ID must be a number.'}})
        end
	else
		TriggerClientEvent('chat:addMessage', source, { args = { '^1Credit ', 'You need to enter an ID.'}})
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1Credit ', 'Insufficient permission.' } })
end, { help = "Credit query", params = {{ name = 'ID', help = "Player ID." }}})