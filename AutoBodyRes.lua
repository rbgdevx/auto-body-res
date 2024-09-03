local _, NS = ...

local Interface = NS.Interface

local GetInstanceInfo = GetInstanceInfo
local IsInInstance = IsInInstance
local GetCorpseRecoveryDelay = GetCorpseRecoveryDelay -- Time left before a player can accept a resurrection.
-- local PortGraveyard = PortGraveyard -- Returns the player to the graveyard.

local After = C_Timer.After
local Ticker = C_Timer.NewTicker

---@type AutoBodyRes
local AutoBodyRes = NS.AutoBodyRes
local AutoBodyResFrame = NS.AutoBodyRes.frame

local ResTicker

-- Death
do
  local RepopMe = RepopMe -- Releases your ghost to the graveyard when dead.
  local AcceptResurrect = AcceptResurrect -- Accepts a resurrection offer.
  local GetSelfResurrectOptions = C_DeathInfo.GetSelfResurrectOptions -- Returns self resurrect options for your character, including from soulstones.

  function AutoBodyRes:CORPSE_IN_RANGE()
    if NS.db.global.resurrect then
      NS.RetrieveBody()
      local resTime = GetCorpseRecoveryDelay()
      if resTime then
        After(resTime, function()
          ResTicker = Ticker(0.1, function()
            NS.RetrieveBody()
          end, 15)
        end)
      end
    end
  end

  function AutoBodyRes:RESURRECT_REQUEST()
    if NS.db.global.resurrect then
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
    if NS.db.global.release then
      local options = GetSelfResurrectOptions()
      if options and #options == 0 then
        RepopMe()
      end
    end
  end

  function AutoBodyRes:PLAYER_DEAD()
    self:PlayerDead()

    local resTime = GetCorpseRecoveryDelay()
    Interface:Start(Interface, resTime + 0.5)
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

  -- Protected Action, only available to the Blizzard UI
  -- PortGraveyard()

  After(5, function()
    Interface.flashAnimationGroup:Stop()
  end)
end

local DEAD_EVENTS = {
  "PLAYER_DEAD",
  "PLAYER_SKINNED",
  "CORPSE_IN_RANGE",
  "RESURRECT_REQUEST",
}

function AutoBodyRes:PlayerDeadEvents()
  FrameUtil.RegisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)

  self:PlayerDead()
end

function AutoBodyRes:PLAYER_ENTERING_WORLD()
  AutoBodyResFrame:RegisterEvent("PLAYER_UNGHOST")

  if NS.db.global.onlypvp then
    local inInstance = IsInInstance()

    if inInstance then
      After(0, function() -- Some info isn't available until 1 frame after loading is done
        local _, instanceType = GetInstanceInfo()

        if instanceType == "pvp" then
          if NS.isDead() then
            local resTime = GetCorpseRecoveryDelay()
            Interface:Start(Interface, resTime + 0.5)
          else
            Interface:Stop(Interface, Interface.timerAnimationGroup)
            Interface:Stop(Interface, Interface.flashAnimationGroup)
          end

          AutoBodyRes:PlayerDeadEvents()
        end
      end)
    else
      After(0, function() -- Some info isn't available until 1 frame after loading is done
        if NS.db.global.test then
          NS.Interface.text:SetText("Placeholder")
          NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
          NS.Interface.textFrame:Show()
        end

        if ResTicker then
          ResTicker:Cancel()
        end
      end)
    end
  else
    if NS.isDead() then
      local resTime = GetCorpseRecoveryDelay()
      Interface:Start(Interface, resTime + 0.5)
    else
      Interface:Stop(Interface, Interface.timerAnimationGroup)
      Interface:Stop(Interface, Interface.flashAnimationGroup)
    end

    self:PlayerDeadEvents()
  end
end

function AutoBodyRes:PLAYER_LOGIN()
  AutoBodyResFrame:UnregisterEvent("PLAYER_LOGIN")

  Interface:CreateInterface()

  AutoBodyResFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end
AutoBodyResFrame:RegisterEvent("PLAYER_LOGIN")
