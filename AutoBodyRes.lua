local AddonName, NS = ...

local Interface = NS.Interface

local LibStub = LibStub
local GetInstanceInfo = GetInstanceInfo
local IsInInstance = IsInInstance
local GetCorpseRecoveryDelay = GetCorpseRecoveryDelay -- Time left before a player can accept a resurrection.

local After = C_Timer.After
local Ticker = C_Timer.NewTicker

AutoBodyRes = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceEvent-3.0")

local ResTicker

-- Death
do
  local RepopMe = RepopMe -- Releases your ghost to the graveyard when dead.
  local AcceptResurrect = AcceptResurrect -- Accepts a resurrection offer.
  local GetSelfResurrectOptions = C_DeathInfo.GetSelfResurrectOptions -- Returns self resurrect options for your character, including from soulstones.

  function AutoBodyRes:CORPSE_IN_RANGE()
    if AutoBodyRes.db.global.resurrect then
      NS.RetrieveBody()
      local resTime = GetCorpseRecoveryDelay()
      if resTime then
        After(resTime + 1, function()
          ResTicker = Ticker(0.1, function()
            NS.RetrieveBody()
          end, 15)
        end)
      end
    end
  end

  function AutoBodyRes:RESURRECT_REQUEST()
    if AutoBodyRes.db.global.resurrect then
      AcceptResurrect()
      After(0, function()
        if NS.isDead() then
          AcceptResurrect()
        end
      end)

      if ResTicker then
        ResTicker:Cancel()
      end

      Interface:Stop(Interface, Interface.timerAnimationGroup)
      Interface:Stop(Interface, Interface.flashAnimationGroup)
    end
  end

  function AutoBodyRes:PlayerDead()
    if AutoBodyRes.db.global.release then
      local options = GetSelfResurrectOptions()
      if options and #options == 0 then
        RepopMe()
      end
    end
  end

  function AutoBodyRes:PLAYER_DEAD()
    self:PlayerDead()

    local resTime = GetCorpseRecoveryDelay()
    Interface:Start(Interface, resTime + 1)
  end
end

function AutoBodyRes:PLAYER_UNGHOST()
  if ResTicker then
    ResTicker:Cancel()
  end

  Interface:Stop(Interface, Interface.timerAnimationGroup)
  Interface:Stop(Interface, Interface.flashAnimationGroup)
end

function AutoBodyRes:PLAYER_SKINNED()
  Interface:Stop(Interface, Interface.timerAnimationGroup)

  if ResTicker then
    ResTicker:Cancel()
  end

  Interface.text:SetText("BODY TAKEN")
  Interface.textFrame:Show()
  Interface.flashAnimationGroup:Play()

  After(5, function()
    Interface.flashAnimationGroup:Stop()
  end)
end

function AutoBodyRes:PlayerDeadEvents()
  self:RegisterEvent("PLAYER_DEAD")
  self:RegisterEvent("PLAYER_SKINNED")
  self:RegisterEvent("CORPSE_IN_RANGE")
  self:RegisterEvent("RESURRECT_REQUEST")

  self:PlayerDead()
end

function AutoBodyRes:PLAYER_ENTERING_WORLD()
  self:RegisterEvent("PLAYER_UNGHOST")

  local inInstance = IsInInstance()

  if inInstance then
    After(0, function() -- Some info isn't available until 1 frame after loading is done
      local _, instanceType = GetInstanceInfo()

      if instanceType == "pvp" then
        if NS.isDead() then
          local resTime = GetCorpseRecoveryDelay()
          Interface:Start(Interface, resTime + 1)
        else
          Interface:Stop(Interface, Interface.timerAnimationGroup)
          Interface:Stop(Interface, Interface.flashAnimationGroup)
        end

        AutoBodyRes:PlayerDeadEvents()
      end
    end)
  else
    After(0, function() -- Some info isn't available until 1 frame after loading is done
      if AutoBodyRes.db.global.test then
        NS.Interface.text:SetText("Placeholder")
        NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
        NS.Interface.textFrame:Show()
      end

      if ResTicker then
        ResTicker:Cancel()
      end
    end)
  end
end

function AutoBodyRes:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New(AddonName .. "DB", NS.DefaultDatabase, true)
  self:SetupOptions()
end

function AutoBodyRes:OnEnable()
  Interface:CreateInterface()
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
