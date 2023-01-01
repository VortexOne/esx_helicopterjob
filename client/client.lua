--No touchy touchy or else script breaks.
ESX = nil

inMissionOne = false
inMissionTwo = false
inDropArea = false
inLoadingArea = false
enableSubtitles = false
veh = nil
pickupVeh = Config.pickupVeh
createdPickupVeh = nil
checkVeh = nil
destBlip = nil
destBlipRadius = nil
dest = nil
object_model = "prop_box_wood02a_pu"
object_modelTwo = "p_cargo_chute_s"
flare = nil
payment = nil
disableControls = nil

announcestring = false
lastfor = 5
msg = _U('deliveredBannerText')


if Config.useEsxLegacy then
    Citizen.CreateThread(function()
        while ESX == nil do
            ESX = exports["es_extended"]:getSharedObject()
            Citizen.Wait(1)
        end

        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end

        ESX.PlayerData = ESX.GetPlayerData()
        StartHelicopterJob()
    end)
else
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    
        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(100)
        end
    
        ESX.PlayerData = ESX.GetPlayerData()
        StartHelicopterJob()
    end)
end

-- Here u can touch but careful :D
function StartHelicopterJob()
    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        --Blip
        if Config.showBlip == true then
            local blip = AddBlipForCoord(Config.StartPos)
            SetBlipSprite(blip, 64)
            SetBlipColour(blip, 24)
            SetBlipAsShortRange(blip, true)
            SetBlipScale(blip, 0.9)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Config.blipName)
            EndTextCommandSetBlipName(blip)
        end

        while true do
            local coords = GetEntityCoords(ped)
            local dist = GetDistanceBetweenCoords(coords, Config.StartPos, true)
            local distHangar = GetDistanceBetweenCoords(coords, Config.HelipadCoords, true)
            if distHangar <= Config.HelipadRadius and DoesEntityExist(veh) and IsPedInVehicle(ped, veh, false) then
                --ESX.ShowHelpNotification('Drücke ~INPUT_CONTEXT~ um den Job zu beenden.')
                --if IsControlJustReleased(1, 51) then
                    endJob()
                    --print("Heli Job beendet")
                    Citizen.Wait(500)
                --end
            end
            if dist <= 25.0 then
                DrawMarker(34, Config.StartPos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 211, 252, 3, 255, false, true, 2, false)
                if dist <= 3.0 then
                    if not inMissionOne then
                        ESX.ShowHelpNotification(_U('startJob'))
                        if IsControlJustReleased(1, 51) then
                            --print("Job started")
                            spawnVeh()
                            startJob()
                            Citizen.Wait(1000)
                        end
                    else
                        ESX.ShowHelpNotification(_U('endJob'))
                        if IsControlJustReleased(1, 51) then
                            endJob()
                            --print("Job ended")
                            Citizen.Wait(500)
                        end
                    end
                end
            end
            Citizen.Wait(1)
        end
    end)
end

function spawnVeh()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
        ESX.Game.SpawnVehicle(Config.vehicle, Config.Spawn, Config.SpawnHeading, function(heli)
            while not DoesEntityExist(heli) do
                Citizen.Wait(1)
            end
            TaskWarpPedIntoVehicle(ped, heli, -1)
            veh = heli
        end)
end

function startJob()
    inMissionOne = true
    enableSubtitles = false
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    GenerateDest()
    Citizen.CreateThread(function()
        while dest == nil do
            --print("Waiting for generated dest")
            Citizen.Wait(0)
        end
        -- Create the mission destination blip
        destBlip = AddBlipForCoord(dest)
        SetBlipSprite(destBlip, 1)
        SetBlipColour(destBlip, 60)
        SetBlipAsShortRange(destBlip, false)
        SetBlipScale(destBlip, 1.1)
        SetBlipFlashTimer(destBlip, 7000)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(Config.DestBlipName)
        EndTextCommandSetBlipName(destBlip)

        destBlipRadius = AddBlipForRadius(dest, 100.0)
        SetBlipColour(destBlipRadius, 60)
        SetBlipAlpha(destBlipRadius, 128)
        SetBlipAsShortRange(destBlipRadius, true)
        CheckMission()
    end)
