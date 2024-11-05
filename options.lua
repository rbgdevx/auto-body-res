local AddonName, NS = ...

local LibStub = LibStub
local CopyTable = CopyTable
local next = next
local IsInInstance = IsInInstance
local GetInstanceInfo = GetInstanceInfo

local IsBattleground = C_PvP.IsBattleground
local IsRatedSoloRBG = C_PvP.IsRatedSoloRBG
local IsRatedBattleground = C_PvP.IsRatedBattleground
local IsInBrawl = C_PvP.IsInBrawl

---@type AutoBodyRes
local AutoBodyRes = NS.AutoBodyRes
local AutoBodyResFrame = NS.AutoBodyRes.frame

local Options = {}
NS.Options = Options

local DEAD_EVENTS = {
  "PLAYER_DEAD",
  "PLAYER_SKINNED",
  "CORPSE_IN_RANGE",
  "RESURRECT_REQUEST",
  "PLAYER_UNGHOST",
}

NS.AceConfig = {
  name = AddonName,
  type = "group",
  childGroups = "tab",
  args = {
    general = {
      name = "General",
      type = "group",
      args = {
        lock = {
          name = "Lock the text into place",
          type = "toggle",
          width = "double",
          order = 1,
          set = function(_, val)
            NS.db.global.lock = val
            if val then
              NS.Interface:Lock(NS.Interface.textFrame)
            else
              NS.Interface:Unlock(NS.Interface.textFrame)
            end
          end,
          get = function(_)
            return NS.db.global.lock
          end,
        },
        test = {
          name = "Turn on placeholder text to test settings",
          desc = "Only works outside of an instance.",
          type = "toggle",
          width = "double",
          order = 2,
          set = function(_, val)
            NS.db.global.test = val

            local isInInstance = IsInInstance()
            if isInInstance == false then
              if val then
                if NS.db.global.outside then
                  if not NS.isDead() then
                    NS.Interface.text:SetText(NS.PLACEHOLDER_TEXT)
                    NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
                    NS.Interface.textFrame:Show()
                  end
                else
                  NS.Interface.text:SetText(NS.PLACEHOLDER_TEXT)
                  NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
                  NS.Interface.textFrame:Show()
                end
              else
                if NS.db.global.outside then
                  if not NS.isDead() then
                    NS.Interface.textFrame:Hide()
                    NS.Interface.text:SetText("")
                  end
                else
                  NS.Interface.textFrame:Hide()
                  NS.Interface.text:SetText("")
                end
              end
            end
          end,
          get = function(_)
            return NS.db.global.test
          end,
        },
        release = {
          name = "Enable auto-release",
          desc = "Auto releases your body upon death.",
          type = "toggle",
          width = "double",
          order = 3,
          set = function(_, val)
            NS.db.global.release = val
          end,
          get = function(_)
            return NS.db.global.release
          end,
        },
        resurrect = {
          name = "Enable auto-resurrect",
          desc = "Auto accepts resurrection from a friend, spell, or your from being in-range of your body.",
          type = "toggle",
          width = "double",
          order = 4,
          set = function(_, val)
            NS.db.global.resurrect = val
          end,
          get = function(_)
            return NS.db.global.resurrect
          end,
        },
        text = {
          name = "Enable body res timer text",
          desc = "Toggles on/off the text that displays the time remaining to resurrect your body.",
          type = "toggle",
          width = "double",
          order = 5,
          set = function(_, val)
            NS.db.global.text = val

            if val then
              NS.Interface.textFrame:SetAlpha(1)
            else
              NS.Interface.textFrame:SetAlpha(0)
            end
          end,
          get = function(_)
            return NS.db.global.text
          end,
        },
        outside = {
          name = "Enable outside of battlegrounds",
          desc = "Toggling this feature on will make it only work outside of battlegrounds.",
          type = "toggle",
          width = "double",
          order = 6,
          set = function(_, val)
            NS.db.global.outside = val

            local isInInstance = IsInInstance()
            if isInInstance == false then
              if val then
                NS.Interface.textFrame:Show()
                FrameUtil.RegisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
              else
                if not NS.db.global.test then
                  NS.Interface.textFrame:Hide()
                end
                FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
              end
            end
          end,
          get = function(_)
            return NS.db.global.outside
          end,
        },
        disablegroup = {
          name = "Choose what content this should not load in",
          type = "group",
          inline = true,
          order = 7,
          args = {
            disableblitz = {
              name = "Disable in 8v8 Rated Blitz",
              desc = "Toggling this feature on will disable in rated blitz.",
              type = "toggle",
              width = "double",
              order = 1,
              set = function(_, val)
                NS.db.global.disableblitz = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local isBlitz = IsRatedSoloRBG()
                    local dontShowInBlitz = isBlitz and val
                    if dontShowInBlitz then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.disableblitz
              end,
            },
            disablerated = {
              name = "Disable in 10v10 Rated Battlegrounds",
              desc = "Toggling this feature on will disable in non-blitz rated bgs.",
              type = "toggle",
              width = "double",
              order = 2,
              set = function(_, val)
                NS.db.global.disablerated = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local isBlitz = IsRatedSoloRBG()
                    local isRated = IsRatedBattleground()
                    local dontShowInRated = isRated and isBlitz == false and val
                    if dontShowInRated then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.disablerated
              end,
            },
            disablerandom = {
              name = "Disable in Random Battlegrounds",
              desc = "Toggling this feature on will disable in random bgs.",
              type = "toggle",
              width = "double",
              order = 3,
              set = function(_, val)
                NS.db.global.disablerandom = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local isBlitz = IsRatedSoloRBG()
                    local isRated = IsRatedBattleground()
                    local dontShowInRandom = isBlitz == false and isRated == false and val
                    if dontShowInRandom then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.disablerandom
              end,
            },
            disableepic = {
              name = "Disable in Epic Battlegrounds",
              desc = "Toggling this feature on will disable in epic bgs.",
              type = "toggle",
              width = "double",
              order = 4,
              set = function(_, val)
                NS.db.global.disableepic = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isEpic = NS.isEpicBattleground(name)
                    local dontShowInEpic = isEpic and val
                    if dontShowInEpic then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.disableepic
              end,
            },
            disablebrawl = {
              name = "Disable in Brawls",
              desc = "Toggling this feature on will disable in pvp brawls.",
              type = "toggle",
              width = "double",
              order = 5,
              set = function(_, val)
                NS.db.global.disablebrawl = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local isBrawl = IsInBrawl()
                    local dontShowInBrawl = isBrawl and val
                    if dontShowInBrawl then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.disablebrawl
              end,
            },
          },
        },
        fontsize = {
          type = "range",
          name = "Font Size",
          width = "double",
          order = 8,
          min = 1,
          max = 500,
          step = 1,
          set = function(_, val)
            NS.db.global.fontsize = val
            NS.UpdateFont(NS.Interface.text)
            NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
          end,
          get = function(_)
            return NS.db.global.fontsize
          end,
        },
        font = {
          type = "select",
          name = "Font",
          width = "double",
          order = 9,
          dialogControl = "LSM30_Font",
          values = AceGUIWidgetLSMlists.font,
          set = function(_, val)
            NS.db.global.font = val
            NS.UpdateFont(NS.Interface.text)
            NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
          end,
          get = function(_)
            return NS.db.global.font
          end,
        },
        color = {
          type = "color",
          name = "Color",
          width = "full",
          order = 10,
          hasAlpha = true,
          set = function(_, val1, val2, val3, val4)
            NS.db.global.color.r = val1
            NS.db.global.color.g = val2
            NS.db.global.color.b = val3
            NS.db.global.color.a = val4
            NS.Interface.text:SetTextColor(val1, val2, val3, val4)
          end,
          get = function(_)
            return NS.db.global.color.r, NS.db.global.color.g, NS.db.global.color.b, NS.db.global.color.a
          end,
        },
        reset = {
          name = "Reset Everything",
          type = "execute",
          width = "normal",
          order = 100,
          func = function()
            AutoBodyResDB = CopyTable(NS.DefaultDatabase)
            NS.db = CopyTable(NS.DefaultDatabase)
            NS.UpdateFont(NS.Interface.text)
            NS.UpdateSize(NS.Interface.textFrame, NS.Interface.text)
          end,
        },
      },
    },
    maps = {
      name = "Maps",
      desc = "Enable/Disable for specific maps.",
      type = "group",
      args = {
        description = {
          name = "These settings only matter if you have the matching game mode enabled in the general settings.",
          type = "description",
          fontSize = "medium",
          width = "double",
          order = 1,
        },
        spacing1 = { type = "description", order = 2, name = " " },
        allmaps = {
          name = "Enable for all maps",
          desc = "Toggling this feature on will enable in all battleground maps.",
          type = "toggle",
          width = "double",
          order = 3,
          set = function(_, val)
            NS.db.global.allmaps = val
          end,
          get = function(_)
            return NS.db.global.allmaps
          end,
        },
        normalgroup = {
          name = "Battlegrounds",
          type = "group",
          inline = true,
          order = 4,
          disabled = function(info)
            return info[3]
              and (
                (NS.db.global.disableblitz and NS.db.global.disablerated and NS.db.global.disablerandom)
                or NS.db.global.allmaps
              )
          end,
          args = {
            arathibasin = {
              name = "Arathi Basin",
              desc = "Turn on for Arathi Basin.",
              type = "toggle",
              width = "full",
              order = 1,
              set = function(_, val)
                NS.db.global.arathibasin = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Arathi Basin" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.arathibasin
              end,
            },
            deephaulravine = {
              name = "Deephaul Ravine",
              desc = "Turn on for Deephaul Ravine.",
              type = "toggle",
              width = "full",
              order = 2,
              set = function(_, val)
                NS.db.global.deephaulravine = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Deephaul Ravine" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.deephaulravine
              end,
            },
            deepwindgorge = {
              name = "Deepwind Gorge",
              desc = "Turn on for Deepwind Gorge.",
              type = "toggle",
              width = "full",
              order = 3,
              set = function(_, val)
                NS.db.global.deepwindgorge = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Deepwind Gorge" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.deepwindgorge
              end,
            },
            eyeofthestorm = {
              name = "Eye of the Storm",
              desc = "Turn on for Eye of the Storm.",
              type = "toggle",
              width = "full",
              order = 4,
              set = function(_, val)
                NS.db.global.eyeofthestorm = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Eye of the Storm" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.eyeofthestorm
              end,
            },
            seethingshore = {
              name = "Seething Shore",
              desc = "Turn on for Seething Shore.",
              type = "toggle",
              width = "full",
              order = 5,
              set = function(_, val)
                NS.db.global.seethingshore = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Seething Shore" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.seethingshore
              end,
            },
            silvershardmines = {
              name = "Silvershard Mines",
              desc = "Turn on for Silvershard Mines.",
              type = "toggle",
              width = "full",
              order = 6,
              set = function(_, val)
                NS.db.global.silvershardmines = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Silvershard Mines" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.silvershardmines
              end,
            },
            thebattleforgilneas = {
              name = "The Battle for Gilneas",
              desc = "Turn on for The Battle for Gilneas.",
              type = "toggle",
              width = "full",
              order = 7,
              set = function(_, val)
                NS.db.global.thebattleforgilneas = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "The Battle for Gilneas" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.thebattleforgilneas
              end,
            },
            templeofkotmogu = {
              name = "Temple of Kotmogu",
              desc = "Turn on for Temple of Kotmogu.",
              type = "toggle",
              width = "full",
              order = 8,
              set = function(_, val)
                NS.db.global.templeofkotmogu = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Temple of Kotmogu" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.templeofkotmogu
              end,
            },
            twinpeaks = {
              name = "Twin Peaks",
              desc = "Turn on for Twin Peaks.",
              type = "toggle",
              width = "full",
              order = 9,
              set = function(_, val)
                NS.db.global.twinpeaks = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Twin Peaks" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.twinpeaks
              end,
            },
            warsonggulch = {
              name = "Warsong Gulch",
              desc = "Turn on for Warsong Gulch.",
              type = "toggle",
              width = "full",
              order = 10,
              set = function(_, val)
                NS.db.global.warsonggulch = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Warsong Gulch" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.warsonggulch
              end,
            },
          },
        },
        epicgroup = {
          name = "Epic Battlegrounds",
          type = "group",
          inline = true,
          order = 5,
          disabled = function(info)
            return info[3] and (NS.db.global.disableepic or NS.db.global.allmaps)
          end,
          args = {
            alteracvalley = {
              name = "Alterac Valley",
              desc = "Turn on for Alterac Valley.",
              type = "toggle",
              width = "full",
              order = 1,
              set = function(_, val)
                NS.db.global.alteracvalley = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Alterac Valley" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.alteracvalley
              end,
            },
            ashran = {
              name = "Ashran",
              desc = "Turn on for Ashran.",
              type = "toggle",
              width = "full",
              order = 2,
              set = function(_, val)
                NS.db.global.ashran = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Ashran" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.ashran
              end,
            },
            battleforwintergrasp = {
              name = "Battle for Wintergrasp",
              desc = "Turn on for Battle for Wintergrasp.",
              type = "toggle",
              width = "full",
              order = 3,
              set = function(_, val)
                NS.db.global.battleforwintergrasp = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Battle for Wintergrasp" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.battleforwintergrasp
              end,
            },
            isleofconquest = {
              name = "Isle of Conquest",
              desc = "Turn on for Isle of Conquest.",
              type = "toggle",
              width = "full",
              order = 4,
              set = function(_, val)
                NS.db.global.isleofconquest = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Isle of Conquest" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.isleofconquest
              end,
            },
          },
        },
        brawlgroup = {
          name = "Brawl Battlegrounds",
          type = "group",
          inline = true,
          order = 6,
          disabled = function(info)
            return info[3] and (NS.db.global.disablebrawl or NS.db.global.allmaps)
          end,
          args = {
            arathiblizzard = {
              name = "Arathi Blizzard",
              desc = "Turn on for Arathi Blizzard.",
              type = "toggle",
              width = "full",
              order = 1,
              set = function(_, val)
                NS.db.global.korraksrevenge = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Arathi Basin Winter" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.korraksrevenge
              end,
            },
            korraksrevenge = {
              name = "Korrak's Revenge",
              desc = "Turn on for Korrak's Revenge.",
              type = "toggle",
              width = "full",
              order = 2,
              set = function(_, val)
                NS.db.global.korraksrevenge = val

                local isInInstance, instanceType = IsInInstance()
                if isInInstance then
                  local isBattleground = instanceType == "pvp" or IsBattleground()
                  if isBattleground then
                    local name = GetInstanceInfo()
                    local isMapAllowed = name == "Korrak's Revenge" and val
                    if not isMapAllowed then
                      NS.Interface.textFrame:Hide()
                      FrameUtil.UnregisterFrameForEvents(AutoBodyResFrame, DEAD_EVENTS)
                    end
                  end
                end
              end,
              get = function(_)
                return NS.db.global.korraksrevenge
              end,
            },
          },
        },
      },
    },
  },
}

