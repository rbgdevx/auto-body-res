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
local select = select
local UnitClass = UnitClass
local GetClassColor = GetClassColor
local print = print

local mfloor = math.floor

local After = C_Timer.After

local SharedMedia = LibStub("LibSharedMedia-3.0")

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
  frame:SetFont(SharedMedia:Fetch("font", NS.db.global.font), NS.db.global.fontsize, "OUTLINE")
end

NS.UpdateColor = function(frame)
  frame:SetTextColor(NS.db.global.color.r, NS.db.global.color.g, NS.db.global.color.b, NS.db.global.color.a)
end

NS.secondsToMinutes = function(seconds)
  return seconds / SECONDS_PER_MIN
end

NS.minutesToSeconds = function(minutes)
  return minutes * SECONDS_PER_MIN
end

NS.secondsToClock = SecondsToClock

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

NS.IsEpicBattleground = function(instanceID)
  local INSTANCE_IDS = {
    [30] = true, -- alteracvalley
    [1191] = true, -- ashran
    [2118] = true, -- battleforwintergrasp
    [628] = true, -- isleofconquest
    [2197] = true, -- korraksrevenge -- isBrawl
    -- [1191] = true, -- classicashran -- isBrawl
    [1280] = true, -- tarrenmillvssouthshore -- isBrawl
  }
  return INSTANCE_IDS[instanceID]
end

NS.isEpicBattlegroundAllowed = function(instanceID)
  local INSTANCE_IDS = {
    [30] = NS.db.global.alteracvalley,
    [1191] = NS.db.global.ashran,
    [2118] = NS.db.global.battleforwintergrasp,
    [628] = NS.db.global.isleofconquest,
    [2197] = NS.db.global.korraksrevenge, -- isBrawl
    -- [1191] = NS.db.global.classicashran, -- isBrawl
    [1280] = NS.db.global.tarrenmillvssouthshore, -- isBrawl
  }
  return INSTANCE_IDS[instanceID]
end

NS.isBrawlAllowed = function(brawlID)
  local BRAWL_IDS = {
    [5] = NS.db.global.arathiblizzard,
    [0] = NS.db.global.compstomp,
    [17] = NS.db.global.cookingimpossible,
    [11] = NS.db.global.deepsix,
    -- [6] = NS.db.global.deepwinddunk, -- needs brawl id check
    [4] = NS.db.global.gravitylapse,
    [3] = NS.db.global.templeofhotmogu,
    [9] = NS.db.global.warsongscramble,
    -- [2197] = true, -- korraksrevenge -- needs brawl id check
    [120] = NS.db.global.classicashran, -- classicashran
    [2] = NS.db.global.tarrenmillvssouthshore, -- tarrenmillvssouthshore
  }
  return BRAWL_IDS[brawlID]
end

NS.isBattlegroundAllowed = function(instanceID)
  local INSTANCE_IDS = {
    [2107] = NS.db.global.arathibasin,
    [2656] = NS.db.global.deephaulravine,
    [2245] = NS.db.global.deepwindgorge,
    [566] = NS.db.global.eyeofthestorm,
    [968] = NS.db.global.eyeofthestorm,
    [1803] = NS.db.global.seethingshore,
    [727] = NS.db.global.silvershardmines,
    [761] = NS.db.global.thebattleforgilneas,
    [998] = NS.db.global.templeofkotmogu,
    [726] = NS.db.global.twinpeaks,
    [2106] = NS.db.global.warsonggulch,
  }
  return INSTANCE_IDS[instanceID]
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
