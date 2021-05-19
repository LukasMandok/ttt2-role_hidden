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

ITEM.material = "vgui/ttt/icon_slk_mana_upgrade"
ITEM.CanBuy   = {ROLE_STALKER}
ITEM.hud      = Material("vgui/ttt/hud_icon_slk_mana_upgrade")  --.png

if SERVER then
    
end