if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then
    AddCSLuaFile()
    SWEP.Weight = 1
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false
end

if CLIENT then
    SWEP.PrintName = "weapon_ttt_slk_tele_name"
    SWEP.DrawAmmo = false -- not needed?
    SWEP.DrawCrosshair = true
    SWEP.ViewModelFlip = true
    SWEP.ViewModelFOV = 74
    SWEP.Slot = 2
    SWEP.Slotpos = 2
    -- TODO: oder knife oder etwas anders
end

SWEP.Base = "weapon_tttbase"
SWEP.HoldType = "knife"
SWEP.ViewModel = ""
SWEP.WorldModel = ""
--SWEP.UseHands              = true 
-- PRIMARY:  Claws Attack
SWEP.Primary.Delay = 0.1
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 1 -- 1
SWEP.Primary.DefaultClip = 1 -- 1
SWEP.Primary.Ammo = "none" -- do i need this?
SWEP.Primary.Tele = Sound("npc/turret_floor/active.wav")
SWEP.Primary.Miss = Sound("ambient/atmosphere/cave_hit2.wav")
-- SECONDARY: Claws Push
SWEP.Secondary.Delay = 2
SWEP.Secondary.Automatic = false
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.TeleShot = Sound("ambient/levels/citadel/portal_beam_shoot5.wav")
-- SWEP.Secondary.HitForce    = 700
-- SWEP.Secondary.ClipSize    = -1
-- SWEP.Secondary.DefaultClip = -1
-- SWEP.Secondary.Automatic   = false
-- SWEP.Secondary.Ammo        = "none"
-- SWEP.Secondary.Delay       = 3
-- SWEP.Secondary.Sound	   = Sound( "weapons/knife/knife_slash2.wav" )
-- SWEP.Secondary.Hit         = Sound( "npc/fast_zombie/claw_strike3.wav" )
-- TTT2 related
SWEP.Kind = WEAPON_SPECIAL
SWEP.MaxDistance = 250
SWEP.AllowDrop = false
SWEP.IsSilent = true
-- Pull out faster than standard guns
SWEP.DeploySpeed = 2
-- Mana Managment
SWEP.Mana = 75
-- SWEP.Mana.Tele = 75

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
    --self:SetHoldType("knife")
end

-- function SWEP:Holster()
--     return false
-- end
function SWEP:Equip(owner)
    if not SERVER or not owner then return end
    owner:DrawWorldModel(false)
    --self.ViewModel = "models/weapons/v_banshee.mdl"
    --self.WorldModel = ""
    -- net.Start("ttt2_hdn_network_wep")
    --     net.WriteEntity(self)
    --     net.WriteString("")
    -- net.Broadcast()
    -- STATUS:RemoveStatus(owner, "ttt2_hdn_knife_recharge")
end

function SWEP:PrimaryAttack()
    -- TODO: Only set this, if the attack hit something.    
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    --self.ViewModel = "models/weapons/v_banshee.mdl"
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end
    --owner:LagCompensation(true)
    self:ShotTele()
    --owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    --self.ViewModel = "models/zed/weapons/v_banshee.mdl"
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end
    --owner:LagCompensation(true)
    -- local tgt, spos, sdest, trace = self:MeleeTrace()
    -- print("target:", tgt, "pos:", spos, "destination:", sdest, "trace:", trace)
    -- if IsValid(tgt) then
    self:Tele()
    --owner:LagCompensation(false)
end

-- Turnes Prop into controlled prop
function SWEP:TeleProp(ent)
    local owner = self:GetOwner()
    print("Turn Prop into TeleProp")
    ent.Tele = true
    local psy = ents.Create("ttt_tele_object")
    psy:SetOwner(owner)
    psy:SetAngles(ent:GetAngles())

    if ent:GetClass() == "prop_ragdoll" then
        psy:SetCollides(true)
        psy:SetTrueParent(ent)
        psy:SetPos(ent:LocalToWorld(ent:OBBCenter()))
        psy:SetModel("models/props_junk/propanecanister001a.mdl")
    else
        psy:SetParent(ent)
        psy:SetModel(ent:GetModel())
        psy:SetPos(ent:GetPos())
    end

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        psy:SetMass(math.Clamp(phys:GetMass(), 100, 5000))
        psy:SetPhysMat(phys:GetMaterial())
    end

    psy:Spawn()
    self.Prop = psy
    --owner:AddInt("Mana", -self.Mana)
    owner:EmitSound(self.Primary.Tele, 50)
    -- net.Start("Flay")
    -- net.Send(owner)
end

-- Checks wether telekinesis can be used on an object
function SWEP:CanTele(ent, phys)
    if (string.find(ent:GetClass(), "prop_phys") or ent:GetClass() == "prop_ragdoll") and not IsValid(ent:GetParent()) then
        if IsValid(phys) and phys:IsMotionEnabled() and phys:IsMoveable() then
            print("Can Tele: TRUE!")

            return true
        end
    end

    print("Cannot Tele: FALSE")
end

-- Lanches Object, if one is controlled with telekinesis
function SWEP:ShotTele()

    print("Activate ShotTele")
    -- TODO: Entfernung beachten
    local tr = util.TraceLine(util.GetPlayerTrace(self:GetOwner()))

    if IsValid(self.Prop) then
        print("ShotTele is carried out!")
        self.Prop:EmitSound(self.Secondary.TeleShot, 100, math.random(100, 120))
        self.Prop:SetLaunchTarget(tr.HitPos)
        self.Prop = nil

        return
    end
end

-- Starks Telekinesis process of an object
function SWEP:Tele()
    local owner = self:GetOwner()
    -- create Trace in the direction the player is looking in. 
    -- restrict distance to self.MaxDistance
    local spos = owner:GetShootPos()
    local sdest = spos + (owner:GetAimVector() * self.MaxDistance)

    local tr = util.TraceLine({
        start = spos,
        endpos = sdest,
        filter = owner,
        mask = MASK_SHOT_HULL
    })

    -- TODO: Implement Mana System
    -- if not enough mana, return
    -- if owner:GetInt( "Mana" ) < self.Mana then
    -- 	owner:EmitSound( self.Primary.Miss, 40, 250 )
    -- 	return
    -- end
    local phys
    if IsValid(tr.Entity) then
        phys = tr.Entity:GetPhysicsObject()
    end

    -- if object meets the Telekinesis requirements: TODO: add distance
    if IsValid(tr.Entity) and IsValid(phys) and self:CanTele(tr.Entity, phys) then
        print("Trace has hit object", tr.Entity)
        self:TeleProp(tr.Entity)
        -- searches around the hit position for the closest other object
    else
        local dist = 100
        local ent
        local tbl = ents.FindByClass("prop_phys*")
        tbl = table.Add(tbl, ents.FindByClass("prop_ragdoll"))

        for k, v in pairs(tbl) do
            local phys = v:GetPhysicsObject()

            -- HitPos is EndPos if trace hit nothing
            if v:GetPos():Distance(tr.HitPos) < dist and not IsValid(v:GetParent()) and self:CanTele(v, phys) then
                ent = v
                dist = v:GetPos():Distance(tr.HitPos)
            end
        end

        if IsValid(ent) then
            print("Trace did not hit an object", ent)
            self:TeleProp(ent)

            return
        end

        owner:EmitSound(self.Primary.Miss, 50, 250)
    end
end