function Options:SlashCommands(message)
  if message == "toggle lock" then
    if NS.db.global.lock == false then
      NS.db.global.lock = true
    else
      NS.db.global.lock = false
    end
  else
    LibStub("AceConfigDialog-3.0"):Open(AddonName)
  end
end

function Options:Setup()
  LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, NS.AceConfig)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonName, AddonName)

  SLASH_ABR1 = AddonName
  SLASH_ABR2 = "/abr"

  function SlashCmdList.ABR(message)
    self:SlashCommands(message)
  end
end

function AutoBodyRes:ADDON_LOADED(addon)
  if addon == AddonName then
    AutoBodyResFrame:UnregisterEvent("ADDON_LOADED")

    AutoBodyResDB = AutoBodyResDB and next(AutoBodyResDB) ~= nil and AutoBodyResDB or {}

    -- Copy any settings from default if they don't exist in current profile
    NS.CopyDefaults(NS.DefaultDatabase, AutoBodyResDB)

    -- Reference to active db profile
    -- Always use this directly or reference will be invalid
    NS.db = AutoBodyResDB

    -- Remove table values no longer found in default settings
    NS.CleanupDB(AutoBodyResDB, NS.DefaultDatabase)

    Options:Setup()
  end
end
AutoBodyResFrame:RegisterEvent("ADDON_LOADED")
