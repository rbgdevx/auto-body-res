local AddonName, NS = ...

local Interface = NS.Interface

local LibStub = LibStub
local next = next
local GetInstanceInfo = GetInstanceInfo
local IsInInstance = IsInInstance
local GetCorpseRecoveryDelay = GetCorpseRecoveryDelay -- Time left before a player can accept a resurrection.
-- local PortGraveyard = PortGraveyard -- Returns the player to the graveyard.

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local After = C_Timer.After
local Ticker = C_Timer.NewTicker
local IsBattleground = C_PvP.IsBattleground
-- local IsRatedSoloRBG = C_PvP.IsRatedSoloRBG
-- local IsRatedBattleground = C_PvP.IsRatedBattleground
-- local IsInBrawl = C_PvP.IsInBrawl
-- local GetActiveBrawlInfo = C_PvP.GetActiveBrawlInfo
local GetAvailableBrawlInfo = C_PvP.GetAvailableBrawlInfo

local CompleteLFGRoleCheck = CompleteLFGRoleCheck
local GetLFGRoleUpdate = GetLFGRoleUpdate
local GetPVPRoles = GetPVPRoles
local ConfirmReadyCheck = ConfirmReadyCheck
local LeaveBattlefield = LeaveBattlefield
local GetBattlefieldWinner = GetBattlefieldWinner

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
      local delay = NS.db.global.resurrectDelay or 0
      After(delay, function()
        NS.RetrieveBody()
        local resTime = GetCorpseRecoveryDelay()
        if resTime then
          After(resTime, function()
            ResTicker = Ticker(0.1, function()
              NS.RetrieveBody()
            end, 15)
          end)
        end
      end)
    end
  end

  function AutoBodyRes:RESURRECT_REQUEST()
    if NS.db.global.resurrect then
      local delay = NS.db.global.resurrectDelay or 0
      After(delay, function()
        AcceptResurrect()
        After(0, function()
          if NS.isDead() then
            AcceptResurrect()
          end
        end)
      end)

      if ResTicker then
        ResTicker:Cancel()
      end

      Interface:Stop(Interface, Interface.timerAnimationGroup)
      Interface:Stop(Interface, Interface.flashAnimationGroup)

      local isInInstance = IsInInstance()
      if isInInstance == false then
        if NS.testMode then
          NS.Interface.text:SetText(NS.PLACEHOLDER_TEXT)
          NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
          NS.Interface.textFrame:Show()
        end
      end
    end
  end

  function AutoBodyRes:PlayerDead()
    if NS.db.global.release then
      local delay = NS.db.global.releaseDelay or 0
      After(delay, function()
        local options = GetSelfResurrectOptions()
        if options and #options == 0 then
          RepopMe()
        end
      end)
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

  local isInInstance = IsInInstance()
  if isInInstance == false then
    if NS.testMode then
      NS.Interface.text:SetText(NS.PLACEHOLDER_TEXT)
      NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
      NS.Interface.textFrame:Show()
    end
  end
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

function AutoBodyRes:PVP_BRAWL_INFO_UPDATED()
  local availableBrawlInfo = GetAvailableBrawlInfo()
  if availableBrawlInfo ~= nil then
    AutoBodyResFrame:UnregisterEvent("PVP_BRAWL_INFO_UPDATED")
    -- print(availableBrawlInfo.name, availableBrawlInfo.brawlID, availableBrawlInfo.brawlType)
  end
end

function AutoBodyRes:LFG_ROLE_CHECK_SHOW()
  local _, _, _, _, _, isBGRoleCheck = GetLFGRoleUpdate()
  if not isBGRoleCheck then
    return
  end

  local roleDb = NS.db.global.role

  if not roleDb.enabled then
    return
  end

  if roleDb.all then
    CompleteLFGRoleCheck(true)
    NS.write("Role check accepted.")
    return
  end

  local tank, healer, dps = GetPVPRoles()
  local roleName, allowed
  if tank then
    roleName, allowed = "Tank", roleDb.tank
  elseif healer then
    roleName, allowed = "Healer", roleDb.healer
  elseif dps then
    roleName, allowed = "DPS", roleDb.dps
  end

  if not roleName then
    return
  end

  if allowed then
    CompleteLFGRoleCheck(true)
    NS.write("Role check accepted (" .. roleName .. ").")
  else
    NS.write("Manual role check needed (" .. roleName .. ").")
  end
end

function AutoBodyRes:READY_CHECK()
  if not NS.db.global.readyCheck then
    return
  end
  ConfirmReadyCheck(true)
  NS.write("Ready check accepted.")
end

