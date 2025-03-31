local AddonName, NS = ...

local CreateFrame = CreateFrame

---@class PositionArray
---@field[1] string
---@field[2] string
---@field[3] number
---@field[4] number

---@class ColorArray
---@field r number
---@field g number
---@field b number
---@field a number

---@class GlobalTable : table
---@field lock boolean
---@field test boolean
---@field release boolean
---@field text boolean
---@field outside boolean
---@field fontsize number
---@field font string
---@field color ColorArray
---@field position PositionArray
---@field debug boolean

---@class DBTable : table
---@field global GlobalTable

---@class AutoBodyRes
---@field ADDON_LOADED function
---@field PLAYER_LOGIN function
---@field CORPSE_IN_RANGE function
---@field RESURRECT_REQUEST function
---@field PLAYER_DEAD function
---@field PLAYER_UNGHOST function
---@field PLAYER_SKINNED function
---@field PLAYER_ENTERING_WORLD function
---@field PlayerDead function
---@field PlayerDeadEvents function
---@field SlashCommands function
---@field frame Frame
---@field db DBTable

---@type AutoBodyRes
---@diagnostic disable-next-line: missing-fields
local AutoBodyRes = {}
NS.AutoBodyRes = AutoBodyRes

local AutoBodyResFrame = CreateFrame("Frame", AddonName .. "Frame")
AutoBodyResFrame:SetScript("OnEvent", function(_, event, ...)
  if AutoBodyRes[event] then
    AutoBodyRes[event](AutoBodyRes, ...)
  end
end)
NS.AutoBodyRes.frame = AutoBodyResFrame

NS.PLACEHOLDER_TEXT = "PLACEHOLDER TEXT"

NS.BRAWL_IDS = {
  [17] = "Cooking Impossible",
  [9] = "Warsong Scramble",
  -- [10] = "Shado-Pan Showdown",
  -- [8] = "Packed House",
  [11] = "Deep Six",
  [5] = "Arathi Blizzard",
  [4] = "Gravity Lapse",
}

NS.INSTANCE_TYPES = {
  [0] = "none",
  [1] = "party",
  [2] = "raid",
  [3] = "pvp",
  [4] = "arena",
  [5] = "scenario",
  [6] = "unknown", -- Used by a single map: Void Zone: Arathi Highlands (2695)
}

NS.DefaultDatabase = {
  global = {
    lock = false,
    test = true,
    release = true,
    resurrect = true,
    text = true,
    outside = false,
    disableblitz = false,
    disablerated = false,
    disablerandom = false,
    disableepic = false,
    disablebrawl = false,
    fontsize = 36,
    font = "Friz Quadrata TT",
    debug = false,
    color = {
      r = 176 / 255,
      g = 43 / 255,
      b = 43 / 255,
      a = 1,
    },
    position = {
      "CENTER",
      "CENTER",
      0,
      0,
    },
    allmaps = true,
    -- battlegrounds
    arathibasin = true,
    deephaulravine = true,
    deepwindgorge = true,
    eyeofthestorm = true,
    seethingshore = true,
    silvershardmines = true,
    thebattleforgilneas = true,
    templeofkotmogu = true,
    twinpeaks = true,
    warsonggulch = true,
    -- epic battlegrounds
    alteracvalley = true,
    ashran = true,
    battleforwintergrasp = true,
    isleofconquest = true,
    -- brawl battlegrounds
    arathiblizzard = true,
    classicashran = true,
    compstomp = true,
    cookingimpossible = true,
    deepsix = true,
    deepwinddunk = true,
    gravitylapse = true,
    korraksrevenge = true,
    tarrenmillvssouthshore = true,
    templeofhotmogu = true,
    warsongscramble = true,
  },
}