end

function endJob()
    local ped = PlayerPedId(-1)
    SetEntityCoords(ped, Config.HelipadCoords, 0.0, 0.0, 0.0, false)
    inMissionOne = false
    inMissionTwo = false
    enableSubtitles = false
    disableControls = false
    checkVeh = false
    RemoveBlip(destBlip)
    RemoveBlip(destBlipRadius)
    destBlip = nil
    destBlipRadius = nil
    dest = nil
    ESX.Game.DeleteVehicle(veh)
    DeleteEntity(createdPickupVeh)
    veh = nil
    exports['okokNotify']:Alert(_U('jobNotifyTitle'), _U('endJobNotify'), 5000, 'info')

end

function failJob()
    inMissionOne = false
    inMissionTwo = false
    enableSubtitles = false
    disableControls = false
    checkVeh = false
    RemoveBlip(destBlip)
    RemoveBlip(destBlipRadius)
    destBlip = nil
    destBlipRadius = nil
    dest = nil
    ESX.Game.DeleteVehicle(veh)
    DeleteEntity(createdPickupVeh)
    veh = nil
    TriggerServerEvent('helicopterJob:jobFailed')
end

function CheckMission()
    checkVeh = true
    CheckVehDestroyed()
    Citizen.CreateThread(function()
        if dest == nil then
            GenerateDest()
            while dest == nil do
                --print("Waiting for generated dest")
                Citizen.Wait(0)
            end
        end
        inMissionOne = true
        enableSubtitles = true
        DrawSubtitles(_U('flyOrReturnToHangar'))
        --print("Check Mission started")
        local ped = PlayerPedId()
        inDropArea = false
        disableControls = true
        local destX, destY, destZ = table.unpack(dest)
        SetPtfxAssetNextCall("core")
        flare = StartParticleFxLoopedAtCoord("exp_grd_flare", destX, destY, destZ, 0.0, 0.0, 0.0, 4.0, false, false, false, false)
        SetParticleFxLoopedAlpha(flare, 1.0)
		SetParticleFxLoopedColour(flare, 235, 149, 52, 0)
        local pickupVehHash = nil
        pickupVehHash = GetHashKey(pickupVeh)
        while pickupVehHash == nil do
            Citizen.Wait(0)
            --print("Waiting for Hash Key...")
        end
        if not IsModelInCdimage(pickupVehHash) then return end
        RequestModel(pickupVehHash)
        while not HasModelLoaded(pickupVehHash) do 
        Citizen.Wait(10)
        end
        createdPickupVeh = CreateVehicle(pickupVehHash, destX, destY, destZ, 230, false, thisScriptCheck)
        SetModelAsNoLongerNeeded(pickupVehHash)

        DisableControls()
        while inMissionOne do
            ----print("while loop (re)started")
            local coords = GetEntityCoords(ped)
            local dist = GetDistanceBetweenCoords(coords, dest, false)
            if not inDropArea then
                --if dist < 150.0 and not flareStarted then
    
                --end
                if dist <= 100.0 then
                    --print("In loading area")
                    inDropArea = true
                    MissionPrompt()
                else
                    inDropArea = false
                end
            end
            if dist > 100.0 then
                inDropArea = false
            end
            Citizen.Wait(10)
        end
    end)
end

function MissionPrompt()
    --print("Mission Prompt started")
    Citizen.CreateThread(function()
        enableSubtitles = false
        local started = false
        while inDropArea do
            if inDropArea then
                if not started then
                    ESX.ShowHelpNotification(_U('dropPrompt'))
                    if IsControlJustReleased(1, 51) then
                        --print("Started loading")
                        inMissionOne = false
                        started = true
                        enableSubtitles = true

                        create_object()

                        PlaySoundFrontend(-1, "Friend_Deliver", "HUD_FRONTEND_MP_COLLECTABLE_SOUNDS", 1)
                        enableSubtitles = false
                        inMissionTwo = true
                        inDropArea = false
                        StopParticleFxLooped(flare, 0)
                        exports['okokNotify']:Alert(_U('jobNotifyTitle'), _U('paymentReceivedNotify', payment), 5000, 'success')
                        exports['okokNotify']:Alert(_U('jobNotifyTitle'), _U('flyOrReturnToHangarNotify'), 10000, 'neutral')
                        
                        TriggerServerEvent('helicopterJob:jobFinished', payment)
                        CheckMissionTwo()
                    end
                end
            end
            Citizen.Wait(1)
        end
    end)
