if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then
    AddCSLuaFile()
end

roles.InitCustomTeam(ROLE.name, {
    icon = "vgui/ttt/dynamic/roles/icon_hdn",
    color = Color(0, 49, 82, 255)
})

function ROLE:PreInitialize()
	roles.SetBaseRole(self, ROLE_HIDDEN)

    self.color = Color(0, 49, 82, 255)

    self.abbr = "slk"
	self.score.surviveBonusMultiplier = 0.5
	self.score.timelimitMultiplier = -0.5
	self.score.killsMultiplier = 5
	self.score.teamKillsMultiplier = -16
	self.score.bodyFoundMuliplier = 0

	self.defaultTeam = TEAM_STALKER
	self.defaultEquipment = SPECIAL_EQUIPMENT

	self.conVarData = {
		pct = 0.13,
		maximum = 1,
		minPlayers = 8,
		credits = 2,
		togglable = true,
		random = 20,
        shopFallback = SHOP_FALLBACK_TRAITOR
	}
end

function ROLE:Initialize()
    if SERVER and JESTER then
        self.networkRoles = {JESTER}
    end
end

if SERVER then

    function ROLE:RemoveRoleLoadout(ply, isRoleChange)
        ply:RemoveEquipmentWeapon("weapon_ttt_slk_claws")
        STATUS:RemoveStatus(ply, "ttt2_hdn_invisbility")
    end

    hook.Add("KeyPress", "StalkerEnterStalker", function(ply, key)
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:Alive() or ply:IsSpec() then return end
        if ply:GetNWBool("ttt2_hd_stalker_mode", false) then return end

        if key == IN_RELOAD then
            ply:SetStalkerMode(true)
            STATUS:AddStatus(ply, "ttt2_hdn_invisbility")
            ply:GiveEquipmentWeapon("weapon_ttt_slk_claws")
        end
    end)
end