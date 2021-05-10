if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then
    AddCSLuaFile()
end

roles.InitCustomTeam(ROLE.name, {
    icon = "vgui/ttt/dynamic/roles/icon_hdn",
    color = Color(0, 49, 82, 255)
})

function ROLE:PreInitialize()
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
    --roles.SetBaseRole(self, ROLE_HIDDEN)
    if SERVER and JESTER then
        self.networkRoles = {JESTER}
    end
end