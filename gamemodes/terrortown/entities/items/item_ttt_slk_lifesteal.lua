if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgiu/ttt/icon_slk_lifesteal")
    resource.AddFile("materials/vgui/ttt/hud_icon_slk_lifesteal") --.png
end

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "item_slk_lifesteal_name",
    desc = "item_slk_lifesteal_desc"
}

ITEM.material = "vgui/ttt/icon_slk_lifesteal"
ITEM.CanBuy   = {ROLE_STALKER}
ITEM.hud      = Material("vgui/ttt/hud_icon_slk_lifesteal")  --.png

if SERVER then
    
end