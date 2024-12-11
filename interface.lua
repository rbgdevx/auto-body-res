local AddonName, NS = ...

local CreateFrame = CreateFrame
local LibStub = LibStub
local GetTime = GetTime

local Interface = {}
NS.Interface = Interface

local sformat = string.format

function Interface:StopMovement(frame)
  frame:SetMovable(false)
end

function Interface:MakeMoveable(frame)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(f)
    if NS.db.global.lock == false then
      f:StartMoving()
    end
  end)
  frame:SetScript("OnDragStop", function(f)
    if NS.db.global.lock == false then
      f:StopMovingOrSizing()
      local a, _, b, c, d = f:GetPoint()
      NS.db.global.position[1] = a
      NS.db.global.position[2] = b
      NS.db.global.position[3] = c
      NS.db.global.position[4] = d
    end
  end)
end

function Interface:Lock(frame)
  self:StopMovement(frame)
end

function Interface:Unlock(frame)
  self:MakeMoveable(frame)
end

function Interface:AddControls(frame)
  frame:EnableMouse(true)
  frame:SetScript("OnMouseUp", function(_, btn)
    if NS.db.global.lock == false then
      if btn == "RightButton" then
        LibStub("AceConfigDialog-3.0"):Open(AddonName)
      end
    end
  end)

  if NS.db.global.lock then
    self:StopMovement(frame)
  else
    self:MakeMoveable(frame)
  end
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

    self:AddControls(Interface.textFrame)

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
