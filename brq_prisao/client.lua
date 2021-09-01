local IsPreso = false

TeleportFunction = function()
    local ped = PlayerPedId()
    DoScreenFadeOut(1000)
    Wait(1000)
    SetEntityCoords(ped, coord)
    IsPreso = true
    Wait(100)
    DoScreenFadeIn(1000)
    RemoveAllPedWeapons(ped, true)
end

CreateThread(function()
    repeat
        if IsPreso then
            TriggerServerEvent('diminuirPena')
        end
        Wait(60 * 1000)
    until false
end)

CreateThread(function()
    repeat
        local ped = PlayerPedId()
        if IsPreso then
            if #(GetEntityCoords(ped) - vec3(1690.666015625,2591.146484375,45.914390563965)) > 201 then
                DoScreenFadeOut(1000)
                Wait(1000)
                SetEntityCoords(ped, coord)
                Wait(100)
                DoScreenFadeIn(1000)
                TriggerServerEvent('fugindo')
            end
        end
        Wait(3 * 1000)
    until false
end)

CreateThread(function()
    repeat
        sleep = 1000
        if IsPreso then
            sleep = 5
            BlockWeaponWheelThisFrame()
			DisableControlAction(0,21,true)
			DisableControlAction(0,22,true)
			DisableControlAction(0,24,true)
			DisableControlAction(0,25,true)
			DisableControlAction(0,29,true)
			DisableControlAction(0,32,true)
			DisableControlAction(0,33,true)
			DisableControlAction(0,34,true)
			DisableControlAction(0,35,true)
			DisableControlAction(0,56,true)
			DisableControlAction(0,58,true)
			DisableControlAction(0,73,true)
			DisableControlAction(0,75,true)
			DisableControlAction(0,140,true)
			DisableControlAction(0,141,true)
			DisableControlAction(0,142,true)
			DisableControlAction(0,143,true)
			DisableControlAction(0,166,true)
			DisableControlAction(0,167,true)
			DisableControlAction(0,170,true)
			DisableControlAction(0,177,true)
			DisableControlAction(0,182,true)
			DisableControlAction(0,187,true)
			DisableControlAction(0,188,true)
			DisableControlAction(0,189,true)
			DisableControlAction(0,190,true)
			DisableControlAction(0,243,true)
			DisableControlAction(0,245,true)
			DisableControlAction(0,246,true)
			DisableControlAction(0,257,true)
			DisableControlAction(0,263,true)
			DisableControlAction(0,264,true)
			DisableControlAction(0,268,true)
			DisableControlAction(0,269,true)
			DisableControlAction(0,270,true)
			DisableControlAction(0,271,true)
			DisableControlAction(0,288,true)
			DisableControlAction(0,289,true)
			DisableControlAction(0,303,true)
			DisableControlAction(0,311,true)
			DisableControlAction(0,344,true)
        end
        Wait(sleep)
    until false
end)

RegisterNetEvent('brq:teleportarprisao')
AddEventHandler('brq:teleportarprisao',TeleportFunction)

RegisterNetEvent('brq:setIsPresoFalse')
AddEventHandler('brq:setIsPresoFalse', function()
    IsPreso = false
    local ped = PlayerPedId()
    DoScreenFadeOut(1000)
    Wait(1000)
    SetEntityCoords(ped, exitcoord)
    TriggerEvent('Notify', 'sucesso', 'Você foi liberto, não cometa mais crimes!')
    Wait(100)
    DoScreenFadeIn(1000)
end)


-- CreateThread(function()
--     repeat
--         print( #(GetEntityCoords(PlayerPedId()) - vec3(1690.666015625,2591.146484375,45.914390563965)) )
--         Wait(1)
--     until false
-- end)