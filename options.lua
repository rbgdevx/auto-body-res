local AddonName, NS = ...

local LibStub = LibStub
local CopyTable = CopyTable
local next = next
local IsInInstance = IsInInstance

---@type AutoBodyRes
local AutoBodyRes = NS.AutoBodyRes
local AutoBodyResFrame = NS.AutoBodyRes.frame

local Options = {}
NS.Options = Options

local DEAD_EVENTS = {
  "PLAYER_DEAD",
  "PLAYER_SKINNED",
  "CORPSE_IN_RANGE",
  "RESURRECT_REQUEST",
}

NS.AceConfig = {
  name = AddonName,
  type = "group",
  args = {
    lock = {
      name = "Lock the text into place",
      type = "toggle",
      width = "double",
      order = 1,
      set = function(_, val)
        NS.db.global.lock = val
        if val then
          NS.Interface:Lock(NS.Interface.textFrame)
        else
          NS.Interface:Unlock(NS.Interface.textFrame)
        end
      end,
      get = function(_)
        return NS.db.global.lock
      end,
    },
    test = {
      name = "Toggle on placeholder text to test settings",
      desc = "Only works outside of an instance.",
      type = "toggle",
      width = "double",
      order = 2,
      set = function(_, val)
        NS.db.global.test = val
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
        return NS.db.global.test
      end,
    },
    release = {
      name = "Toggle auto-release",
      desc = "Auto releases your body upon death.",
      type = "toggle",
      width = "double",
      order = 3,
      set = function(_, val)
        NS.db.global.release = val
      end,
      get = function(_)
        return NS.db.global.release
      end,
    },
    resurrect = {
      name = "Toggle auto-resurrect",
      desc = "Auto accepts resurrection from a friend, spell, or your from being in-range of your body.",
      type = "toggle",
      width = "double",
      order = 4,
      set = function(_, val)
        NS.db.global.resurrect = val
      end,
      get = function(_)
        return NS.db.global.resurrect
      end,
    },
    onlypvp = {
      name = "Toggle on this addon only in battlegrounds",
      desc = "Toggling this feature off will make it work outside of battlegrounds",
      type = "toggle",
      width = "double",
      order = 5,
      set = function(_, val)
        NS.db.global.onlypvp = val

        if IsInInstance() == false then
          if val == false then
            FrameUtil.RegisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
          else
            FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
          end
        end
      end,
      get = function(_)
        return NS.db.global.onlypvp
      end,
    },
    fontsize = {
      type = "range",
      name = "Font Size",
      width = "double",
      order = 6,
      min = 1,
      max = 500,
      step = 1,
      set = function(_, val)
        NS.db.global.fontsize = val
        NS.UpdateFont(NS.Interface.text)
        NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
      end,
      get = function(_)
        return NS.db.global.fontsize
      end,
    },
    font = {
      type = "select",
      name = "Font",
      width = "double",
      order = 7,
      dialogControl = "LSM30_Font",
      values = AceGUIWidgetLSMlists.font,
      set = function(_, val)
        NS.db.global.font = val
        NS.UpdateFont(NS.Interface.text)
        NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
      end,
      get = function(_)
        return NS.db.global.font
      end,
    },
    color = {
      type = "color",
      name = "Color",
      width = "double",
      order = 8,
      hasAlpha = true,
      set = function(_, val1, val2, val3, val4)
        NS.db.global.color.r = val1
        NS.db.global.color.g = val2
        NS.db.global.color.b = val3
        NS.db.global.color.a = val4
        NS.Interface.text:SetTextColor(val1, val2, val3, val4)
      end,
      get = function(_)
        return NS.db.global.color.r, NS.db.global.color.g, NS.db.global.color.b, NS.db.global.color.a
      end,
    },
    debug = {
      name = "Toggle debug mode",
      desc = "Turning this feature on prints debug messages to the chat window.",
      type = "toggle",
      width = "full",
      order = 99,
      set = function(_, val)
        NS.db.global.debug = val
      end,
      get = function(_)
        return NS.db.global.debug
      end,
    },
    reset = {
      name = "Reset Everything",
      type = "execute",
      width = "normal",
      order = 100,
      func = function()
        AutoBodyResDB = CopyTable(NS.DefaultDatabase)
        NS.db = CopyTable(NS.DefaultDatabase)
        NS.UpdateFont(NS.Interface.text)
        NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
      end,
    },
  },
}

function Options:SlashCommands(message)
  if message == "toggle lock" then
    if NS.db.global.general.lock == false then
      NS.db.global.general.lock = true
    else
      NS.db.global.general.lock = false
    end
  else
    LibStub("AceConfigDialog-3.0"):Open(AddonName)
  end
end

function Options:Setup()
  LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, NS.AceConfig)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonName, AddonName)

  SLASH_ABR1 = AddonName
  SLASH_ABR2 = "/abr"

  function SlashCmdList.ABR(message)
    self:SlashCommands(message)
  end
end

function AutoBodyRes:ADDON_LOADED(addon)
  if addon == AddonName then
    AutoBodyResFrame:UnregisterEvent("ADDON_LOADED")

    AutoBodyResDB = AutoBodyResDB and next(AutoBodyResDB) ~= nil and AutoBodyResDB or {}

    -- Copy any settings from default if they don't exist in current profile
    NS.CopyDefaults(NS.DefaultDatabase, AutoBodyResDB)

    -- Reference to active db profile
    -- Always use this directly or reference will be invalid
    NS.db = AutoBodyResDB

    -- Remove table values no longer found in default settings
    NS.CleanupDB(AutoBodyResDB, NS.DefaultDatabase)

    Options:Setup()
  end
end
AutoBodyResFrame:RegisterEvent("ADDON_LOADED")
