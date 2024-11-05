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
    korraksrevenge = true,
  },
}

--[[
-- Warsong Gulch --
-- Instance ID: 2106
-- Zone ID: 1339

-- Arathi Basin --
-- Instance ID: 2107, 2177, 1681
-- Zone ID: 1366, nil, 837

-- Deephaul Ravine --
-- Instance ID: 2656
-- Zone ID: 2345

-- Alterac Valley --
-- Instance ID: 30
-- Zone ID: 91

-- Eye of the Storm --
-- Instance ID: 566, 968
-- Zone ID: 112

-- Isle of Conquest --
-- Instance ID: 628
-- Zone ID: 169

-- The Battle for Gilneas --
-- Instance ID: 761
-- Zone ID: 275

-- Battle for Wintergrasp --
-- Instance ID: 2118
-- Zone ID: 1334

-- Ashran --
-- Instance ID: 1191
-- Zone ID: 1478

-- Twin Peaks --
-- Instance ID: 726
-- Zone ID: 206

-- Silvershard Mines --
-- Instance ID: 727
-- Zone ID: 423

-- Temple of Kotmogu --
-- Instance ID: 998
-- Zone ID: 417

-- Seething Shore --
-- Instance ID: 1803
-- Zone ID: 907

-- Deepwind Gorge --
-- Instance ID: 2245
-- Zone ID: 1576

-- Korrak's Revenge --
-- Instance ID: 2197
-- Zone ID: 1537
--]]
