local _, NS = ...

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
---@field onlypvp boolean
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

local AutoBodyResFrame = CreateFrame("Frame", "AutoBodyResFrame")
AutoBodyResFrame:SetScript("OnEvent", function(_, event, ...)
  if AutoBodyRes[event] then
    AutoBodyRes[event](AutoBodyRes, ...)
  end
end)
NS.AutoBodyRes.frame = AutoBodyResFrame

NS.DefaultDatabase = {
  global = {
    lock = false,
    test = true,
    release = true,
    resurrect = true,
    onlypvp = true,
    fontsize = 40,
    font = "Friz Quadrata TT",
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
    debug = false,
  },
}
