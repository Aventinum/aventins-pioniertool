AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Schaufel (Base)"
    SWEP.Slot = 2
    SWEP.SlotPos = 1
    SWEP.DrawCrosshair = false
    SWEP.DrawAmmo = false
elseif SERVER then
    util.AddNetworkString("AventinOpenPanel")
end

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
        name = "Sandsäcke",
        health = 500,
        model = "models/props_fortifications/sandbags_line1.mdl",
        category = 1
    },
    {
        name = "Panzersperre",
        health = 500,
        model = "models/props_fortifications/hedgehog_large1.mdl",
        category = 1
    },
    {
        name = "Sofa",
        health = 250,
        model = "models/props_furniture/couch2.mdl",
        category = 1
    },
    {
        name = "Stacheldraht",
        health = 200,
        model = "models/props_street/concertinawire128.mdl",
        category = 1
    },
    {
        name = "Betonbarriere",
        health = 500,
        model = "models/props_fortifications/concrete_block001_128_reference.mdl",
        category = 1
    }
}

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "SelectedFortification")
end

function SWEP:Initialize()
    self:SetHoldType("passive")
    self:SetSelectedFortification(1)
end

if SERVER then
    function SWEP:PrimaryAttack()
        local ply = self:GetOwner()

        if ply:IsValid() then
            local nextFortification = self:GetSelectedFortification() + 1

            if self.Fortifications[nextFortification] then
                self:SetSelectedFortification(nextFortification)
            else
                self:SetSelectedFortification(1)
            end
        end
    end

    function SWEP:SecondaryAttack()
        local ply = self:GetOwner()

        if ply:IsValid() then
            local prevFortification = self:GetSelectedFortification() - 1

            if self.Fortifications[prevFortification] then
                self:SetSelectedFortification(prevFortification)
            else
                self:SetSelectedFortification(#self.Fortifications)
            end
        end
    end

    hook.Add("KeyPress", "PlayerBuildsFortification", function(ply, key)
        if ply:IsValid() and key == IN_USE then
            local built = false

            timer.Create("MenuTimer", 0.05, 5, function()
                if not ply:KeyDown(IN_USE) and not built then
                    built = true
                    local wep = ply:GetActiveWeapon()

                    if wep:IsValid() and wep:IsPioneertool() and wep:CanBuildFortification() then
                        local fortification = ents.Create("ent_fortification")
                        fortification:SetAngles(Angle(0, ply:EyeAngles().y - 180, 0))
                        fortification:SetModel(wep.Fortifications[wep:GetSelectedFortification()]["model"])
                        fortification:SetPos(ply:GetEyeTrace().HitPos - ply:GetEyeTrace().HitNormal * fortification:OBBMins().z)
                        fortification:Spawn()
                        fortification:SetGravity(150)
                        fortification:SetFortificationHealth(0)
                        fortification:SetMaxFortificationHealth(wep.Fortifications[wep:GetSelectedFortification()]["health"])
                        fortification:EmitSound("physics/concrete/rock_impact_hard" .. math.random(1, 6) .. ".wav")
                        local effectdata = EffectData()
                        effectdata:SetOrigin(Vector(fortification:GetPos().x, fortification:GetPos().y, fortification:GetPos().z) + (fortification:GetUp() * fortification:OBBMaxs().z / 2))
                        effectdata:SetMagnitude(3)
                        effectdata:SetScale(5)
                        effectdata:SetRadius(2)
                        util.Effect("cball_explode", effectdata, true, true)
                    end
                end
            end)

            timer.Simple(0.26, function()
                if not built and ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():IsPioneertool() then
                    net.Start("AventinOpenPanel")
                    net.Send(ply)
                end
            end)
        end
    end)
else
    local fortificationHologram = nil

    hook.Add("Tick", "PlayerHologram", function()
        local ply = LocalPlayer()

        if ply:IsValid() then
            local wep = ply:GetActiveWeapon()
            local tr = ply:GetEyeTrace()

            if wep:IsValid() and wep:IsPioneertool() and wep.Fortifications[wep:GetSelectedFortification()] then
                local fortificationModel = wep.Fortifications[wep:GetSelectedFortification()]["model"]
                local fortificationAngles = Angle(0, ply:EyeAngles().y - 180, 0)

                if not fortificationHologram or not fortificationHologram:IsValid() then
                    fortificationHologram = ClientsideModel(fortificationModel)
                    fortificationHologram:SetPos(tr.HitPos - tr.HitNormal * fortificationHologram:OBBMins().z)
                    fortificationHologram:SetAngles(fortificationAngles)
                    fortificationHologram:SetRenderMode(RENDERMODE_TRANSALPHA)
                    fortificationHologram:SetColor(Color(50, 200, 110, 150))
                    fortificationHologram:DrawShadow(false)
                    fortificationHologram:SetMaterial("models/wireframe")
                    fortificationHologram:Spawn()
                elseif fortificationHologram:IsValid() then
                    if fortificationHologram:GetModel() ~= fortificationModel then
                        fortificationHologram:SetModel(fortificationModel)
                    end

                    local fortificationPosition = Lerp(20 * FrameTime(), fortificationHologram:GetPos(), tr.HitPos - tr.HitNormal * fortificationHologram:OBBMins().z)
                    fortificationHologram:SetPos(fortificationPosition)
                    fortificationHologram:SetAngles(fortificationAngles)

                    if wep:CanBuildFortification() then
                        fortificationHologram:SetColor(Color(50, 200, 110, 150))
                    else
                        fortificationHologram:SetColor(Color(200, 67, 50, 150))
                    end
                end
            elseif fortificationHologram then
                fortificationHologram:Remove()
                fortificationHologram = nil
            end
        end
    end)

    function SWEP:Initialize()
        radialmenu = vgui.Create("DFrame")
        radialmenu:SetSize(600, 600)
        radialmenu:Center()
        radialmenu:SetVisible(false)
        radialmenu:SetDeleteOnClose(false)
    end

    net.Receive("AventinOpenPanel", function()
        gui.EnableScreenClicker(true)
        radialmenu:SetVisible(true)

        function radialmenu:OnClose()
            gui.EnableScreenClicker(false)
        end
    end)
end

function SWEP:CanBuildFortification()
    local ply = self:GetOwner()

    return (ply:GetPos():DistToSqr(ply:GetEyeTrace().HitPos) < (250 ^ 2)) and ply:IsValid() and ply:IsPlayer() and ply:Alive() and (ply:GetVelocity():Length() <= 25)
end

function SWEP:Reload()
    return false
end

function SWEP:Holster()
    return true
end

function SWEP:OnDrop()
    self:Holster()
end

function SWEP:OnRemove()
    self:Holster()
end