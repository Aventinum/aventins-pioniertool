AddCSLuaFile()

local weapon = FindMetaTable("Weapon")

function weapon:IsPioneertool()
    return self:GetClass() == "weapon_pioniertoolbase" or self:GetClass() == "weapon_pioniertoolnato" or self:GetClass() == "weapon_pioniertoolmiliz" or self:GetClass() == "weapon_pioniertoolun"
end