end

function CheckMissionTwo()
    --print("Check Mission Two started")
    Citizen.CreateThread(function()
        inMissionTwo = true
        enableSubtitles = true
        DrawSubtitles(_U('flyBack'))

        SetBlipCoords(destBlip, Config.LoadDestination)
        SetBlipAlpha(destBlipRadius, 0)
        SetBlipCoords(destBlipRadius, Config.LoadDestination)

        local ped = PlayerPedId()
        inLoadingArea = false
        while inMissionTwo do
            local coords = GetEntityCoords(ped)
            local dist = GetDistanceBetweenCoords(coords, Config.LoadDestination, true)
            if not inLoadingArea then
                if dist <= 15.0 then
                    --print("In loading Area")
                    inLoadingArea = true
                    MissionPromptTwo()
                else
                    inLoadingArea = false
                end
            end
            if dist > 15.0 then
                inLoadingArea = false
            end
            Citizen.Wait(10)
        end
    end)
end

function MissionPromptTwo()
    --print("Missipn Prompt Two started")
    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        local startedTwo = false
    
        while inLoadingArea do
            if inLoadingArea then
                enableSubtitles = false
                if not startedTwo then
                    ESX.ShowHelpNotification(_U('startLoading'))
                    if IsControlJustReleased(1, 51) then
                        DeleteEntity(createdPickupVeh)
                        --print("Started loading")
                        inMissionTwo = false
                        startedTwo = true
                        enableSubtitles = true
                        DrawSubtitles(_U('loadingInProgress'))
                        FreezeEntityPosition(veh, true)
                        SetVehicleEngineOn(veh, false, false, true)

                        exports['an_progBar']:run(Config.LoadTime,_U('loadingProgressBar'),'#b5e31e')

                        Citizen.Wait(Config.LoadTime * 1000 - 10)
                        SetVehicleEngineOn(veh, true, false, false)
                        FreezeEntityPosition(veh, false)
                        enableSubtitles = false
                        inMissionTwo = false
                        inLoadingArea = false
                        dest = nil

                        --exports['okokNotify']:Alert(_U('jobNotifyTitle'), _U('paymentReceivedNotify', payment), 5000, 'success')
                        --exports['okokNotify']:Alert(_U('jobNotifyTitle'), _U('flyOrReturnToHangarNotify'), 10000, 'neutral')
                        
                        --TriggerServerEvent('helicopterJob:jobFinished', payment)
                        payment = nil
                        GenerateDest()
                        while dest == nil do
                            --print("Waiting for generated dest")
                            Citizen.Wait(0)
                        end
                        SetBlipCoords(destBlip, dest)
                        SetBlipCoords(destBlipRadius, dest)
                        SetBlipAlpha(destBlipRadius, 128)
                        CheckMission()
                        --PlaySoundFrontend(-1, "Mission_pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
                    end
                end
            end
            Citizen.Wait(1)
        end
    end)
end

function DrawSubtitles(text1)
    text = text1
    Citizen.CreateThread(function()
        while enableSubtitles do
        DrawTextOnScreen(text)
        Citizen.Wait(1)
        end
    end)
end

function GenerateDest()
    local random = math.random(1,3)
    if random == 1 then
        dest = Config.Destination
        payment = Config.Payment1
    elseif random == 2 then
        dest = Config.Destination2
        payment = Config.Payment2
    elseif random == 3 then
        dest = Config.Destination3
        payment = Config.Payment3
    end
    --print("Destination generated: " .. random)
end