function AutoBodyRes:PVP_MATCH_COMPLETE()
  if not NS.db.global.leave then
    return
  end

  local delay = NS.db.global.leaveDelay or 2
  NS.write("Leaving match in " .. delay .. "s...")

  After(delay, function()
    if not NS.db.global.leave then
      return
    end
    if not GetBattlefieldWinner() then
      return
    end
    LeaveBattlefield()
  end)
end

function AutoBodyRes:PLAYER_ENTERING_WORLD()
  After(0, function() -- Some info isn't available until 1 frame after loading is done
    local isInInstance, instanceType = IsInInstance()

    local availableBrawlInfo = GetAvailableBrawlInfo()
    if availableBrawlInfo ~= nil then
      AutoBodyResFrame:UnregisterEvent("PVP_BRAWL_INFO_UPDATED")
      -- print(availableBrawlInfo.name, availableBrawlInfo.brawlID, availableBrawlInfo.brawlType)
    end

    if isInInstance then
      local isBattleground = instanceType == "pvp" or IsBattleground()

      if isBattleground then
        -- local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()

        -- local isBlitz = IsRatedSoloRBG()
        -- local isRated = IsRatedBattleground()
        -- local isBrawl = IsInBrawl()
        -- local isEpic = NS.IsEpicBattleground(instanceID)

        -- local dontShowInBlitz = isBlitz and NS.db.global.disableblitz
        -- local dontShowInRated = isRated and isBlitz == false and NS.db.global.disablerated
        -- local dontShowInRandom = isBlitz == false and isRated == false and NS.db.global.disablerandom
        -- local dontShowInBrawl = isBrawl and NS.db.global.disablebrawl
        -- local dontShowInEpic = isEpic and NS.db.global.disableepic
        -- local dontShow = dontShowInBlitz or dontShowInRated or dontShowInRandom or dontShowInBrawl or dontShowInEpic

        -- if dontShow then
        --   Interface:Stop(Interface, Interface.timerAnimationGroup)
        --   Interface:Stop(Interface, Interface.flashAnimationGroup)

        --   if ResTicker then
        --     ResTicker:Cancel()
        --   end

        --   FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
        --   return
        -- end

        -- local activeBrawlInfo = GetActiveBrawlInfo()
        -- local isMapAllowed = false
        -- if isBrawl then
        --   if activeBrawlInfo then
        --     if activeBrawlInfo.brawlType == 1 then
        --       isMapAllowed = NS.isBrawlAllowed(activeBrawlInfo.brawlID)
        --     else
        --       isMapAllowed = false
        --     end
        --   else
        --     isMapAllowed = false
        --   end
        -- elseif isEpic then
        --   isMapAllowed = NS.isEpicBattlegroundAllowed(instanceID)
        -- else
        --   isMapAllowed = NS.isBattlegroundAllowed(instanceID)
        -- end

        -- print("isBrawl", isBrawl, "instanceID", instanceID)
        -- if activeBrawlInfo then
        --   print("activeBrawlInfo", activeBrawlInfo.brawlID, activeBrawlInfo.brawlType)
        -- end

        if NS.isDead() then
          local resTime = GetCorpseRecoveryDelay()
          Interface:Start(Interface, resTime + 0.5)
        else
          Interface:Stop(Interface, Interface.timerAnimationGroup)
          Interface:Stop(Interface, Interface.flashAnimationGroup)
        end

        AutoBodyRes:PlayerDeadEvents()
      else
        Interface:Stop(Interface, Interface.timerAnimationGroup)
        Interface:Stop(Interface, Interface.flashAnimationGroup)

        if ResTicker then
          ResTicker:Cancel()
        end

        FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
      end
    else
      Interface:Stop(Interface, Interface.timerAnimationGroup)
      Interface:Stop(Interface, Interface.flashAnimationGroup)

      if ResTicker then
        ResTicker:Cancel()
      end

      if NS.testMode then
        NS.Interface.text:SetText(NS.PLACEHOLDER_TEXT)
        NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
        NS.Interface.textFrame:Show()
      end

      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
    end
  end)
end

function AutoBodyRes:PLAYER_LOGIN()
  AutoBodyResFrame:UnregisterEvent("PLAYER_LOGIN")

  Interface:CreateInterface()

  AutoBodyResFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  AutoBodyResFrame:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
  AutoBodyResFrame:RegisterEvent("LFG_ROLE_CHECK_SHOW")
  AutoBodyResFrame:RegisterEvent("READY_CHECK")
  AutoBodyResFrame:RegisterEvent("PVP_MATCH_COMPLETE")

  AutoBodyResFrame:UnregisterEvent("ADDON_LOADED")

  After(1, function()
    if NS.ShowIntroPopup then
      NS.ShowIntroPopup()
    end
  end)
end
AutoBodyResFrame:RegisterEvent("PLAYER_LOGIN")

