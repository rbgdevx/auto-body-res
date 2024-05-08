local AddonName, NS = ...

local AutoBodyRes = LibStub("AceAddon-3.0"):GetAddon(AddonName)

local IsInInstance = IsInInstance

NS.AceConfig = {
  name = AddonName,
  type = "group",
  args = {
    lock = {
      name = "Lock the text into place",
      type = "toggle",
      width = "double",
      set = function(_, val)
        AutoBodyRes.db.global.lock = val
        if val then
          NS.Interface:Lock(NS.Interface.textFrame)
        else
          NS.Interface:Unlock(NS.Interface.textFrame)
        end
      end,
      get = function(_)
        return AutoBodyRes.db.global.lock
      end,
    },
    test = {
      name = "Toggle on placeholder text to test settings",
      desc = "Only works outside of an instance.",
      type = "toggle",
      width = "double",
      set = function(_, val)
        AutoBodyRes.db.global.test = val
        if IsInInstance() == false then
          if val then
            NS.Interface.text:SetText("CAN BODY RES NOW")
            NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
            NS.Interface.textFrame:Show()
          else
            NS.Interface.text:SetText("")
            NS.Interface.textFrame:SetWidth(0)
            NS.Interface.textFrame:SetHeight(0)
            NS.Interface.textFrame:Hide()
          end
        end
      end,
      get = function(_)
        return AutoBodyRes.db.global.test
      end,
    },
    release = {
      name = "Toggle auto-release",
      desc = "Auto releases your body upon death.",
      type = "toggle",
      width = "double",
      set = function(_, val)
        AutoBodyRes.db.global.release = val
      end,
      get = function(_)
        return AutoBodyRes.db.global.release
      end,
    },
    resurrect = {
      name = "Toggle auto-resurrect",
      desc = "Auto accepts resurrection from a friend, spell, or your from being in-range of your body.",
      type = "toggle",
      width = "double",
      set = function(_, val)
        AutoBodyRes.db.global.resurrect = val
      end,
      get = function(_)
        return AutoBodyRes.db.global.resurrect
      end,
    },
    onlypvp = {
      name = "Toggle on this addon only in battlegrounds",
      desc = "Toggling this feature off will make it work outside of battlegrounds",
      type = "toggle",
      width = "double",
      set = function(_, val)
        AutoBodyRes.db.global.onlypvp = val

        if IsInInstance() == false then
          if val == false then
            AutoBodyRes:PlayerDeadEvents()
          else
            AutoBodyRes:UnregisterEvent("PLAYER_DEAD")
            AutoBodyRes:UnregisterEvent("PLAYER_SKINNED")
            AutoBodyRes:UnregisterEvent("CORPSE_IN_RANGE")
            AutoBodyRes:UnregisterEvent("RESURRECT_REQUEST")
          end
        end
      end,
      get = function(_)
        return AutoBodyRes.db.global.onlypvp
      end,
    },
    fontsize = {
      type = "range",
      name = "Font Size",
      width = "double",
      min = 1,
      max = 500,
      step = 1,
      set = function(_, val)
        AutoBodyRes.db.global.fontsize = val
        NS.UpdateFont(NS.Interface.text)
        NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
      end,
      get = function(_)
        return AutoBodyRes.db.global.fontsize
      end,
    },
    font = {
      type = "select",
      name = "Font",
      width = "double",
      dialogControl = "LSM30_Font",
      values = AceGUIWidgetLSMlists.font,
      set = function(_, val)
        AutoBodyRes.db.global.font = val
        NS.UpdateFont(NS.Interface.text)
        NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
      end,
      get = function(_)
        return AutoBodyRes.db.global.font
      end,
    },
    color = {
      type = "color",
      name = "Color",
      width = "double",
      hasAlpha = true,
      set = function(_, val1, val2, val3, val4)
        AutoBodyRes.db.global.color.r = val1
        AutoBodyRes.db.global.color.g = val2
        AutoBodyRes.db.global.color.b = val3
        AutoBodyRes.db.global.color.a = val4
        NS.Interface.text:SetTextColor(val1, val2, val3, val4)
      end,
      get = function(_)
        return AutoBodyRes.db.global.color.r,
          AutoBodyRes.db.global.color.g,
          AutoBodyRes.db.global.color.b,
          AutoBodyRes.db.global.color.a
      end,
    },
  },
}

function AutoBodyRes:SetupOptions()
  LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, NS.AceConfig)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonName, AddonName)
end
