# CQC-MUGSHOT
![Banner](https://user-images.githubusercontent.com/89382232/146275315-47638b67-0eba-4c42-acff-2cea8693b7a6.png)

CQC-Mugshot is a mugshot system for use with QB servers to allow players to take pictures of suspects and then have them uploaded to a webhook.
<br>
<h1>INSTALLATION GUIDE</h1>

1. Add the cqc-mugshot folder into your resources folder
2. Add The Following Line to qb-target>config.lua>Config.BoxZones (**change the location etc as needed**)

```lua
-- CQC-Mugshot
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
				event = 'cqc-mugshot:client:takemugshot',
				type = 'client'
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
- Supports all MLOs via the config also has an option for no MLO's which TP's suspects to an IPL and back
- QB Callback to request latest mugshots on that session for a citizenID


<h2>NOTE</h2>
The config option Config.CQCMDT is built in for future releases from CQC. We might release the MDT we are working on. If you want to pull the images into an existing MDT system this config option simply creates a server object with the citizenid and the images urls which can be pulled on demand.

<h2>IMAGES</h2>

![screenshot](https://user-images.githubusercontent.com/32689432/143718564-8941f692-4c04-42e2-9ea2-41629236552b.jpg)
![screenshot (1)](https://user-images.githubusercontent.com/32689432/143718578-43d855e3-d705-4d40-80be-28d098e2467f.jpg)
![screenshot (2)](https://user-images.githubusercontent.com/32689432/143718597-fed1251e-d855-449a-ad13-dd7990057dab.jpg)


**CREDIT**
-----
Lassemc475 - https://github.com/Lassemc475/fivem-scripts/tree/master/vrp/lmc_mugshot
Used for understanding how the mugshot board works

**DEPENDENCIES**
-----

- QBCore - https://github.com/qbcore-framework
- QB-Target - https://github.com/BerkieBb/qb-target
- screenshot-basic - https://github.com/citizenfx/screenshot-basic
