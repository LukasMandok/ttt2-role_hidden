if SERVER then
    AddCSLuaFile()

    SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if CLIENT then
    SWEP.PrintName     = "weapon_ttt_slk_claws_name"

    SWEP.DrawAmmo	   = false -- not needed?

    SWEP.DrawCrosshair = true
    SWEP.ViewModelFlip = true 
    SWEP.ViewModelFOV  = 74

    SWEP.Slot          = 1
    SWEP.Slotpos       = 1 

    -- TODO: oder knife oder etwas anders
end


SWEP.Base = "weapon_tttbase"

SWEP.ViewModel  = "models/weapons/v_banshee.mdl"
SWEP.WorldModel = "models/weapons/v_banshee.mdl" -- change this! w_pistol
--SWEP.UseHands   = true 

-- PRIMARY:  Claws Attack
SWEP.Primary.Damage        = 40
SWEP.Primary.Delay         = 0.75
SWEP.Primary.Automatic     = true

SWEP.Primary.ClipSize      = -1 -- 1
SWEP.Primary.DefaultClip   = -1 -- 1
SWEP.Primary.Ammo          = "none" -- do i need this?

SWEP.Primary.Sound		   = Sound( "weapons/knife/knife_slash2.wav" )
SWEP.Primary.Hit           = Sound( "npc/fast_zombie/claw_strike3.wav" )


-- SECONDARY: Claws Push
SWEP.Secondary.Damage      = 10
SWEP.Secondary.HitForce    = 700
SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"
SWEP.Secondary.Delay       = 3

SWEP.Secondary.Sound	   = Sound( "weapons/knife/knife_slash2.wav" )
SWEP.Secondary.Hit         = Sound( "npc/fast_zombie/claw_strike3.wav" )


-- SWEP.Secondary.Select      = Sound( "ui/buttonrollover.wav" )
-- SWEP.Secondary.Miss        = Sound( "ambient/atmosphere/cave_hit2.wav" )
-- SWEP.Secondary.Flay        = Sound( "ambient/levels/citadel/portal_beam_shoot6.wav" )
-- SWEP.Secondary.Scream      = Sound( "npc/stalker/go_alert2a.wav" )
-- SWEP.Secondary.Heal        = Sound( "npc/antlion_guard/growl_idle.wav" )
-- SWEP.Secondary.Tele        = Sound( "npc/turret_floor/active.wav" )
-- SWEP.Secondary.TeleShot    = Sound( "ambient/levels/citadel/portal_beam_shoot5.wav" )

-- TTT2 related
SWEP.Kind        = WEAPON_SPECIAL
SWEP.HitDistance = 64
SWEP.AllowDrop   = false
SWEP.IsSilent    = true

-- Pull out faster than standard guns
SWEP.DeploySpeed = 2


-- Mana Managment
SWEP.Mana = {}
SWEP.Mana.Scream = 25
SWEP.Mana.Flay = 50
SWEP.Mana.Psycho = 75
SWEP.Mana.Heal = 100


local swingSound = Sound("WeaponFrag.Throw")
local hitSound = Sound("Flesh.ImpactHard")

function SWEP:Initialize()
    self.Weapon:SetWeaponHoldType( self.HoldType )
    --self:SetHoldType("knife")
end

-- function SWEP:Holster()
--     return false
-- end

function SWEP:Equip(owner)
    if not SERVER or not owner then return end

    self.Owner:DrawWorldModel( false )
    -- self.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
    -- self.WorldModel = ""
    -- net.Start("ttt2_hdn_network_wep")
    --     net.WriteEntity(self)
    --     net.WriteString("")
    -- net.Broadcast()
    -- STATUS:RemoveStatus(owner, "ttt2_hdn_knife_recharge")
end

function SWEP:PrimaryAttack()
    -- TODO: Only set this, if the attack hit something.    
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    --self.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
    local owner = self:GetOwner()

    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end

    owner:LagCompensation(true)

        local tgt = self.Weapon:MeleeTrace(owner)

        if IsValid(tgt) then

            self:SendWeaponAnim(ACT_VM_MISSCENTER)
    
            local eData = EffectData()
            eData:SetStart(spos)
            eData:SetOrigin(trace.HitPos)
            eData:SetNormal(trace.Normal)
            eData:SetEntity(tgt)
    
            if tgt:IsPlayer() or tgt:GetClass() == "prop_ragdoll" then
                owner:SetAnimation(PLAYER_ATTACK1)
                
                self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
                tgt:EmitSound( self.Primary.Hit, 100, math.random(90,110) )
                --self:SendWeaponAnim(ACT_VM_MISSCENTER)
    
                util.Effect("BloodImpact", eData)
            end
        else
            self:SendWeaponAnim(ACT_VM_MISSCENTER)
            -- TODO: keine Ahnung
            owner:EmitSound( self.Primary.Sound, 100, math.random(80,100) )
        end
    
        -- TODO: Warum brauche ich das?
        --if SERVER then owner:SetAnimation(PLAYER_ATTACK1) end
        
        if SERVER and trace.Hit and trace.HitNonWorld and IsValid(tgt) then
            self.Weapon:DealDamage(self.Primary.Damage, tgt, trace, spos, sdest)
        end

    owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
    self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
 
    --self.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
    local owner = self:GetOwner()

    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end

    owner:LagCompensation(true)

        local tgt = self.Weapon:MeleeTrace(owner)

        if IsValid(tgt) then

            self:SendWeaponAnim(ACT_VM_MISSCENTER)
    
            local eData = EffectData()
            eData:SetStart(spos)
            eData:SetOrigin(trace.HitPos)
            eData:SetNormal(trace.Normal)
            eData:SetEntity(tgt)
    
            if tgt:IsPlayer() or tgt:GetClass() == "prop_ragdoll" then
                owner:SetAnimation(PLAYER_ATTACK1)
                
                self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
                tgt:EmitSound( self.Secondary.Hit, 100, math.random(90,110) )
                --self:SendWeaponAnim(ACT_VM_MISSCENTER)
    
                util.Effect("BloodImpact", eData)
            end
        else
            self:SendWeaponAnim(ACT_VM_MISSCENTER)
            -- TODO: keine Ahnung
            owner:EmitSound( self.Secondary.Sound, 100, math.random(80,100) )
        end
    
        -- TODO: Warum brauche ich das?
        --if SERVER then owner:SetAnimation(PLAYER_ATTACK1) end
        
        if SERVER and trace.Hit and trace.HitNonWorld and IsValid(tgt) then
            self.Weapon:DealDamage(self.Secondary.Damage, tgt, trace, spos, sdest)
        end

    owner:LagCompensation(false)

 end


