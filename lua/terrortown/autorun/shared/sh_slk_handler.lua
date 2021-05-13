if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then
    AddCSLuaFile()

    util.AddNetworkString("ttt2_slk_epop")
    util.AddNetworkString("ttt2_slk_epop_defeat")
    util.AddNetworkString("ttt2_slk_network_wep")
end

local plymeta = FindMetaTable("Player")

if not plymeta then
    Error("[TTT2 STALKER] FAILED TO FIND PLAYER TABLE")
end

if CLIENT then
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1 Load Stalker Handler")
    -- HiddenWallhack not for stalker

    -- DoHiddenVision (hook("RenderScreenspaceEffects")) in sh_hd_handler
end


if SERVER then

    -- using plymeta:SetCloakMode

    -- using plymeta:GetloakMode

    -- using plymeta:UpdateCloaking

    -- using hook "HiddenCloakThink"

    -- TODO: Has to be reimplemente. Any way round this?
    local function BetterWeaponStrip(ply, exclude_class)
        if not ply or not IsValid(ply) or not ply:IsPlayer() then return end

        local weps = ply:GetWeapons()
        for i = 1, #weps do
          local wep = weps[i]
          local wep_class = wep:GetClass()
          if (wep.Kind == WEAPON_EQUIP or wep.Kind == WEAPON_EQUIP2 or wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL or wep.Kind == WEAPON_NADE) and not exclude_class[wep_class] then
            ply:StripWeapon(wep_class)
          else
            wep.WorldModel = ""
            net.Start("ttt2_slk_network_wep")
            net.WriteEntity(wep)
            net.WriteString(wep.WorldModel)
            net.Broadcast()
          end
        end
    end

    function plymeta:ActivateStalkerStalker()
        if self:GetSubRole() ~= ROLE_STALKER then return end

        print("Activate Stalker")

        local exclude_tbl = {}
        exclude_tbl["weapon_ttt_hd_knife"] = true
        exclude_tbl["weapon_ttt_slk_claws"] = true
        --exclude_tbl["weapon_ttt_hd_nade"] = true
        BetterWeaponStrip(self, exclude_tbl)

        self:SetNWBool("ttt2_hd_stalker_mode", true)
        self:UpdateCloaking()

        -- events.Trigger(EVENT_HDN_ACTIVATE, self)
    end

    function plymeta:DeactivateStalkerStalker()
        self:SetNWBool("ttt2_hd_stalker_mode", false)
        self:UpdateCloaking()
        -- DeactivateCloaking(self)
    end

    function plymeta:SetStalkerMode_slk(bool)
        if bool then
            self:ActivateStalkerStalker()
            net.Start("ttt2_slk_epop")
            net.WriteString(self:Nick())
            -- net.SendOmit(self)
            net.Broadcast()
        else
            self:DeactivateStalkerStalker()
        end
    end

    -- using ResetHiddenRole from Hidden and their hooks,
    -- probably need to implement for own NetVars

    hook.Add("PlayerCanPickupWeapon", "NoStalkerPickups", function(ply, wep)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_hd_stalker_mode", false) then return end

        return (wep:GetClass() == "weapon_ttt_hd_knife" or wep:GetClass() == "weapon_ttt_slk_claws")
    end)

    -- hook.Add("PlayerCanPickupWeapon", "NoPickupHiddenKnife", function(ply, wep)
    --     if wep:GetClass() ~= "weapon_ttt_hd_knife" then return end
    --     if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end

    --     return ply:GetSubRole() == ROLE_STALKER
    -- end)

    hook.Add("TTTPlayerSpeedModifier", "StalkerSpeedBonus", function(ply, _, _, speedMod)
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_hd_stalker_mode") then return end

        speedMod[1] = speedMod[1] * 1.8
    end)

     hook.Add("TTT2StaminaRegen", "StalkerStaminaMod", function(ply, stamMod)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_hd_stalker_mode") then return end

        stamMod[1] = stamMod[1] * 1.8
    end)

    -- using hook("ScalePlayerDamage") of hidden

    hook.Add("DoPlayerDeath", "TTT2StalkerDied", function(ply, attacker, dmgInfo)
        if ply:GetSubRole() ~= ROLE_STALKER or not ply:GetNWBool("ttt2_hd_stalker_mode", false) then return end

        ply:SetStalkerMode_slk(false)
        -- events.Trigger(EVENT_HDN_DEFEAT, ply, attacker, dmgInfo)
        net.Start("ttt2_slk_epop_defeat")
        net.WriteString(ply:Nick())
        net.Broadcast()
    end)

    -- using hook("PlayerSPawn") of hidden

end

if CLIENT then
    net.Receive("ttt2_slk_epop", function()
        EPOP:AddMessage({
            text = LANG.GetParamTranslation("slk_epop_title", {nick = net.ReadString()}),
            color = HIDDEN.ltcolor
            },
            LANG.GetTranslation("slk_epop_desc")
        )
    end)

    net.Receive("ttt2_slk_epop_defeat", function()
        EPOP:AddMessage({
            text = LANG.GetParamTranslation("slk_epop_defeat_title", {nick = net.ReadString()}),
            color = HIDDEN.ltcolor
            },
            LANG.GetTranslation("slk_epop_defeat_desc")
        )
    end)

    net.Receive("ttt2_slk_network_wep", function()
                net.ReadEntity().WorldModel = net.ReadString()
    end)
end