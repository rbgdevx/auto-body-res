local _, NS = ...

local CreateFrame = CreateFrame
local StaticPopup_FindVisible = StaticPopup_FindVisible
local StaticPopupDialogs = StaticPopupDialogs

local POPUP = "AREA_SPIRIT_HEAL"

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

-- The status text we want mirrored into the popup, or nil when the feature is
-- off / there's nothing to show. When this returns nil the addon makes ZERO
-- changes to Blizzard's dialog -- it is left in its native state.
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

-- ---------------------------------------------------------------------------
-- Mirror the addon's status text into the spirit-healer popup's SubText.
--
-- TAINT-SAFE BY CONSTRUCTION: this addon never calls a single layout/frame
-- method on the dialog. It only:
--   1. Writes a string to Blizzard's own `subText` field. Blizzard's secure
--      code reads that field at show time and does ALL of the showing, font,
--      anchoring and sizing itself (AREA_SPIRIT_HEAL is a self-laying-out
--      BaseLayoutMixin dialog, so it relayouts on its own).
--   2. Calls FontString:SetText on the already-visible SubText to keep the
--      countdown live. SetText is not a protected operation.
--
-- And it doesn't matter even if the dialog were tainted: this popup's button
-- handlers (AcceptAreaSpiritHeal / CancelAreaSpiritHeal / OpenWorldMap /
-- IsCemeterySelectionAvailable) are not protected functions, so they are never
-- blocked. We deliberately do NOT call SetupText (it would blank the deferred
-- "Resurrection in X" countdown) nor Resize/SetupElementAnchoring/MarkDirty.
-- ---------------------------------------------------------------------------

local function applySubText()
  local info = StaticPopupDialogs[POPUP]
  if not info then
    return
  end

  local desired = getMirroredText() -- string | nil

  -- Sync the definition so the next fresh show lays the subtext out natively,
  -- entirely inside Blizzard's own (untainted) code path.
  info.subText = desired

  -- Live-update the text of an already-open popup (the countdown ticks every
  -- second). Only touch it when Blizzard already laid out a visible SubText --
  -- i.e. subText was set when the popup was shown. We never show/hide or resize
  -- it ourselves; presence and sizing are Blizzard's job, handled at show.
  local dialog = StaticPopup_FindVisible(POPUP)
  if dialog and dialog.SubText and dialog.SubText:IsShown() then
    dialog.SubText:SetText(desired or "")
  end
end

NS.RefreshPopupSubText = applySubText

-- ---------------------------------------------------------------------------
-- Driver: keep info.subText synced + the open popup's text live. The addon's
-- interface timer also calls RefreshPopupSubText every frame while it animates,
-- but that animation stops on "BODY TAKEN" / unghost, so this independent
-- sampler covers the popup for as long as it is actually on screen.
-- ---------------------------------------------------------------------------

local driver = CreateFrame("Frame")
local accum = 0
driver:SetScript("OnUpdate", function(_, elapsed)
  accum = accum + elapsed
  if accum < 0.1 then
    return
  end
  accum = 0
  -- Runs every 0.1s: keeps info.subText synced (so a fresh show is correct
  -- within 0.1s) and keeps an open popup's countdown text live.
  applySubText()
end)