function SWEP:MeleeTrace(owern)

    local spos = owner:GetShootPos()
    local sdest = spos + (owner:GetAimVector() * 80)

    local kmins = Vector(1, 1, 1) * -20
    local kmaxs = Vector(1, 1, 1) * 20

    local trace = util.TraceHull({
        start = spos,
        endpos = sdest,
        filter = owner,
        mask = MASK_SHOT_HULL,
        mins = kmins,
        maxs = kmaxs
    })
    
    -- TODO: not shure about this
    if not IsValid(trace.Entity) then
        trace = util.TraceLine({
            start = spos,
            endpos = sdest,
            filter = owner,
            mask = MASK_SHOT_HULL
        })
    end
    
    return trace.Entity
end


function SWEP:DealDamage(dmg, tgt, trace, spos, sdest, lifesteal)
   
    local owner = self:GetOwner()

    if tgt:IsPlayer() then
        local health = tgt:Health()
        if  health < (dmg + 5) then
            self:Murder(trace, spos, sdest)
            
            -- TODO: if Player has aqquired the lifesteam item: 20% of remaining health + 10 flat
            if lifesteal and self.RegenTime then
                owner:AddHealth(health * 0.2 + 10)
            end
        else
            local dmg = DamageInfo()
            dmg:SetDamage(dmg)
            dmg:SetAttacker(owner)
            dmg:SetInflictor(self)
            dmg:SetDamageForce(owner:GetAimVector() * 5)
            dmg:SetDamagePosition(owner:GetPos())
            dmg:SetDamageType(DMG_SLASH)

            tgt:DispatchTraceAttack(dmg, spos + (owner:GetAimVector() * 3), sdest)
            
            -- TODO: if Player has aqquired the lifesteal item
            if lifesteal and self.RegenTime then
                owner:AddHealth(dmg * 0.2)
            end
        end
    
    elseif tgt:GetClass() == "prop_ragdoll" then
        -- TODO: if Player haS aqquired lifesteal from corpses item he can regenerate life from corpses
        if lifesteal and self.RegenTime then
            owner:AddHealth(dmg * 0.2)
        end 
        -- TODO: implement something to cound the remaining life a corpse has
        
    end
end

function SWEP:Murder(trace, spos, sdest)
    local tgt = trace.Entity
    local owner = self:GetOwner()

    local dmg = DamageInfo()
    dmg:SetDamage(2000)
    dmg:SetAttacker(owner)
    dmg:SetInflictor(self)
    dmg:SetDamageForce(owner:GetAimVector())
    dmg:SetDamagePosition(owner:GetPos())
    dmg:SetDamageType(DMG_SLASH)

    local retrace = util.TraceLine({
        start = spos,
        endpos = sdest,
        filter = owner,
        mask = MASK_SHOT_HULL
    })

    if retrace.Entity ~= tgt then
        local center = tgt:LocalToWorld(tgt:OBBCenter())

        retrace = util.TraceLine({
            start = spos,
            endpos = sdest,
            filter = owner,
            mask = MASK_SHOT_HULL
        })
    end

    local bone = retrace.PhysicsBone
    local pos = retrace.HitPos
    local norm = trace.Normal

    local angle = Angle(-28, 0, 0) + norm:Angle()
    angle:RotateAroundAxis(angle:Right(), -90)

    pos = pos - (angle:Forward() * 7)

    tgt.effect_fn = function(rag)
        local moreTrace = util.TraceLine({
            start = pos,
            endpos = pos + norm * 40,
            filter = ignore,
            mask = MASK_SHOT_HULL
        }) 

        if IsValid(moreTrace.Entity) and moreTrace.Entity == rag then
            bone = moreTrace.PhysicsBone
            pos = moreTrace.HitPos
            angle = Angle(-28, 0, 0) + moreTrace.Normal:Angle()
            angle:RotateAroundAxis(angle:Right(), -90)
            pos = pos - (angle:Forward() * 10)
        end

        local knife = ents.Create("prop_physics")
        knife:SetModel("models/weapons/w_knife_t.mdl")
        knife:SetPos(pos)
        knife:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        knife:SetAngles(angle)

        knife.CanPickup = false 

        knife:Spawn()

        local phys = knife:GetPhysicsObject()

        if IsValid(phys) then
            phys:EnableCollisions(false)
        end

        constraint.Weld(rag, knife, bone, 0, 0, true)

        rag:CallOnRemove("ttt_knife_cleanup", function()
            SafeRemoveEntity(knife)
        end)
    end

    tgt:DispatchTraceAttack(dmg, spos + owner:GetAimVector() * 3, sdest)
end
