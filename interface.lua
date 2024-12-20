local AddonName, NS = ...

local CreateFrame = CreateFrame
local LibStub = LibStub
local GetTime = GetTime

local sformat = string.format

local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local Interface = {}
NS.Interface = Interface

function Interface:MakeUnmovable(frame)
  frame:SetMovable(false)
  frame:RegisterForDrag()
  frame:SetScript("OnDragStart", nil)
  frame:SetScript("OnDragStop", nil)
end

function Interface:MakeMoveable(frame)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(f)
    if NS.db.global.lock == false and frame:IsVisible() and frame:GetAlpha() ~= 0 then
      f:StartMoving()
    end
  end)
  frame:SetScript("OnDragStop", function(f)
    if NS.db.global.lock == false and frame:IsVisible() and frame:GetAlpha() ~= 0 then
      f:StopMovingOrSizing()
      local a, _, b, c, d = f:GetPoint()
      NS.db.global.position[1] = a
      NS.db.global.position[2] = b
      NS.db.global.position[3] = c
      NS.db.global.position[4] = d
    end
  end)
end

function Interface:RemoveControls(frame)
  frame:EnableMouse(false)
  frame:SetScript("OnMouseUp", nil)
end

function Interface:AddControls(frame)
  frame:EnableMouse(true)
  frame:SetScript("OnMouseUp", function(_, btn)
    if NS.db.global.lock == false and not IsInInstance() and frame:IsVisible() and frame:GetAlpha() ~= 0 then
      if btn == "RightButton" then
        AceConfigDialog:Open(AddonName)
      end
    end
  end)
end

function Interface:Lock(frame)
  self:RemoveControls(frame)
  self:MakeUnmovable(frame)
end

function Interface:Unlock(frame)
  self:AddControls(frame)
  self:MakeMoveable(frame)
end

local function stopAnimation(frame, animationGroup)
  animationGroup:Stop()
  frame.textFrame:Hide()
  frame.textFrame:SetParent(UIParent)
end

function Interface:Stop(bar, animationGroup)
  stopAnimation(bar, animationGroup)
end

local function animationUpdate(frame, animationGroup)
  local t = GetTime()
  if t >= frame.exp then
    animationGroup:Stop()
    local str = sformat("%s", "CAN BODY RES NOW")
    frame.text:SetText(str)
    NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
  else
    local time = frame.exp - t
    frame.remaining = time
    local str = sformat("%s %s", "CAN BODY RES IN", NS.formatTime(time))
    frame.text:SetText(str)
    NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
  end
end

function Interface:CreateFlashAnimation(frame)
  local flashAnimationGroup = frame:CreateAnimationGroup()
  flashAnimationGroup:SetLooping("REPEAT")

  local FadeOutAnimation = flashAnimationGroup:CreateAnimation("Alpha")
  FadeOutAnimation:SetOrder(1)
  FadeOutAnimation:SetFromAlpha(1)
  FadeOutAnimation:SetDuration(0.4)
  FadeOutAnimation:SetToAlpha(0)

  local FadeInAnimation = flashAnimationGroup:CreateAnimation("Alpha")
  FadeInAnimation:SetOrder(2)
  FadeInAnimation:SetFromAlpha(0)
  FadeInAnimation:SetDuration(0.4)
  FadeInAnimation:SetToAlpha(1)

  return flashAnimationGroup
end

function Interface:CreateTimerAnimation(frame)
  local timerAnimationGroup = frame:CreateAnimationGroup()
  timerAnimationGroup:SetLooping("REPEAT")

  local TimerAnimation = timerAnimationGroup:CreateAnimation()
  TimerAnimation:SetDuration(0.05)

  return timerAnimationGroup
end

function Interface:CreateInterface()
  if not Interface.textFrame then
    local TextFrame = CreateFrame("Frame", AddonName .. "InterfaceTextFrame", UIParent)
    TextFrame:SetClampedToScreen(true)
    TextFrame:SetPoint(
      NS.db.global.position[1],
      UIParent,
      NS.db.global.position[2],
      NS.db.global.position[3],
      NS.db.global.position[4]
    )

    local Text = TextFrame:CreateFontString(nil, "OVERLAY")
    Text:SetShadowOffset(0, 0)
    Text:SetShadowColor(0, 0, 0, 1)
    Text:SetJustifyH("CENTER")
    Text:SetJustifyV("MIDDLE")
    Text:SetPoint("CENTER", TextFrame, "CENTER", 0, 0)

    NS.UpdateColor(Text)
    NS.UpdateFont(Text)
    NS.UpdateSize(TextFrame, Text)

    Interface.text = Text
    Interface.textFrame = TextFrame

    if NS.db.global.lock then
      self:Lock(Interface.textFrame)
    else
      self:Unlock(Interface.textFrame)
    end

    Interface.timerAnimationGroup = self:CreateTimerAnimation(Interface.textFrame)
    Interface.flashAnimationGroup = self:CreateFlashAnimation(Interface.textFrame)
  end
end

function Interface:Start(frame, duration)
  self:Stop(frame, frame.timerAnimationGroup)

  frame.remaining = duration
  local time = frame.remaining
  frame.start = GetTime()
  frame.exp = frame.start + time

  frame.textFrame:Show()

  if NS.db.global.text then
    frame.textFrame:SetAlpha(1)
  else
    frame.textFrame:SetAlpha(0)
  end

  if duration == 0 then
    local str = sformat("%s", "CAN BODY RES NOW")
    frame.text:SetText(str)
    NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
  else
    local str = sformat("%s %s", "CAN BODY RES IN", NS.formatTime(time))
    frame.text:SetText(str)
    NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
    frame.timerAnimationGroup:SetScript("OnLoop", function(updatedGroup)
      animationUpdate(frame, updatedGroup)
    end)
    frame.timerAnimationGroup:Play()
  end
end
