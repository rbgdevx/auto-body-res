local AddonName, NS = ...

local CreateFrame = CreateFrame
local GetTime = GetTime
local StaticPopup_Show = StaticPopup_Show
local StaticPopup_Hide = StaticPopup_Hide
local StaticPopup_FindVisible = StaticPopup_FindVisible
local StaticPopupDialogs = StaticPopupDialogs
local GetAreaSpiritHealerTime = GetAreaSpiritHealerTime
local hooksecurefunc = hooksecurefunc

local POPUP = "AREA_SPIRIT_HEAL"
local PLACEHOLDER_SUBTEXT = " "
local SUBTEXT_OFFSET_Y = -8

-- Gap between GhostFrame ("Return to Graveyard") and the top of our popup.
local GHOSTFRAME_GAP = -10

-- Wave anchor: absolute GetTime() at which the current GY res wave will fire.
-- All timer math derives from this, so values stay accurate regardless of
-- in-range / OOR transitions or popup hide-and-show churn.
local gyEndTime = nil

-- ---------------------------------------------------------------------------
-- Inject SubText support into the AREA_SPIRIT_HEAL dialog definition.
-- ---------------------------------------------------------------------------

do
  local def = StaticPopupDialogs[POPUP]
  if def and not def._abrSubTextInjected then
    def.subText = PLACEHOLDER_SUBTEXT
    def.normalSizedSubText = true
    def._abrSubTextInjected = true
  end
end

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function toTitleCase(s)
  if not s or s == "" then return s end
  return (s:gsub("(%a)(%w*)", function(first, rest)
    return first:upper() .. rest:lower()
  end))
end

local function getMirroredText()
  local iface = NS.Interface
  if not iface or not iface.text or not iface.textFrame then
    return nil
  end
  if not iface.textFrame:IsShown() then
    return nil
  end
  local txt = iface.text:GetText()
  if not txt or txt == "" then
    return nil
  end
  return toTitleCase(txt)
end

local function anchorPopup(dialog)
  if not dialog then return end
  if not GhostFrame or not GhostFrame:IsShown() then return end
  local _, currentRel = dialog:GetPoint()
  if currentRel == GhostFrame then return end
  dialog:ClearAllPoints()
  dialog:SetPoint("TOP", GhostFrame, "BOTTOM", 0, GHOSTFRAME_GAP)
end

local function styleSubText(dialog)
  if not dialog or not dialog.SubText or not dialog.Text then return end
  dialog.SubText:SetFontObject("UserScaledFontGameHighlight")
  dialog.SubText:ClearAllPoints()
  dialog.SubText:SetPoint("TOP", dialog.Text, "BOTTOM", 0, SUBTEXT_OFFSET_Y)
end

local function refreshSubText(dialog)
  dialog = dialog or StaticPopup_FindVisible(POPUP)
  if not dialog or not dialog.SubText then return end
  styleSubText(dialog)
  local txt = getMirroredText()
  if txt then
    dialog.SubText:SetText(txt)
    if not dialog.SubText:IsShown() then
      dialog.SubText:Show()
      if dialog.Resize then dialog:Resize() end
    end
  else
    dialog.SubText:SetText(PLACEHOLDER_SUBTEXT)
  end
end

-- Called from the outer text's animation tick so the SubText updates in the
-- same frame as the outer rendering, eliminating any sampling-window drift
-- between the two.
NS.RefreshPopupSubText = refreshSubText

-- ---------------------------------------------------------------------------
-- Driver: pushes the accurate remaining wave time into dialog.timeleft so the
-- "Resurrection in N Seconds" line stays correct, and refreshes our SubText.
-- ---------------------------------------------------------------------------

local driver = CreateFrame("Frame")
local accum = 0
driver:SetScript("OnUpdate", function(_, elapsed)
  local dialog = StaticPopup_FindVisible(POPUP)

  if dialog then
    anchorPopup(dialog)

    -- Opportunistic capture: if we never got a clean IN_RANGE reading,
    -- anchor from whatever the dialog is showing the first time we see it.
    if not gyEndTime and dialog.timeleft and dialog.timeleft > 0 then
      gyEndTime = GetTime() + dialog.timeleft
    end

    if gyEndTime then
      local remaining = gyEndTime - GetTime()
      if remaining > 0 then
        dialog.timeleft = remaining
      else
        gyEndTime = nil
        dialog.timeleft = 0
        StaticPopup_Hide(POPUP)
      end
    end
  end

  accum = accum + elapsed
  if accum < 0.1 then return end
  accum = 0

  if not dialog then return end
  refreshSubText(dialog)
end)

hooksecurefunc("StaticPopup_Show", function(which)
  if which ~= POPUP then return end
  local dialog = StaticPopup_FindVisible(POPUP)
  if not dialog then return end
  styleSubText(dialog)
  if gyEndTime then
    local remaining = gyEndTime - GetTime()
    if remaining > 0 then
      dialog.timeleft = remaining
    end
  end
  refreshSubText(dialog)
  anchorPopup(dialog)
end)

-- ---------------------------------------------------------------------------
-- Events: track wave anchoring + cleanup.
-- ---------------------------------------------------------------------------

local helper = CreateFrame("Frame")
helper:RegisterEvent("AREA_SPIRIT_HEALER_IN_RANGE")
helper:RegisterEvent("PLAYER_UNGHOST")
helper:RegisterEvent("PLAYER_ALIVE")
helper:RegisterEvent("PLAYER_ENTERING_WORLD")
helper:SetScript("OnEvent", function(_, event)
  if event == "AREA_SPIRIT_HEALER_IN_RANGE" then
    local waveTime = GetAreaSpiritHealerTime()
    if waveTime and waveTime > 0 then
      gyEndTime = GetTime() + waveTime
    end

  elseif event == "PLAYER_UNGHOST" or event == "PLAYER_ALIVE"
      or event == "PLAYER_ENTERING_WORLD" then
    gyEndTime = nil
    StaticPopup_Hide(POPUP)
  end
end)
