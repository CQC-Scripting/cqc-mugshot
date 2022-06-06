Config = {}

Config.Webhook = '' -- Images will be uploaded here
Config.TestCommand = true -- Use this when testing /testmugshot

Config.CustomMLO = true -- If you use a MLO use the options below to change the camera location. Otherwise it will use the default IPL for the mugshot location
Config.MugshotLocation = vector3(472.92, -1011.49, 25.27) -- Location of the Suspect
Config.MugshotSuspectHeading = 183.55 -- Direction Suspsect is facing
Config.MugShotCamera = {
    x = 473.05,
    y = -1012.56,
    z = 26.90,
    r = {x = 0.0, y = 0.0, z = 358.04} -- To change the rotation use the z. Others are if you want rotation on other axis
}

Config.BoardHeader = "Los Santos Police Department" -- Header that appears on the board
Config.WaitTime = 2000 -- Time before and after the photo is taken. Decreasing this value might result in some angles being skiped.
Config.Photos = 4 -- Front, Back Side. Use 4 for both sides
Config.CQCMDT = true -- If you use CQC MDT this will automatically send them to a players profile