function CheckVehDestroyed()
    Citizen.CreateThread(function()
        while checkVeh and checkVeh ~= nil do
            local exists = DoesEntityExist(veh)
            if exists then
                local vehHealth = GetVehicleEngineHealth(veh)
                local drivable = IsVehicleDriveable(veh, true)
                if vehHealth <= 0 or not drivable then
                    --print("Job failed")
                    if Config.fineAmount >= 2 then
                    failJob()
                    else
                    endJob()
                    end
                end
            end
            Citizen.Wait(200)
        end
    end)
end
function DrawTextOnScreen(text)
    SetTextProportional(0)
    SetTextFont(0)
    SetTextEntry("STRING")
    SetTextColour(255, 255, 255, 255)
    SetTextScale(1.0, 0.45)
    SetTextOutline()
    AddTextComponentString(text)
    SetTextCentre(true)
    DrawText(0.5, 0.9)
end

function DisableControls()
    Citizen.CreateThread(function()
        while disableControls do
            DisableControlAction(1, 49, true)
            DisableControlAction(1, 75, true)
            Wait(1)
        end
        EnableControlAction(1, 49, true)
        EnableControlAction(1, 75, true)
    end)
end

-- No touchy touchy from here
RegisterNetEvent('helicopterJob:banner')
announcestring = false
AddEventHandler('helicopterJob:banner', function(msg)
	announcestring = msg
	PlaySoundFrontend(-1, "Friend_Deliver", "HUD_FRONTEND_MP_COLLECTABLE_SOUNDS", 1)
	Citizen.Wait(lastfor * 1000)
	announcestring = false
end)

function Initialize(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
	PushScaleformMovieFunctionParameterString(_U('deliveredBanner'))
    PushScaleformMovieFunctionParameterString(announcestring)
    PopScaleformMovieFunctionVoid()
    return scaleform
end


Citizen.CreateThread(function()
while true do
	Citizen.Wait(0)
    if announcestring then
		scaleform = Initialize("mp_big_message_freemode")
		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end
end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    if DoesEntityExist(veh) then
    ESX.Game.DeleteVehicle(veh)
    end
    DeleteEntity(createdPickupVeh)
    --print(resourceName .. ' was stopped or restarted.')
  end)

function create_object()
    Citizen.CreateThread(function()
        RequestModel(object_model)
        local iter_for_request = 1
        while not HasModelLoaded(object_model) and iter_for_request < 5 do
            Citizen.Wait(500)				
            iter_for_request = iter_for_request + 1
        end
        if not HasModelLoaded(object_model) then
            SetModelAsNoLongerNeeded(object_model)
            print("ERROR: Prop could not be spawned.")
        else
            local ped = PlayerPedId()
            local x,y,z = table.unpack(GetEntityCoords(ped))
            local created_object = CreateObjectNoOffset(object_model, x, y, z - 3.0, 1, 1, 1)
            SetEntityLodDist(created_object, 500)
            ActivatePhysics(created_object)
            SetDamping(created_object, 2, 0.1)
            SetEntityVelocity(created_object, 0.0, 0.0, -0.2)
            --SetModelAsNoLongerNeeded(object_model)

            local created_objectTwo = CreateObjectNoOffset(object_modelTwo, x, y, z - 3.0, 1, 1, 1)
            SetEntityLodDist(created_objectTwo, 1000)
            SetEntityVelocity(created_objectTwo, 0.0, 0.0, -0.2)

            AttachEntityToEntity(created_objectTwo, created_object, 0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

            Citizen.Wait(10000)
            DetachEntity(created_objectTwo, 1, 1)
            DeleteEntity(created_object)
            DeleteEntity(created_objectTwo)
            SetEntityAsNoLongerNeeded(created_object)
            SetEntityAsNoLongerNeeded(created_objectTwo)
            SetModelAsNoLongerNeeded(object_model)
            SetModelAsNoLongerNeeded(object_modelTwo)
          end
      end)
 end
--[[
RegisterCommand('testBanner', function(rawCommand)
TriggerServerEvent('helicopterJob:jobFinished')
end)
]]--