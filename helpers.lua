local _, NS = ...

local LibStub = LibStub
local RetrieveCorpse = RetrieveCorpse -- Resurrects when the player is standing near its corpse.
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

local sformat = string.format
local mfloor = math.floor

local After = C_Timer.After

local LSM = LibStub("LibSharedMedia-3.0")

NS.isDead = function()
  return UnitIsDeadOrGhost("player")
end

NS.UpdateSize = function(frame, text)
  frame:SetWidth(text:GetStringWidth())
  frame:SetHeight(text:GetStringHeight())
end

NS.UpdateFont = function(frame)
  frame:SetFont(LSM:Fetch("font", AutoBodyRes.db.global.font), AutoBodyRes.db.global.fontsize, "THINOUTLINE")
end

NS.getSeconds = function(time)
  return time % 60
end

NS.getMinutes = function(time)
  return mfloor(time / 60)
end

NS.formatTime = function(time)
  return sformat("%02d:%02d", NS.getMinutes(time), NS.getSeconds(time))
end

NS.RetrieveBody = function()
  RetrieveCorpse()
  After(0, function()
    if NS.isDead() then
      RetrieveCorpse()
    end
  end)
end
