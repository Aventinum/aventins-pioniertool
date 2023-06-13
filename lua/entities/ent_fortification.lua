AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Befestigung"
ENT.Category = "Aventin's Pioniertool"
ENT.Author = "Aventin"
ENT.Instructions = ""
ENT.Contact = ""
ENT.Purpose = ""
ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local physObj = self:GetPhysicsObject()

    if physObj:IsValid() then
        physObj:Wake()
        physObj:SetMass(50000)
        physObj:EnableMotion(false)
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "FortificationHealth")
    self:NetworkVar("Int", 1, "MaxFortificationHealth")
end