function NS.OnDbChanged()
  AutoBodyResFrame.dbChanged = true

  local isInInstance, instanceType = IsInInstance()

  if isInInstance then
    local isBattleground = instanceType == "pvp" or IsBattleground()

    if isBattleground then
      local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()

      -- local isBlitz = IsRatedSoloRBG()
      -- local isRated = IsRatedBattleground()
      -- local isBrawl = IsInBrawl()
      -- local isEpic = NS.IsEpicBattleground(instanceID)

      -- local dontShowInBlitz = isBlitz and NS.db.global.disableblitz
      -- local dontShowInRated = isRated and isBlitz == false and NS.db.global.disablerated
      -- local dontShowInRandom = isBlitz == false and isRated == false and NS.db.global.disablerandom
      -- local dontShowInBrawl = isBrawl and NS.db.global.disablebrawl
      -- local dontShowInEpic = isEpic and NS.db.global.disableepic

      -- if dontShowInBlitz or dontShowInRated or dontShowInRandom or dontShowInBrawl or dontShowInEpic then
      --   Interface:Stop(Interface, Interface.timerAnimationGroup)
      --   Interface:Stop(Interface, Interface.flashAnimationGroup)

      --   if ResTicker then
      --     ResTicker:Cancel()
      --   end

      --   FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
      --   return
      -- end

      -- local isMapAllowed = false
      -- if isBrawl then
      --   local activeBrawlInfo = GetActiveBrawlInfo()
      --   if activeBrawlInfo then
      --     if activeBrawlInfo.brawlType == 1 then
      --       isMapAllowed = NS.isBrawlAllowed(activeBrawlInfo.brawlID)
      --     else
      --       isMapAllowed = false
      --     end
      --   else
      --     isMapAllowed = false
      --   end
      -- elseif isEpic then
      --   isMapAllowed = NS.isEpicBattlegroundAllowed(instanceID)
      -- else
      --   isMapAllowed = NS.isBattlegroundAllowed(instanceID)
      -- end

      if NS.isDead() then
        local resTime = GetCorpseRecoveryDelay()
        Interface:Start(Interface, resTime + 0.5)
      else
        Interface:Stop(Interface, Interface.timerAnimationGroup)
        Interface:Stop(Interface, Interface.flashAnimationGroup)
      end

      AutoBodyRes:PlayerDeadEvents()
    else
      Interface:Stop(Interface, Interface.timerAnimationGroup)
      Interface:Stop(Interface, Interface.flashAnimationGroup)

      if ResTicker then
        ResTicker:Cancel()
      end

      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
    end
  else
    Interface:Stop(Interface, Interface.timerAnimationGroup)
    Interface:Stop(Interface, Interface.flashAnimationGroup)

    if ResTicker then
      ResTicker:Cancel()
    end

    if NS.testMode then
      NS.Interface.text:SetText(NS.PLACEHOLDER_TEXT)
      NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
      NS.Interface.textFrame:Show()
    else
      NS.Interface.textFrame:Hide()
      NS.Interface.text:SetText("")
    end

    FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
  end

  NS.UpdateColor(NS.Interface.text)
  NS.UpdateFont(NS.Interface.text)
  NS.UpdateShadow(NS.Interface.text)
  NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)

  if NS.db.global.text then
    NS.Interface.textFrame:SetAlpha(1)
  else
    NS.Interface.textFrame:SetAlpha(0)
  end

  AutoBodyResFrame.dbChanged = false
end

function NS.Options_SlashCommands(message)
  if message == "test" then
    if NS.testMode then
      NS.DisableTestMode()
    else
      NS.EnableTestMode()
    end
    AceConfigRegistry:NotifyChange(AddonName)
  else
    AceConfigDialog:Open(AddonName)
  end
end

function NS.Options_Setup()
  AceConfig:RegisterOptionsTable(AddonName, NS.AceConfig)
  AceConfigDialog:AddToBlizOptions(AddonName, AddonName)

  SLASH_ABR1 = AddonName
  SLASH_ABR2 = "/abr"

  function SlashCmdList.ABR(message)
    NS.Options_SlashCommands(message)
  end
end

function AutoBodyRes:ADDON_LOADED(addon)
  if addon == AddonName then
    AutoBodyResDB = AutoBodyResDB and next(AutoBodyResDB) ~= nil and AutoBodyResDB or {}

    -- Copy any settings from default if they don't exist in current profile
    NS.CopyDefaults(NS.DefaultDatabase, AutoBodyResDB)

    -- Reference to active db profile
    -- Always use this directly or reference will be invalid
    NS.db = AutoBodyResDB

    -- Remove table values no longer found in default settings
    NS.CleanupDB(AutoBodyResDB, NS.DefaultDatabase)

    NS.Options_Setup()
  end
end
AutoBodyResFrame:RegisterEvent("ADDON_LOADED")
