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

---@class RoleTable : table
---@field enabled boolean
---@field all boolean
---@field tank boolean
---@field healer boolean
---@field dps boolean

---@class GlobalTable : table
---@field release boolean
---@field resurrect boolean
---@field text boolean
---@field outside boolean
---@field leave boolean
---@field leaveDelay number
---@field role RoleTable
---@field readyCheck boolean
---@field resurrectDelay number
---@field releaseDelay number
---@field introShown boolean
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

NS.PLACEHOLDER_TEXT = "BODY RES AVAILABLE"

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
    release = true,
    resurrect = true,
    text = true,
    outside = false,
    leave = false,
    leaveDelay = 5,
    role = {
      enabled = false,
      all = true,
      tank = true,
      healer = true,
      dps = true,
    },
    readyCheck = false,
    resurrectDelay = 0,
    releaseDelay = 0,
    introShown = false,
    disableblitz = false,
    disablerated = false,
    disablerandom = false,
    disableepic = false,
    disablebrawl = false,
    fontsize = 32,
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
