local base = "octagonal_target" -- "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then

	--local pad = 7
	--local iconSize = 64

	-- local const_defaults = {
	-- 	basepos = {x = 0, y = 0},
	-- 	size = {w = 365, h = 40}, -- 321
	-- 	minsize = {w = 225, h = 40} --75
	-- }

	function HUDELEMENT:PreInitialize()
		--print("PreInitialize: Octagonal", self.Base)
		BaseClass.PreInitialize(self)

		local hud = huds.GetStored("octagonal")
		if hud then
			--print("ForceELement:", self.id)
			hud:ForceElement(self.id)
		end

		self.disabledUnlessForced = true
	end

	-- function HUDELEMENT:Initialize()
	-- 	print("Initialize: Octagonal")
	-- 	self.scale = 1.0
	-- 	self.basecolor = self:GetHUDBasecolor()
	-- 	self.pad = pad
	-- 	self.iconSize = iconSize

	-- 	BaseClass.Initialize(self)
	-- end

	-- parameter overwrites
	-- function HUDELEMENT:IsResizable()
	-- 	return true, false
	-- end
	-- parameter overwrites end

	-- function HUDELEMENT:GetDefaults()
	-- 	-- const_defaults["basepos"] = {x = math.Round(ScrW() * 0.5 - self.size.w * 0.5), y = ScrH() - self.pad - self.size.h}
	-- 	const_defaults["basepos"] = {
	-- 		x = 10 * self.scale,
	-- 		y = ScrH() - self.size.h - 146 * self.scale - self.pad - 10 * self.scale
	-- 	}
	-- 	return const_defaults
	-- end

	function HUDELEMENT:ShouldDraw()
		local client = LocalPlayer()

		print("ShouldDraw octagonal")

		return HUDEditor.IsEditing or (client:IsActive() and client:Alive() and client:GetSubRole() == ROLE_STALKER and client:GetNWBool("ttt2_hd_stalker_mode", false))
		-- pure_skin: return IsValid(client) 
		-- octagonal: return HUDEditor.IsEditing or client.drowningProgress and client:Alive() and client.drowningProgress ~= -1
	end

	-- function HUDELEMENT:PerformLayout()
	-- 	self.scale = self:GetHUDScale()
	-- 	self.basecolor = self:GetHUDBasecolor()
	-- 	self.iconSize = iconSize * self.scale
	-- 	self.pad = pad * self.scale

	-- 	BaseClass.PerformLayout(self)
	-- end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		local mana = client:GetNWInt("ttt2_stalker_mana", 0)

		-- draw bg and shadow
		self:DrawBg(x, y, w, h, self.basecolor)
		self:DrawBg(x, y, self.pad, h, self.extraBarColor)
		self:DrawBg(x, y, self.pad, h, self.darkOverlayColor)

		local name = "Test"
		draw.AdvancedText(name, "OctagonalBar", x + self.iconSize + 2 * self.pad + 4, y + h * 0.5, util.GetDefaultColor(self.basecolor), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, false, self.scale)

		--           x,            y, width,        height, color,         progress,                                    scale,      text,                                textpadding
		self:DrawBar(x + self.pad, y, w - self.pad, h, self.extraBarColor, (HUDEditor.IsEditing and 1) or (mana / 100), self.scale, LANG.GetTranslation("slk_mana_name"))
	end
end
