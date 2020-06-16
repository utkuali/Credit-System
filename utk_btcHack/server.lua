ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

local maxhack = 3 -- max hack a player can do in a day
local maxcredit = 5 -- max credit
local mincredit = 3 -- min credit
local mincops = 0 -- min required cops
local requireditem = "laptop_h" -- required item to start hack
local playerCounters = {}

RegisterServerEvent("utk_creditHack")
AddEventHandler("utk_creditHack", function()
    local _source = source
    local amount = math.random(mincredit, maxcredit)
    playerCounters[xPlayer.identifier] = playerCounters[xPlayer.identifier] - 1

    TriggerEvent("utk_c:addcredit", _source, amount)
end)

ESX.RegisterServerCallback("utk_creditHack", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem(requireditem)

    if item.count > 0 then
        if playerCounters[xPlayer.identifier] ~= nil then
            if playerCounters[xPlayer.identifier] < maxhack then
                local players = ESX.GetPlayers()
                local cops = 0

                for i = 1, #players, 1 do
                    local temp = ESX.GetPlayerFromId(players[i])

                    if temp.job.name == "police" then
                        cops = cops + 1
                    end
                end
                if cops >= mincops then
                    cb(true)
                else
                    cb("Not enough cops in town!")
                end
            else
                cb("You done too many hacks today!")
            end
        else
            playerCounters[xPlayer.identifier] = 1
            local players = ESX.GetPlayers()
            local cops = 0

            for i = 1, #players, 1 do
                local temp = ESX.GetPlayerFromId(players[i])

                if temp.job.name == "police" then
                    cops = cops + 1
                end
            end
            if cops >= mincops then
                cb(true)
            else
                cb("Not enough cops in town!")
            end
        end
    else
        cb("You don't have the required item!")
    end
end)
