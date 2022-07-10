local QBCore = exports['qb-core']:GetCoreObject()

local mugshotInProgress, createdCamera, MugshotArray

local PoliceTextBoard = 'prop_police_id_text'
local PoliceIDBoard = 'prop_police_id_board'

local x = Config.MugShotCamera.x
local y = Config.MugShotCamera.y
local z = Config.MugShotCamera.z
local r = Config.MugShotCamera.r
local suspectheading = Config.MugshotSuspectHeading
local suspectx = Config.MugshotLocation.x
local suspecty = Config.MugshotLocation.y
local suspectz = Config.MugshotLocation.z

local CMx = 403.0
local CMy = -998.08
local CMz = -98.5
local CMr = {x = 0.0, y = 0.0, z = 359.66}
local CMsuspectheading = 179.99
local CMsuspectx = 403.01
local CMsuspecty = -996.3
local CMsuspectz = -100.0

local function TakeMugShot()
    exports['screenshot-basic']:requestScreenshotUpload(Config.Webhook, 'files[]', {encoding = 'jpg'}, function(data)
        local resp = json.decode(data)
        table.insert(MugshotArray, resp.attachments[1].url)
    end)
end

local function PhotoProcess()
    local ped = PlayerPedId()
    if Config.CustomMLO == true then
        rotation = suspectheading
    else
        rotation = CMsuspectheading
    end
    for _ = 1, Config.Photos, 1 do
        Wait(Config.WaitTime)
        TakeMugShot()
        PlaySoundFromCoord(-1, "SHUTTER_FLASH", x, y, z, "CAMERA_FLASH_SOUNDSET", true, 5, 0)
        Wait(Config.WaitTime)
        rotation = rotation - 90.0
        SetEntityHeading(ped, rotation)
    end
end

local function MugShotCamera()
    local ped = PlayerPedId()
    if createdCamera ~= 0 then
        DestroyCam(createdCamera, 0)
        createdCamera = 0
    end
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    if Config.CustomMLO == false then
        SetCamCoord(cam, x, y, z)
        SetCamRot(cam, r.x, r.y, r.z, 2)
    else
        SetCamCoord(cam, CMx, CMy, CMz)
        SetCamRot(cam, CMr.x, CMr.y, CMr.z, 2)
    end
    RenderScriptCams(1, 0, 0, 1, 1)
    Wait(250)
    createdCamera = cam
    CreateThread(function()
        FreezeEntityPosition(ped, true)
        SetPauseMenuActive(false)
        while mugshotInProgress do
            DisableAllControlActions(0)
            EnableControlAction(0, 249, true)
            EnableControlAction(0, 46, true)
            Wait(1)
        end
    end)
end

local function CreateNamedRenderTargetForModel(name, model)
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end
	return handle
end

local function LoadScaleform (scaleform)
	local handle = RequestScaleformMovie(scaleform)
	if handle ~= 0 then
		while not HasScaleformMovieLoaded(handle) do
			Wait(0)
		end
	end
	return handle
end

local function CallScaleformMethod (scaleform, method, ...)
	local t
	local args = { ... }
	BeginScaleformMovieMethod(scaleform, method)
	for _, v in ipairs(args) do
		t = type(v)
		if t == 'string' then
			PushScaleformMovieMethodParameterString(v)
		elseif t == 'number' then
			if string.match(tostring(v), "%.") then
				PushScaleformMovieFunctionParameterFloat(v)
			else
				PushScaleformMovieFunctionParameterInt(v)
			end
		elseif t == 'boolean' then
			PushScaleformMovieMethodParameterBool(v)
		end
	end
	EndScaleformMovieMethod()
end

