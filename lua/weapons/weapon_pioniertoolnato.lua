AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Schaufel (NATO)"
    SWEP.Slot = 2
    SWEP.SlotPos = 1
    SWEP.DrawCrosshair = false
    SWEP.DrawAmmo = false
elseif SERVER then
    util.AddNetworkString("AventinOpenPanel")
end

SWEP.Base = "weapon_pioniertoolbase"
SWEP.Author = "Aventin"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "Aventin's Pioniertool"
-- primäres "magazin"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
-- sekundäres "magazin"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "passive"
SWEP.UseHands = true
SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.Fortifications = {
    {
        name = "Betonmauer",
        health = 500,
        model = "models/props_fortifications/concrete_wall001_96_reference.mdl",
        category = 1
    },
    {
        name = "Langer Polizeizaun",
        health = 500,
        model = "models/props_street/police_barricade2.mdl",
        category = 1
    },
    {
        name = "Polizeizaun",
        health = 250,
        model = "models/props_street/police_barricade.mdl",
        category = 1
    }
}