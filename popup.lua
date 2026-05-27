local _, NS = ...

local CreateFrame = CreateFrame
local StaticPopup_FindVisible = StaticPopup_FindVisible
local hooksecurefunc = hooksecurefunc

local POPUP = "AREA_SPIRIT_HEAL"
local SUBTEXT_OFFSET_Y = -8

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function toTitleCase(s)
  if not s or s == "" then
    return s
  end
  return (s:gsub("(%a)(%w*)", function(first, rest)
    return first:upper() .. rest:lower()
  end))
end

local function getMirroredText()
  if not NS.db or not NS.db.global.popuptext then
    return nil
  end
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

local function refreshSubText(dialog)
  dialog = dialog or StaticPopup_FindVisible(POPUP)
  if not dialog or not dialog.SubText or not dialog.Text then
    return
  end
  local txt = getMirroredText()
  if txt then
    dialog.SubText:SetText(txt)
    dialog.SubText:SetFontObject("UserScaledFontGameHighlight")
    dialog.SubText:ClearAllPoints()
    dialog.SubText:SetPoint("TOP", dialog.Text, "BOTTOM", 0, SUBTEXT_OFFSET_Y)

    if not dialog.SubText:IsShown() then
      dialog.SubText:Show()
    end

    -- Push ButtonContainer below SubText so Layout() computes the correct
    -- dialog height.  Only do this when SubText is visible — anchoring to
    -- a hidden frame breaks ButtonContainer positioning.
    if dialog.ButtonContainer then
      dialog.ButtonContainer:ClearAllPoints()
      dialog.ButtonContainer:SetPoint("TOP", dialog.SubText, "BOTTOM", 0, -9)
    end
  else
    if dialog.SubText:IsShown() then
      dialog.SubText:Hide()
    end
    -- Restore ButtonContainer back to Text so the dialog collapses cleanly
    if dialog.ButtonContainer then
      dialog.ButtonContainer:ClearAllPoints()
      dialog.ButtonContainer:SetPoint("TOP", dialog.Text, "BOTTOM", 0, -9)
    end
  end
end

NS.RefreshPopupSubText = refreshSubText

-- ---------------------------------------------------------------------------
-- Driver: refreshes SubText in the spirit healer popup.
-- ---------------------------------------------------------------------------

local driver = CreateFrame("Frame")
local accum = 0
driver:SetScript("OnUpdate", function(_, elapsed)
  local dialog = StaticPopup_FindVisible(POPUP)
  if not dialog then
    return
  end

  accum = accum + elapsed
  if accum < 0.1 then
    return
  end
  accum = 0

  refreshSubText(dialog)
end)

hooksecurefunc("StaticPopup_Show", function(which)
  if which ~= POPUP then
    return
  end
  local dialog = StaticPopup_FindVisible(POPUP)
  if not dialog then
    return
  end
  refreshSubText(dialog)
end)
