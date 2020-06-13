ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

local coords = vector3(1272.40, -1711.64, 53.77) -- hack coords
local doingit = false

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()

        if GetDistanceBetweenCoords(GetEntityCoords(player), coords, true) < 2.5 and not doingit then
            DisplayText("Press ~INPUT_PICKUP~ to steal credits.")
            DrawMarker(1, coords, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 236, 236, 80, 155, false, false, 2, false, 0, 0, 0, 0)
            if IsControlJustReleased(0, 38) then
                CanHack()
            end
        end
        Citizen.Wait(1)
    end
end)

function DisableControl() DisableControlAction(0, 73, false) DisableControlAction(0, 24, true) DisableControlAction(0, 257, true) DisableControlAction(0, 25, true) DisableControlAction(0, 263, true) DisableControlAction(0, 32, true) DisableControlAction(0, 34, true) DisableControlAction(0, 31, true) DisableControlAction(0, 30, true) DisableControlAction(0, 45, true) DisableControlAction(0, 22, true) DisableControlAction(0, 44, true) DisableControlAction(0, 37, true) DisableControlAction(0, 23, true) DisableControlAction(0, 288, true) DisableControlAction(0, 289, true) DisableControlAction(0, 170, true) DisableControlAction(0, 167, true) DisableControlAction(0, 73, true) DisableControlAction(2, 199, true) DisableControlAction(0, 47, true) DisableControlAction(0, 264, true) DisableControlAction(0, 257, true) DisableControlAction(0, 140, true) DisableControlAction(0, 141, true) DisableControlAction(0, 142, true) DisableControlAction(0, 143, true) end
function DisplayText(msg) BeginTextCommandDisplayHelp('STRING') AddTextComponentSubstringPlayerName(msg) EndTextCommandDisplayHelp(0, false, true, -1) end

Citizen.CreateThread(function()
    while true do
        if doingit then
            DisableControl()
            Citizen.Wait(1)
        else
            Citizen.Wait(1000)
        end
    end
end)

function CanHack()
    ESX.TriggerServerCallback("utk_creditHack", function(result)
        if result == true then
            DoIt()
        else
            exports["mythic_notify"]:SendAlert("error", result, 6000)
        end
    end)
end

function DoIt()
    doingit = true
    SetEntityHeading(PlayerPedId(), 34.79)
    FreezeEntityPosition(PlayerPedId(), true)
    TaskStartScenarioAtPosition(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", GetEntityCoords(PlayerPedId()), 34.79, 0, 0, 1)
    Citizen.Wait(2000)
    exports["mythic_notify"]:SendAlert("success", "Find the correct codes!", 4500)
    TriggerEvent("mhacking:show")
    TriggerEvent("mhacking:start", 5, 15, PhoneHacking)
end

function PhoneHacking(output, time)
    if output then
        TriggerEvent('mhacking:hide')
        local animped = PlayerPedId()

        RequestAnimDict("anim@amb@warehouse@laptop@")
        while not HasAnimDictLoaded("anim@amb@warehouse@laptop@") do
            RequestAnimDict("anim@amb@warehouse@laptop@")
            Citizen.Wait(10)
        end
        ClearPedTasksImmediately(animped)
        SetEntityCoords(animped, 1272.40, -1711.64, 53.77, 1, 0, 0, 1)
        SetEntityHeading(animped, 34.79)
        TaskPlayAnim(animped, "anim@amb@warehouse@laptop@", "enter", 8.0, 8.0, 0.1, 0, 1, false, false, false)
        Citizen.Wait(600)
        TaskPlayAnim(animped, "anim@amb@warehouse@laptop@", "idle_a", 8.0, 8.0, -1, 1, 1, false, false, false)
        Citizen.Wait(2500)
        exports["mythic_notify"]:SendAlert("success", "Match the sticks with white line!", 4500)
        exports["datacrack"]:Start(4.7)
    else
        TriggerEvent('mhacking:hide')
        ClearPedTasks(animped)
        exports["mythic_notify"]:SendAlert("error", "You have failed!", 4500)
        doingit = false
    end
end

AddEventHandler("datacrack", function(success)
    doingit = false
    FreezeEntityPosition(PlayerPedId(), false)
    ClearPedTasks(PlayerPedId())
    if success then
        exports["mythic_notify"]:SendAlert("success", "Success!", 4500)
        TriggerServerEvent("utk_creditHack")
    else
        exports["mythic_notify"]:SendAlert("error", "You have failed!", 4500)
    end
end)
