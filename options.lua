local AddonName, NS = ...

local CopyTable = CopyTable
local LibStub = LibStub

local SharedMedia = LibStub("LibSharedMedia-3.0")

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
            NS.OnDbChanged()
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
            NS.OnDbChanged()
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
            NS.OnDbChanged()
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
            NS.OnDbChanged()
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
            description = {
              name = "These settings override any relevant maps selected in the maps tab settings.",
              type = "description",
              order = 1,
            },
            spacing1 = { type = "description", order = 2, name = " " },
            disableblitz = {
              name = "Disable in 8v8 Rated Blitz",
              desc = "Toggling this feature on will disable in rated blitz.",
              type = "toggle",
              width = "double",
              order = 3,
              set = function(_, val)
                NS.db.global.disableblitz = val
                NS.OnDbChanged()
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
              order = 4,
              set = function(_, val)
                NS.db.global.disablerated = val
                NS.OnDbChanged()
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
              order = 5,
              set = function(_, val)
                NS.db.global.disablerandom = val
                NS.OnDbChanged()
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
              order = 6,
              set = function(_, val)
                NS.db.global.disableepic = val
                NS.OnDbChanged()
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
              order = 7,
              set = function(_, val)
                NS.db.global.disablebrawl = val
                NS.OnDbChanged()
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
          min = 2,
          max = 64,
          step = 1,
          set = function(_, val)
            NS.db.global.fontsize = val
            NS.OnDbChanged()
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
          values = SharedMedia:HashTable("font"),
          set = function(_, val)
            NS.db.global.font = val
            NS.OnDbChanged()
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
            NS.OnDbChanged()
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
            NS.OnDbChanged()
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
          name = "These settings only matter if you have the matching game mode enabled in the general tab settings.",
          type = "description",
          fontSize = "medium",
          width = "double",
          order = 1,
        },
        spacing2 = { type = "description", order = 2, name = " " },
        allmaps = {
          name = "Enable for all maps",
          desc = "Toggling this feature on will enable in all battleground maps.",
          type = "toggle",
          width = "double",
          order = 3,
          set = function(_, val)
            NS.db.global.allmaps = val
            NS.OnDbChanged()
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
                NS.OnDbChanged()
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
                NS.OnDbChanged()
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
                NS.OnDbChanged()
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
                NS.OnDbChanged()
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
                NS.OnDbChanged()
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
                NS.OnDbChanged()
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
                NS.OnDbChanged()
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
                NS.OnDbChanged()
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
                NS.OnDbChanged()
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
                NS.OnDbChanged()
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
                NS.OnDbChanged()
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
                NS.OnDbChanged()
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
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.battleforwintergrasp
              end,
            },
            classicashran = {
              name = "Classic Ashran",
              desc = "Turn on for Classic Ashran.",
              type = "toggle",
              width = "full",
              order = 4,
              set = function(_, val)
                NS.db.global.classicashran = val
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.classicashran
              end,
            },
            isleofconquest = {
              name = "Isle of Conquest",
              desc = "Turn on for Isle of Conquest.",
              type = "toggle",
              width = "full",
              order = 5,
              set = function(_, val)
                NS.db.global.isleofconquest = val
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.isleofconquest
              end,
            },
            korraksrevenge = {
              name = "Korrak's Revenge",
              desc = "Turn on for Korrak's Revenge.",
              type = "toggle",
              width = "full",
              order = 6,
              set = function(_, val)
                NS.db.global.korraksrevenge = val
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.korraksrevenge
              end,
            },
            tarrenmillvssouthshore = {
              name = "Tarren Mill vs Southshore",
              desc = "Turn on for Tarren Mill vs Southshore.",
              type = "toggle",
              width = "full",
              order = 7,
              set = function(_, val)
                NS.db.global.tarrenmillvssouthshore = val
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.tarrenmillvssouthshore
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
                NS.db.global.arathiblizzard = val
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.arathiblizzard
              end,
            },
            compstomp = {
              name = "Comp Stomp",
              desc = "Turn on for Comp Stomp.",
              type = "toggle",
              width = "full",
              order = 2,
              set = function(_, val)
                NS.db.global.compstomp = val
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.compstomp
              end,
            },
            cookingimpossible = {
              name = "Cooking Impossible",
              desc = "Turn on for Cooking Impossible.",
              type = "toggle",
              width = "full",
              order = 3,
              set = function(_, val)
                NS.db.global.cookingimpossible = val
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.cookingimpossible
              end,
            },
            deepsix = {
              name = "Deep Six",
              desc = "Turn on for Deep Six.",
              type = "toggle",
              width = "full",
              order = 4,
              set = function(_, val)
                NS.db.global.deepsix = val
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.deepsix
              end,
            },
            deepwinddunk = {
              name = "Deepwind Dunk",
              desc = "Turn on for Deepwind Dunk.",
              type = "toggle",
              width = "full",
              order = 5,
              set = function(_, val)
                NS.db.global.deepwinddunk = val
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.deepwinddunk
              end,
            },
            gravitylapse = {
              name = "Gravity Lapse",
              desc = "Turn on for Gravity Lapse.",
              type = "toggle",
              width = "full",
              order = 6,
              set = function(_, val)
                NS.db.global.gravitylapse = val
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.gravitylapse
              end,
            },
            templeofhotmogu = {
              name = "Temple of Hotmogu",
              desc = "Turn on for Temple of Hotmogu.",
              type = "toggle",
              width = "full",
              order = 7,
              set = function(_, val)
                NS.db.global.templeofhotmogu = val
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.templeofhotmogu
              end,
            },
            warsongscramble = {
              name = "Warsong Scramble",
              desc = "Turn on for Warsong Scramble.",
              type = "toggle",
              width = "full",
              order = 8,
              set = function(_, val)
                NS.db.global.warsongscramble = val
                NS.OnDbChanged()
              end,
              get = function(_)
                return NS.db.global.warsongscramble
              end,
            },
          },
        },
      },
    },
  },
}
