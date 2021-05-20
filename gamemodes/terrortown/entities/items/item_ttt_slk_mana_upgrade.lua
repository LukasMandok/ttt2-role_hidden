if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgiu/ttt/icon_slk_mana_upgrade")
    resource.AddFile("materials/vgui/ttt/hud_icon_slk_mana_upgrade") --.png
end

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "item_slk_mana_upgrade_name",
    desc = "item_slk_mana_upgrade_desc"
}

ITEM.PrintName = "item_slk_lifesteal_name"

ITEM.CanBuy   = {ROLE_STALKER}
ITEM.limited  = false

ITEM.ManaUpgrade = 100

if CLIENT then
    ITEM.material = "vgui/ttt/icon_slk_mana_upgrade"
    ITEM.hud      = Material("vgui/ttt/hud_icon_slk_mana_upgrade")  --.png
end

if SERVER then
    function ITEM:Equip(ply)
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:Alive() or ply:IsSpec() then return end

        ply:SetNWInt("ttt2_stalker_mana_max", ply:GetNWInt("ttt2_stalker_mana_max") + self.ManaUpgrade)
    end
end