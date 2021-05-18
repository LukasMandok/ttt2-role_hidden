if engine.ActiveGamemode() ~= "terrortown" then return end

game.AddAmmoType( {
	name = "stalker_scream",
} )

if SERVER then
    AddCSLuaFile()
    SWEP.Weight         = 1
    SWEP.AutoSwitchTo   = false
    SWEP.AutoSwitchFrom = false
end

if CLIENT then
    SWEP.PrintName      = "weapon_ttt_slk_scream_name"
    SWEP.DrawAmmo       = false -- not needed?
    SWEP.DrawCrosshair  = false
    SWEP.ViewModelFlip  = false
    SWEP.ViewModelFOV   = 74
    SWEP.Slot           = 3
    SWEP.Slotpos        = 3

    SWEP.EquipMenuData = {
        type = "Weapon",
        desc = "Control objects with the power of your mind. \nMana cost: 75"
    }
end

SWEP.Base = "weapon_tttbase"

-- Visuals
SWEP.ViewModel             = "models/zed/weapons/v_banshee.mdl"
SWEP.WorldModel            = ""
SWEP.HoldType              = "magic"
SWEP.UseHands              = true

-- Shop settings
SWEP.Kind                  = WEAPON_NADE
SWEP.CanBuy                = {ROLE_STALKER}
SWEP.LimitedStock          = true

--SWEP.UseHands              = true 
-- PRIMARY:  Claws Attack
SWEP.Primary.Delay          = 10
SWEP.Primary.Automatic      = false
SWEP.Primary.ClipSize       = 1 -- 1
SWEP.Primary.DefaultClip    = 1 -- 1
SWEP.Primary.Ammo           = "stalker_scream" -- do i need this?
SWEP.Primary.Tele           = Sound("npc/turret_floor/active.wav")
SWEP.Primary.Miss           = Sound("ambient/atmosphere/cave_hit2.wav")

-- TTT2 related
SWEP.MaxDistance = 250
SWEP.AllowDrop = false
SWEP.IsSilent = true

-- Pull out faster than standard guns
SWEP.DeploySpeed = 2

-- Mana Managment
SWEP.Mana = 50


function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

-- function SWEP:Holster()
--     return false
-- end
function SWEP:Equip(owner)
    if not SERVER or not owner then return end
    owner:DrawWorldModel(false)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end

    local ammo = math.Clamp(math.floor(self:GetOwner():GetMana() / self.Mana ) - self:Clip1(), 0, 10)
    owner:SetAmmo(ammo, self:GetPrimaryAmmoType())

    if owner:GetMana() < self.Mana then
        --print("Not enough mana")
    return end

    if self:GetNextPrimaryFire() > CurTime() then
        --print("NextSecondaryFire not valid:", self:GetNextSecondaryFire())
    return end

    --print("Reload Ammo:", ammo)
    self:SetClip1(1)
    -- self:Reload()
end

function SWEP:CanPrimaryAttack()
    if self:Clip1() < 1 then
        self:GetOwner():EmitSound( self.Primary.Miss, 40, 250 )
        self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
        return false
    end

    return true
end

-- end


function SWEP:PrimaryAttack()

    --self.ViewModel = "models/weapons/v_banshee.mdl"
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetSubRole() ~= ROLE_STALKER or not owner:GetNWBool("ttt2_hd_stalker_mode", false) then return end
    --owner:LagCompensation(true)

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    self:SetClip1(0)
    --owner:SetAmmo(owner:GetAmmoCount(self:GetPrimaryAmmoType()) - 1, self:GetPrimaryAmmoType())
    owner:AddMana(-self.Secondary.Mana)

    self:Scream()

    return true
    --owner:LagCompensation(false)
end


function SWEP:Scream()

	if self.Owner:GetInt( "Mana" ) < self.Mana.Scream then
	
		self.Owner:EmitSound( self.Secondary.Miss, 40, 250 )
		
		return
	
	end
	
	self.Owner:EmitSound( self.Secondary.Scream, 100, 90 )
	self.Owner:AddInt( "Mana", -self.Mana.Scream )

	for k,v in pairs( team.GetPlayers( TEAM_HUMAN ) ) do
	
		if v:GetPos():Distance( self.Owner:GetPos() ) < 500 then
		
			util.BlastDamage( self.Owner, self.Owner, v:GetPos(), 5, 5 )
			
			local ed = EffectData()
			ed:SetOrigin( v:GetPos() )
			util.Effect( "scream_hit", ed, true, true )
			
		end
		
	end
	
	local tbl = ents.FindByClass( "sent_tripmine" )
	tbl = table.Add( tbl, ents.FindByClass( "sent_seeker" ) )
	
	for k,v in pairs( tbl ) do
	
		if v:GetPos():Distance( self.Owner:GetPos() ) < 350 then
		
			v:Malfunction()
		
		end
	
	end

end