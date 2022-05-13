Config = {}

Config.Webhook = '' -- Images will be uploaded here
Config.TestCommand = false -- Use this when testing /testmugshot

Config.CustomMLO = false -- If you use a MLO use the options below to change the camera location. Otherwise it will use the default IPL for the mugshot location
Config.MugshotLocation = vector3(-559.81, -132.68, 32.75) -- Location of the Suspect
Config.MugshotSuspectHeading = 291.18 -- Direction Suspsect is facing
Config.MugShotCamera = {
    x = -558.44,
    y = -132.23,
    z = 34.10,
    r = {x = 0.0, y = 0.0, z = 110.33} -- To change the rotation use the z. Others are if you want rotation on other axis
}

--[[

If using Western's MRPD the Coordinates are as following,

Config.MugshotLocation = vector3(484.0772, -999.4976, 25.4675) -- Location of the Suspect
Config.MugshotSuspectHeading = 357.8132 -- Direction Suspsect is facing
Config.MugShotCamera = {
    x = 484.0522,
    y = -997.6379,
    z = 25.4675,
    r = {x = 0.0, y = 0.0, z = 177.5} -- To change the rotation use the z. Others are if you want rotation on other axis
}

]]

Config.BoardHeader = "Los Santos Police Department" -- Header that appears on the board
Config.WaitTime = 2000 -- Time before and after the photo is taken. Decreasing this value might result in some angles being skiped.
Config.Photos = 3 -- Front, Back Side. Use 4 for both sides
Config.CQCMDT = false -- If you use CQC MDT this will automatically send them to a players profile