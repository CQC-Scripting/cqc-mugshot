# CC-FUEL

CQC-Mugshot is a mugshot system for use with QB servers to allow players to take pictures of suspects have them uploaded to a webhook.
<br>
<h1>INSTALLATION GUIDE</h1>

1. Add the cqc-mugshot folder into your resources folder
2. Add The Following Line to qb-target>config.lua change the location etc as needed

```lua
-- CC-Fuel
['CQCMugshot'] = {
		name = 'CQCMugshot',
		coords = vector3(-556.26, -132.99, 33.75),
		debugPoly = false,
		length = 0.50,
		width = 0.65,
		heading = 131.24,
		maxZ = 34.30,
		minZ = 33.75,
		options = {
			{
				icon = 'fas fa-camera',
				label = 'Take Suspects Mugshots',
				job = {
					['police'] = 0,
					['sast'] = 0,
				},
				action = function()
					local player, distance = QBCore.Functions.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
                    if player ~= -1 and distance < 2.0 then
                        local playerId = GetPlayerServerId(player)
						TriggerServerEvent('cqc-mugshot:server:triggerSuspect', playerId)
					end
				end,
			},
		},
		distance = 2.0,
	},
```

<h1>FEATURES</h1>

- Teleports player into correct area
- All client sided to improve performance
- Mugshot Board with players information on
- Automatically takes and uploads the images to a discord webhook
- Highly configurable


<h2>NOTE</h2>
The config option Config.CQCMDT is built in for future releases from CQC. We might release the MDT we are working on. If you want to pull the images into an existing MDT system this config option simply creates a server object with the citizenid and the images urls which can be pulled on demand.

<h2>IMAGES</h2>

![image](https://user-images.githubusercontent.com/46245557/135166635-562cf4fe-491c-4120-9bc0-dd7c919a3c00.png)
![Image1](https://user-images.githubusercontent.com/89382232/135759935-e459ef23-30c3-4e24-a9d1-293a6d12735c.png)


**CREDIT**
-----
Lassemc475 - https://github.com/Lassemc475/fivem-scripts/tree/master/vrp/lmc_mugshot
For understanding how the mugshot board works

**DEPENDENCIES**
-----

- QBCore - https://github.com/qbcore-framework
- QB-Target - https://github.com/BerkieBb/qb-target
- screenshot-basic - https://github.com/citizenfx/screenshot-basic
