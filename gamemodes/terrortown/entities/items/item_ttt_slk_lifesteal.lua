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

ITEM.PrintName = "item_slk_lifesteal_name"

ITEM.CanBuy   = {ROLE_STALKER}
ITEM.limited = true

if CLIENT then
    ITEM.material = "vgui/ttt/icon_slk_lifesteal"
    ITEM.hud      = Material("vgui/ttt/hud_icon_slk_lifesteal")  --.png
end

ITEM.RegenTime = 2
ITEM.RegenTimeCorpse = 5


if SERVER then

    -- Sets the time, where the Item can regenerate Health again
    function ITEM:SetNextRegen(time)
        self.NextRegen = CurTime() + (time or self.RegenTime)
    end

    -- Tests if the item can regenerate health
    function ITEM:CanRegen()
        return self.NextRegen < CurTime()
    end

    function ITEM:AddHealth(health)
        local owner = self:GetOwner()

        if owner:GetHealth() == owner:GetMaxHealth() then return end

        -- Clamp between 0 and Maximum Health
        -- TODO: Maybe not needed: CHECK THIS!
        owner:SetHealth( math.Clamp(owner:GetHealth() + health, 0, owner:GetMaxHealth()))
    end


    local function HitPlayer(tgt, dmg)
        if not ITEM:CanRegen() then return end

        local health = tgt:Health()
        if  health < (dmg + 5) then
            ITEM:AddHealth(health * 0.2 + 20)
            ITEM:SetNextRegen()
        else
            ITEM:AddHealth(dmg * 0.2)
            ITEM:SetNextRegen()
        end
    end

    local function HitRagdoll(tgt, dmg)
        if not ITEM:CanRegen() then return end

        tgt.lifesteal_hits = tgt.lifesteal_hits or 1

        if tgt.lifesteal_hits >= 5 then return end

        ITEM:AddHealth(dmg * 0.4)
        ITEM:SetNextRegen(ITEM.RegenTimeCorpse)
        tgt.lifesteal_hits = tgt.lifesteal_hits + 1
    end

    function ITEM:Initialize()
        -- TODO: Primary entfernen oder so...
        hook.Add("ttt_slk_claws_hit", function(owner, tgt, dmg, primary)
            if owner ~= ITEM:GetOwner() then
                print("Owner is not Owner of this Weapon.  Owner:", owner, "self:GetOwner:", ITEM:GetOwner())
            return end

            if tgt:IsPlayer() and primary then
                HitPlayer(tgt, dmg)
            elseif tgt:IsRagdoll() and primary then
                HitRagdoll(tgt, dmg)
            end
        end)
    end
end