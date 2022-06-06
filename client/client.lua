local QBCore = exports['qb-core']:GetCoreObject()
local mugshotInProgress, createdCamera, MugshotArray, playerData = false, 0, {}, nil
local handle, board, board_scaleform, overlay, ped, pedcoords, x, y, z, r, suspectheading, suspectx, suspecty, suspectz, board_pos

if Config.CustomMLO then
    x = Config.MugShotCamera.x
    y = Config.MugShotCamera.y
    z = Config.MugShotCamera.z
    r = Config.MugShotCamera.r
    suspectheading = Config.MugshotSuspectHeading
    suspectx = Config.MugshotLocation.x
    suspecty = Config.MugshotLocation.y
    suspectz = Config.MugshotLocation.z
else
    x = 403.0
    y = -998.08
    z = -98.5
    r = {x = 0.0, y = 0.0, z = 359.66}
    suspectheading = 179.99
    suspectx = 403.01
    suspecty = -996.3
    suspectz = -100.0
end

local function TakeMugShot()
    exports['screenshot-basic']:requestScreenshotUpload(Config.Webhook, 'files[]', {encoding = 'jpg'}, function(data)
        local resp = json.decode(data)
        table.insert(MugshotArray, resp.attachments[1].url)
    end)
end

local function PhotoProcess(ped)
    local rotation = suspectheading
    for photo = 1, Config.Photos, 1 do
        Wait(Config.WaitTime)
        TakeMugShot()
        PlaySoundFromCoord(-1, "SHUTTER_FLASH", x, y, z, "CAMERA_FLASH_SOUNDSET", true, 5, 0)
        Wait(Config.WaitTime)
        rotation = rotation - 90.0
        SetEntityHeading(ped, rotation)
    end
end

local function MugShotCamera()
    if createdCamera ~= 0 then
        DestroyCam(createdCamera, 0)
        createdCamera = 0
    end
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamCoord(cam, x, y, z)
    SetCamRot(cam, r.x, r.y, r.z, 2)
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
	for k, v in ipairs(args) do
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

local function PrepBoard()
    CreateThread(function()
        board_scaleform = LoadScaleform("mugshot_board_01")
        handle = CreateNamedRenderTargetForModel("ID_Text", `prop_police_id_text`)
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
    end)
end

local function MakeBoard()
    title = Config.BoardHeader
    center = playerData.charinfo.firstname.. " ".. playerData.charinfo.lastname
    footer = playerData.citizenid
    header = playerData.charinfo.birthdate
	CallScaleformMethod(board_scaleform, 'SET_BOARD', title, center, footer, header, 0, 1337, 116)
end

local function PlayerBoard()
	RequestModel(`prop_police_id_board`)
	RequestModel(`prop_police_id_text`)
	while not HasModelLoaded(`prop_police_id_board`) or not HasModelLoaded(`prop_police_id_text`) do 
        Wait(1) 
    end
	board = CreateObject(`prop_police_id_board`, pedcoords, true, true, false)
	overlay = CreateObject(`prop_police_id_text`, pedcoords, true, true, false)
	AttachEntityToEntity(overlay, board, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
	SetModelAsNoLongerNeeded(`prop_police_id_board`)
	SetModelAsNoLongerNeeded(`prop_police_id_text`)
    SetCurrentPedWeapon(ped, `weapon_unarmed`, 1)
	ClearPedWetness(ped)
	ClearPedBloodDamage(ped)
	AttachEntityToEntity(board, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)
end

local function DestoryCamera()
    DestroyCam(createdCamera, 0)
    RenderScriptCams(0, 0, 1, 1, 1)
    SetFocusEntity(GetPlayerPed(ped))
    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, false)
    DeleteObject(overlay)
    DeleteObject(board)
    handle = nil
    createdCamera = 0
end

RegisterNetEvent('cqc-mugshot:client:trigger', function()
    ped = PlayerPedId()
    pedcoords = GetEntityCoords(ped)
    CreateThread(function()
        playerData = QBCore.Functions.GetPlayerData()
        MugshotArray, mugshotInProgress = {}, true
        local citizenid = playerData.citizenid
        local animDict = 'mp_character_creation@lineup@male_a'
        QBCore.Functions.RequestAnimDict(animDict)
        PrepBoard()
        Wait(250)
        MakeBoard()
        MugShotCamera()
        SetEntityCoords(ped,suspectx, suspecty, suspectz)
        SetEntityHeading(ped,suspectheading)
        PlayerBoard()
        TaskPlayAnim(ped, animDict, "loop_raised", 8.0, 8.0, -1, 49, 0, false, false, false)
        PhotoProcess(ped)
        if createdCamera ~= 0 then
            DestoryCamera()
            SetEntityHeading(suspectheading, ped)
            ClearPedSecondaryTask(GetPlayerPed(ped))
        end
        if Config.CQCMDT then
            TriggerServerEvent('cqc-mugshot:server:MDTupload', playerData.citizenid, MugshotArray)
        end
        if Config.CustomMLO == false then
            SetEntityCoords(ped, pedcoords.x, pedcoords.y, pedcoords.z)
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
    RegisterCommand("testmugshot", function(source)
        local player, distance = QBCore.Functions.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
        if player ~= -1 and distance < 2.0 then
            local playerId = GetPlayerServerId(player)
            TriggerServerEvent('cqc-mugshot:server:triggerSuspect', playerId)
        end
    end, false)
    RegisterCommand("testmugshotself", function(source)
        TriggerEvent('cqc-mugshot:client:trigger')
    end, false)
end