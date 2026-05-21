local AddonName, NS = ...

local CreateFrame = CreateFrame
local tinsert = tinsert
local LibStub = LibStub

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local introFrame

local function MarkShown()
  if NS.db and NS.db.global then
    NS.db.global.introShown = true
  end
end

local function NotifyConfigChange()
  AceConfigRegistry:NotifyChange(AddonName)
end

local function AddCheckbox(parent, label, y, getter, setter)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 50, y)
  cb.Text:SetFontObject("GameFontNormal")
  cb.Text:SetText(label)
  cb.Text:ClearAllPoints()
  cb.Text:SetPoint("LEFT", cb, "RIGHT", 4, 1)
  cb:SetChecked(getter() and true or false)
  cb:SetScript("OnClick", function(self)
    setter(self:GetChecked() and true or false)
    NotifyConfigChange()
  end)
  return cb
end

local function CreateIntroFrame()
  local frame = CreateFrame("Frame", "AutoBodyResIntroFrame", UIParent, "BackdropTemplate")
  frame:SetSize(320, 240)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
  })
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:Hide()

  -- Addon name (yellow, small) — branding line above the title
  local addonLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  addonLabel:SetPoint("TOP", 0, -26)
  addonLabel:SetText(AddonName)

  -- Title (white, large)
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  title:SetPoint("TOP", 0, -48)
  title:SetText("Introducing new settings")

  -- Close X
  local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  closeBtn:SetPoint("TOPRIGHT", -5, -5)

  -- Mark "seen" on any hide path (X button, Esc via UISpecialFrames, programmatic)
  frame:HookScript("OnHide", MarkShown)

  -- Esc to close
  tinsert(UISpecialFrames, "AutoBodyResIntroFrame")

  -- Checkboxes
  AddCheckbox(frame, "Enable Auto Role Check", -75, function()
    return NS.db.global.role and NS.db.global.role.enabled
  end, function(v)
    if NS.db.global.role then
      NS.db.global.role.enabled = v
    end
  end)

  AddCheckbox(frame, "Enable Auto Ready Check", -111, function()
    return NS.db.global.readyCheck
  end, function(v)
    NS.db.global.readyCheck = v
  end)

  AddCheckbox(frame, "Enable Auto Leave Match", -147, function()
    return NS.db.global.leave
  end, function(v)
    NS.db.global.leave = v
  end)

  -- "Open Settings" button — closes the intro popup (Hide → OnHide → MarkShown)
  -- then opens the AceConfig options window.
  local openBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  openBtn:SetSize(120, 24)
  openBtn:SetPoint("BOTTOM", 0, 28)
  openBtn:SetText("Open Settings")
  openBtn:SetScript("OnClick", function()
    frame:Hide()
    AceConfigDialog:Open(AddonName)
  end)

  introFrame = frame
end

function NS.ShowIntroPopup()
  if not NS.db or not NS.db.global then
    return
  end
  if NS.db.global.introShown then
    return
  end
  if not introFrame then
    CreateIntroFrame()
  end
  introFrame:ClearAllPoints()
  introFrame:SetPoint("CENTER")
  introFrame:Show()
end
