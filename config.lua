Config = {}

Config.Webhook = 'https://discord.com/api/webhooks/913767420794122240/3f_yIYDco5z4m_8IabNZ27b2z3X8zvW7nGgCHWvjjU_8_zlzSrfh-kDdA3daluJcXxn5' -- Images will be uploaded here
Config.TestCommand -- Use this when testing /testmugshot

Config.MugshotLocation = vector3(-559.81, -132.68, 32.75) -- Location of the Suspect
Config.MugshotHeading = 291.18 -- Direction Suspsect is facing
Config.MugShotCamera = {
    x = -558.44,
    y = -132.23,
    z = 34.10,
    r = {x = 0.0, y = 0.0, z = 110.33} -- To change the rotation use the z. Others are if you want rotation on other axis
}

Config.BoardHeader = "Los Santos Police Department" -- Header that appears on the board
Config.WaitTime = 2000 -- Time before and after the photo is taken. Decreasing this value might result in some angles being skiped.
Config.Photos = 3 -- Front, Back Side. Use 4 for both sides
Config.CQCMDT = true -- If you use CQC MDT this will automatically send them to a players profile