RegisterNetEvent('cqc-mugshot:client:trigger', function()
    local ped = PlayerPedId()
    local pedcoords = GetEntityCoords(ped)
    CreateThread(function()
        local playerData = QBCore.Functions.GetPlayerData()
        MugshotArray, mugshotInProgress = {}, true
        local animDict = 'mp_character_creation@lineup@male_a'
        QBCore.Functions.RequestAnimDict(animDict)
        local board_scaleform = LoadScaleform("mugshot_board_01")
        local handle = CreateNamedRenderTargetForModel("ID_Text", PoliceTextBoard)
        while handle do
            HideHudAndRadarThisFrame()
            SetTextRenderId(handle)
            Set_2dLayer(4)
            SetScriptGfxDrawBehindPausemenu(1)
            DrawScaleformMovie(board_scaleform, 0.405, 0.37, 0.81, 0.74, 255, 255, 255, 255, 0)
            SetScriptGfxDrawBehindPausemenu(0)
            SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            SetScriptGfxDrawBehindPausemenu(1)
            SetScriptGfxDrawBehindPausemenu(0)
            Wait(0)
        end
        Wait(250)
        local title = Config.BoardHeader
        local center = playerData.charinfo.firstname.. " ".. playerData.charinfo.lastname
        local footer = playerData.citizenid
        local header = playerData.charinfo.birthdate
        CallScaleformMethod(board_scaleform, 'SET_BOARD', title, center, footer, header, 0, 1337, 116)
        MugShotCamera()
        if Config.CustomMLO == true then
            SetEntityCoords(ped, CMsuspectx, CMsuspectz, CMsuspecty)
            SetEntityHeading(ped, CMsuspectheading)
        else
            SetEntityCoords(ped, suspectx, suspectz, suspecty)
            SetEntityHeading(ped, suspectheading)
        end
        RequestModel(PoliceIDBoard)
        RequestModel(PoliceTextBoard)
        while not HasModelLoaded(PoliceIDBoard) or not HasModelLoaded(PoliceTextBoard) do
            Wait(1)
        end
        local board = CreateObject(PoliceIDBoard, pedcoords, true, true, false)
        local overlay = CreateObject(PoliceTextBoard, pedcoords, true, true, false)
        AttachEntityToEntity(overlay, board, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        SetModelAsNoLongerNeeded(PoliceIDBoard)
        SetModelAsNoLongerNeeded(PoliceTextBoard)
        SetCurrentPedWeapon(ped, 'weapon_unarmed', 1)
        ClearPedWetness(ped)
        ClearPedBloodDamage(ped)
        AttachEntityToEntity(board, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)
        TaskPlayAnim(ped, animDict, "loop_raised", 8.0, 8.0, -1, 49, 0, false, false, false)
        PhotoProcess(ped)
        if createdCamera ~= 0 then
            DestroyCam(createdCamera, 0)
            RenderScriptCams(0, 0, 1, 1, 1)
            SetFocusEntity(GetPlayerPed(ped))
            ClearPedTasksImmediately(ped)
            FreezeEntityPosition(ped, false)
            DeleteObject(overlay)
            DeleteObject(board)
            handle = nil
            createdCamera = 0
            if Config.CustomMLO == true then
                SetEntityHeading(ped, CMsuspectheading)
            else
                SetEntityHeading(ped, suspectheading)
            end
            ClearPedSecondaryTask(GetPlayerPed(ped))
        end
        if Config.CQCMDT then
            TriggerServerEvent('cqc-mugshot:server:MDTupload', playerData.citizenid, MugshotArray)
        end
        if Config.CustomMLO == false then
            SetEntityCoords(ped, pedcoords.x, pedcoords.z, pedcoords.y)
        end
        mugshotInProgress = false
    end)
end)

RegisterNetEvent("cqc-mugshot:client:takemugshot",function()
    local player, distance = QBCore.Functions.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
    if player ~= -1 and distance < 2.0 then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent('cqc-mugshot:server:triggerSuspect', playerId)
    end
end)

if Config.TestCommand then
    RegisterCommand("testmugshot", function()
        local player, distance = QBCore.Functions.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
        if player ~= -1 and distance < 2.0 then
            local playerId = GetPlayerServerId(player)
            TriggerServerEvent('cqc-mugshot:server:triggerSuspect', playerId)
        end
    end, false)
    RegisterCommand("testmugshotself", function()
        TriggerEvent('cqc-mugshot:client:trigger')
    end, false)
end