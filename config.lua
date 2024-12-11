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
  [10] = "Shado-Pan Showdown",
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

NS.INSTANCE_IDS = {
  -- battlegrounds
  2107, -- "Arathi Basin"
  2656, -- "Deephaul Ravine"
  2245, -- "Deepwind Gorge"
  566, -- "Eye of the Storm Normal",
  968, -- "Eye of the Storm Rated"
  1803, -- "Seething Shore"
  727, -- "Silvershard Mines"
  761, -- "The Battle for Gilneas"
  998, -- "Temple of Kotmogu"
  726, -- "Twin Peaks"
  2106, -- "Warsong Gulch"
  -- epic battlegrounds
  30, -- "Alterac Valley"
  1191, -- "Ashran"
  2118, -- "Battle for Wintergrasp"
  -- 628, -- "Classic Ashran"
  628, -- "Isle of Conquest"
  2197, -- "Korrak's Revenge"
  -- 2197, -- "Tarren Mill vs Southshore"
  -- brawl battlegrounds
  1681, -- "Arathi Blizzard"
  2177, -- "Comp Stomp"
  1691, -- "Cooking Impossible"
  -- 1691, -- "Deep Six"
  -- 1691, -- "Deepwind Dunk"
  566, --  "Gravity Lapse"
  -- 2106, -- "Temple of Hotmogu"
  2106, -- "Warsong Scramble"
}

NS.INSTANCE_NAMES = {
  -- battlegrounds
  "Arathi Basin",
  "Deephaul Ravine",
  "Deepwind Gorge",
  "Eye of the Storm",
  "Seething Shore",
  "Silvershard Mines",
  "The Battle for Gilneas",
  "Temple of Kotmogu",
  "Twin Peaks",
  "Warsong Gulch",
  -- epic battlegrounds
  "Alterac Valley",
  "Ashran",
  "Battle for Wintergrasp",
  "Isle of Conquest",
  -- brawl battlegrounds
  "Arathi Basin Comp Stomp",
  "Arathi Basin Winter",
  "Classic Ahsran",
  "Cooking Impossible",
  "Deep Siz",
  "Deepwind Dunk",
  "Gravity Lapse",
  "Korrak's Revenge",
  "Tarren Mill vs Southshore",
  "Temple of Hotmogu",
  "Warsong Scramble",
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

--[[
-- Warsong Gulch --
-- Instance ID: 2106
-- Zone ID: 1339

-- Arathi Basin --
-- Instance ID: 2107
-- Zone ID: 1366

-- Deephaul Ravine --
-- Instance ID: 2656
-- Zone ID: 2345

-- Alterac Valley --
-- Instance ID: 30
-- Zone ID: 91

-- Eye of the Storm --
-- Instance ID: 566, 566, 968
-- Zone ID: 112, 112, 112

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

-- Arathi Basin Comp Stomp --
-- Instance ID: 2177
-- Zone ID: 1383

-- Deepwind Dunk
-- Instance ID:
-- Zone ID:

-- Warsong Scramble
-- Instance ID: 2106
-- Zone ID: 1339
-- Brawl ID: 9

-- Arathi Basin Winter
-- Instance ID: 1681
-- Instance Type ID: 3
-- Zone ID: 837
-- Brawl ID:

-- Temple of Hotmogu
-- Instance ID:
-- Instance Type ID:
-- Zone ID:
-- Brawl ID:

-- Cooking Impossible
-- Instance ID: 1691
-- Instance Type ID:
-- Zone ID: 1335
-- Brawl ID: 17
--]]
