local _, NS = ...

local LibStub = LibStub
local type = type
local next = next
local pairs = pairs
local wipe = wipe
local getmetatable = getmetatable
local setmetatable = setmetatable
local RetrieveCorpse = RetrieveCorpse -- Resurrects when the player is standing near its corpse.
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local format = format
local select = select
local UnitClass = UnitClass
local GetClassColor = GetClassColor
local print = print

local mfloor = math.floor
local mmax = math.max

local After = C_Timer.After

local LSM = LibStub("LibSharedMedia-3.0")

NS.write = function(...)
  local playerClass = select(2, UnitClass("player"))
  local playerClassHexColor = "|c" .. select(4, GetClassColor(playerClass))
  print(playerClassHexColor .. "AutoBodyRes|r: ", ...)
end

NS.isDead = function()
  return UnitIsDeadOrGhost("player")
end

NS.UpdateSize = function(frame, text)
  frame:SetWidth(text:GetStringWidth())
  frame:SetHeight(text:GetStringHeight())
end

NS.UpdateFont = function(frame)
  frame:SetFont(LSM:Fetch("font", NS.db.global.font), NS.db.global.fontsize, "OUTLINE")
end

NS.secondsToMinutes = function(seconds)
  return seconds / SECONDS_PER_MIN
end

NS.minutesToSeconds = function(minutes)
  return minutes * SECONDS_PER_MIN
end

function ConvertSecondsToUnits(timestamp)
  timestamp = mmax(timestamp, 0)
  local days = mfloor(timestamp / SECONDS_PER_DAY)
  timestamp = timestamp - (days * SECONDS_PER_DAY)
  local hours = mfloor(timestamp / SECONDS_PER_HOUR)
  timestamp = timestamp - (hours * SECONDS_PER_HOUR)
  local minutes = mfloor(timestamp / SECONDS_PER_MIN)
  timestamp = timestamp - (minutes * SECONDS_PER_MIN)
  local seconds = mfloor(timestamp)
  local milliseconds = timestamp - seconds
  return {
    days = days,
    hours = hours,
    minutes = minutes,
    seconds = seconds,
    milliseconds = milliseconds,
  }
end

NS.secondsToClock = function(seconds, displayZeroHours)
  local units = ConvertSecondsToUnits(seconds)
  if units.hours > 0 or displayZeroHours then
    return format(HOURS_MINUTES_SECONDS, units.hours, units.minutes, units.seconds)
  else
    return format(MINUTES_SECONDS, units.minutes, units.seconds)
  end
end

NS.getSeconds = function(time)
  return time % SECONDS_PER_MIN
end

NS.getMinutes = function(time)
  return mfloor(time / SECONDS_PER_MIN)
end

NS.formatTime = function(time)
  return NS.secondsToClock(time, false)
  -- return sformat("%02d:%02d", NS.getMinutes(time), NS.getSeconds(time))
end

NS.RetrieveBody = function()
  RetrieveCorpse()
  After(0, function()
    if NS.isDead() then
      RetrieveCorpse()
    end
  end)
end

NS.IsEpicBattleground = function(instanceName)
  local EPIC_BATTLEGROUNDS = {
    ["Alterac Valley"] = true,
    ["Ashran"] = true,
    ["Isle of Conquest"] = true,
    ["Battle for Wintergrasp"] = true,
  }
  return EPIC_BATTLEGROUNDS[instanceName]
end

NS.isMapAllowed = function(instanceName)
  local MAPS = {
    -- battlegrounds
    ["Arathi Basin"] = NS.db.global.arathibasin,
    ["Deephaul Ravine"] = NS.db.global.deephaulravine,
    ["Deepwind Gorge"] = NS.db.global.deepwindgorge,
    ["Eye of the Storm"] = NS.db.global.eyeofthestorm,
    ["Seething Shore"] = NS.db.global.seethingshore,
    ["Silvershard Mines"] = NS.db.global.silvershardmines,
    ["The Battle for Gilneas"] = NS.db.global.thebattleforgilneas,
    ["Temple of Kotmogu"] = NS.db.global.templeofkotmogu,
    ["Twin Peaks"] = NS.db.global.twinpeaks,
    ["Warsong Gulch"] = NS.db.global.warsonggulch,
    -- epic battlegrounds
    ["Alterac Valley"] = NS.db.global.alteracvalley,
    ["Ashran"] = NS.db.global.ashran,
    ["Battle for Wintergrasp"] = NS.db.global.battleforwintergrasp,
    ["Isle of Conquest"] = NS.db.global.isleofconquest,
    -- brawl battlegrounds
    ["Arathi Basin Winter"] = NS.db.global.arathiblizzard,
    ["Korrak's Revenge"] = NS.db.global.korraksrevenge,
  }
  return MAPS[instanceName]
end

NS.CopyTable = function(src, dest)
  -- Handle non-tables and previously-seen tables.
  if type(src) ~= "table" then
    return src
  end

  if dest and dest[src] then
    return dest[src]
  end

  -- New table; mark it as seen an copy recursively.
  local s = dest or {}
  local res = {}
  s[src] = res

  for k, v in next, src do
    res[NS.CopyTable(k, s)] = NS.CopyTable(v, s)
  end

  return setmetatable(res, getmetatable(src))
end

-- Copies table values from src to dst if they don't exist in dst
NS.CopyDefaults = function(src, dst)
  if type(src) ~= "table" then
    return {}
  end
  if type(dst) ~= "table" then
    dst = {}
  end
  for k, v in pairs(src) do
    if type(v) == "table" then
      dst[k] = NS.CopyDefaults(v, dst[k])
    elseif type(v) ~= type(dst[k]) then
      dst[k] = v
    end
  end
  return dst
end

-- Cleanup savedvariables by removing table values in src that no longer
-- exists in table dst (default settings)
NS.CleanupDB = function(src, dst)
  for key, value in pairs(src) do
    if dst[key] == nil then
      if key ~= "version" then
        src[key] = nil
      end
    elseif type(value) == "table" then
      dst[key] = NS.CleanupDB(value, dst[key])
    end
  end
  return dst
end

-- Pool for reusing tables. (Garbage collector isn't ran in combat unless max garbage is reached, which causes fps drops)
do
  local pool = {}

  NS.NewTable = function()
    local t = next(pool) or {}
    pool[t] = nil -- remove from pool
    return t
  end

  NS.RemoveTable = function(tbl)
    if tbl then
      pool[wipe(tbl)] = true -- add to pool, wipe returns pointer to tbl here
    end
  end

  NS.ReleaseTables = function()
    if next(pool) then
      pool = {}
    end
  end
end
