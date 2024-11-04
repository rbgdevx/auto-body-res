local _, NS = ...

local Interface = NS.Interface

local GetInstanceInfo = GetInstanceInfo
local IsInInstance = IsInInstance
local GetCorpseRecoveryDelay = GetCorpseRecoveryDelay -- Time left before a player can accept a resurrection.
-- local PortGraveyard = PortGraveyard -- Returns the player to the graveyard.

local After = C_Timer.After
local Ticker = C_Timer.NewTicker
local IsBattleground = C_PvP.IsBattleground
local IsRatedSoloRBG = C_PvP.IsRatedSoloRBG
local IsRatedBattleground = C_PvP.IsRatedBattleground
local IsInBrawl = C_PvP.IsInBrawl

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
  "PLAYER_UNGHOST",
}

function AutoBodyRes:PlayerDeadEvents()
  FrameUtil.RegisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)

  self:PlayerDead()
end

function AutoBodyRes:PLAYER_ENTERING_WORLD()
  After(0, function() -- Some info isn't available until 1 frame after loading is done
    local inInstance, instanceType = IsInInstance()

    if inInstance then
      local isBattleground = instanceType == "pvp" or IsBattleground()

      if isBattleground then
        local name = GetInstanceInfo()

        local isBlitz = IsRatedSoloRBG()
        local isRated = IsRatedBattleground()
        local isBrawl = IsInBrawl()
        local isEpic = NS.IsEpicBattleground(name)

        local dontShowInBlitz = isBlitz and NS.db.global.disableblitz
        local dontShowInRated = isRated and isBlitz == false and NS.db.global.disablerated
        local dontShowInRandom = isBlitz == false and isRated == false and NS.db.global.disablerandom
        local dontShowInBrawl = isBrawl and NS.db.global.disablebrawl
        local dontShowInEpic = isEpic and NS.db.global.disableepic

        if dontShowInBlitz or dontShowInRated or dontShowInRandom or dontShowInBrawl or dontShowInEpic then
          Interface:Stop(Interface, Interface.timerAnimationGroup)
          Interface:Stop(Interface, Interface.flashAnimationGroup)

          if ResTicker then
            ResTicker:Cancel()
          end

          FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
          return
        end

        local mapNotInList = NS.isMapAllowed(name) == nil
        local isMapAllowed = mapNotInList and true or NS.isMapAllowed(name)

        if mapNotInList then
          NS.write(
            "This map is not being tracked, please report this to the addon author to track the following map name: "
              .. name
          )
        end

        if NS.db.global.allmaps or isMapAllowed then
          if NS.isDead() then
            local resTime = GetCorpseRecoveryDelay()
            Interface:Start(Interface, resTime + 0.5)
          else
            Interface:Stop(Interface, Interface.timerAnimationGroup)
            Interface:Stop(Interface, Interface.flashAnimationGroup)
          end

          AutoBodyRes:PlayerDeadEvents()
        end
      else
        Interface:Stop(Interface, Interface.timerAnimationGroup)
        Interface:Stop(Interface, Interface.flashAnimationGroup)

        if ResTicker then
          ResTicker:Cancel()
        end

        FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
      end
    else
      if not NS.db.global.outside then
        Interface:Stop(Interface, Interface.timerAnimationGroup)
        Interface:Stop(Interface, Interface.flashAnimationGroup)

        if ResTicker then
          ResTicker:Cancel()
        end

        FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
        return
      end

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
end

function AutoBodyRes:PLAYER_LOGIN()
  AutoBodyResFrame:UnregisterEvent("PLAYER_LOGIN")

  Interface:CreateInterface()

  AutoBodyResFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end
AutoBodyResFrame:RegisterEvent("PLAYER_LOGIN")
