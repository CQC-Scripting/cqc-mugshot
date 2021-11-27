local QBCore = exports['qb-core']:GetCoreObject()
local mugshotInProgress, createdCamera, MugshotArray, playerData = false, 0, {}, nil
local handle, board
local player = GetPlayerPed(PlayerPedId())
local playerCoords = GetEntityCoords(player)
local board_pos = vector3(playerCoords.x, playerCoords.y, playerCoords.z)
local board_scaleform, overlay

local function MugShotInProgress()
    CreateThread(function()
        while mugshotInProgress do
            DisableAllControlActions(0)
            EnableControlAction(0, 249, true)
            EnableControlAction(0, 46, true)
            Wait(1)
        end
    end)
end

local function TakeMugShot()
    exports['screenshot-basic']:requestScreenshotUpload(Config.Webhook, 'files[]', {encoding = 'jpg'}, function(data)
        local resp = json.decode(data)
        table.insert(MugshotArray, resp.attachments[1].url)
    end)
end

local function PhotoProcess(suspect)
    PhotoTaken = false
    local rotation = Config.MugshotHeading
    for photo = 1, Config.Photos, 1 do
        Wait(Config.WaitTime)
        TakeMugShot()
        Wait(Config.WaitTime)
        rotation = rotation - 90.0
        SetEntityHeading(suspect, rotation)
    end
end

local function MugShotCamera()
    x = Config.MugShotCamera.x
    y = Config.MugShotCamera.y
    z = Config.MugShotCamera.z
    r = Config.MugShotCamera.r

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
	local ped = PlayerPedId()
	RequestModel(`prop_police_id_board`)
	RequestModel(`prop_police_id_text`)
	RequestAnimDict(lineup_male)
	while not HasModelLoaded(`prop_police_id_board`) or not HasModelLoaded(`prop_police_id_text`) do Wait(1) end
	board = CreateObject(`prop_police_id_board`, board_pos, false, true, false)
	overlay = CreateObject(`prop_police_id_text`, board_pos, false, true, false)
	AttachEntityToEntity(overlay, board, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
	SetModelAsNoLongerNeeded(`prop_police_id_board`)
	SetModelAsNoLongerNeeded(`prop_police_id_text`)
	ClearPedWetness(ped)
	ClearPedBloodDamage(ped)
	SetCurrentPedWeapon(ped, `weapon_unarmed`, 1)
	AttachEntityToEntity(board, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)
end

RegisterNetEvent('cqc-mugshot:client:trigger', function(suspect)
    CreateThread(function()
        playerData = QBCore.Functions.GetPlayerData()
        local animDict = 'mp_character_creation@lineup@male_a'
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(100)
        end
        PrepBoard()
        Wait(100)
        MakeBoard()
        MugShotCamera()
        MugshotArray = {}
        mugshotInProgress = true
        local suspect = PlayerPedId()
        SetEntityCoords(suspect, Config.MugshotLocation.x, Config.MugshotLocation.y, Config.MugshotLocation.z)
        SetEntityHeading(suspect, Config.MugshotHeading)
        MugShotInProgress()
        PlayerBoard()
        TaskPlayAnim(suspect, animDict, "loop_raised", 8.0, 8.0, -1, 49, 0, false, false, false)
        PhotoProcess(suspect)
        FreezeEntityPosition(suspect, true)
        mugshotInProgress = false
        if createdCamera ~= 0 then
            DestroyCam(createdCamera, 0)
            RenderScriptCams(0, 0, 1, 1, 1)
            SetFocusEntity(GetPlayerPed(PlayerId()))
            ClearPedTasksImmediately(PlayerPedId())
            FreezeEntityPosition(PlayerPedId(), false)
            createdCamera = 0
            ClearPedSecondaryTask(GetPlayerPed(-1))
            DeleteObject(overlay)
            DeleteObject(board)
            handle = nil
        end
    end)
end)