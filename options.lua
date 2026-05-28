local AddonName, NS = ...

-- local CopyTable = CopyTable
local LibStub = LibStub

local SharedMedia = LibStub("LibSharedMedia-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

NS.AceConfig = {
  name = AddonName .. " v" .. GetAddOnMetadata(AddonName, "Version"),
  descStyle = "inline",
  type = "group",
  -- childGroups = "tab",
  args = {
    autoReadyCheck = {
      name = "Auto Ready Check",
      type = "group",
      inline = true,
      order = 1,
      args = {
        enable = {
          name = "Enable Auto Ready Check",
          desc = "Auto-accept ready checks initiated by your group or raid leader.",
          type = "toggle",
          width = "double",
          order = 1,
          set = function(_, val)
            NS.db.global.readyCheck = val
          end,
          get = function(_)
            return NS.db.global.readyCheck
          end,
        },
      },
    },
    autoRelease = {
      name = "Auto Release",
      type = "group",
      inline = true,
      order = 2,
      args = {
        enable = {
          name = "Enable Auto Release",
          desc = "Auto-release your body upon death.",
          type = "toggle",
          width = "full",
          order = 1,
          set = function(_, val)
            NS.db.global.release = val
          end,
          get = function(_)
            return NS.db.global.release
          end,
        },
        delay = {
          name = "Release delay (seconds)",
          desc = "How long to wait after death before releasing. Lets you manually use a soulstone or wait for a res.",
          type = "range",
          width = 1.5,
          order = 2,
          min = 0,
          max = 10,
          step = 1,
          disabled = function()
            return not NS.db.global.release
          end,
          set = function(_, val)
            NS.db.global.releaseDelay = val
          end,
          get = function(_)
            return NS.db.global.releaseDelay
          end,
        },
      },
    },
    autoLeave = {
      name = "Auto Leave",
      type = "group",
      inline = true,
      order = 3,
      args = {
        enable = {
          name = "Enable Auto Leave",
          desc = "Auto-leave battlegrounds and arenas after the match ends.",
          type = "toggle",
          width = "full",
          order = 1,
          set = function(_, val)
            NS.db.global.leave = val
          end,
          get = function(_)
            return NS.db.global.leave
          end,
        },
        delay = {
          name = "Leave delay (seconds)",
          desc = "How long to wait after the match ends before leaving. Useful for glancing at the scoreboard.",
          type = "range",
          width = 1.5,
          order = 2,
          min = 2,
          max = 15,
          step = 1,
          disabled = function()
            return not NS.db.global.leave
          end,
          set = function(_, val)
            NS.db.global.leaveDelay = val
          end,
          get = function(_)
            return NS.db.global.leaveDelay
          end,
        },
      },
    },
    autoRoleCheck = {
      name = "Auto Role Check",
      type = "group",
      inline = true,
      order = 4,
      args = {
        enable = {
          name = "Enable Auto Role Check",
          desc = "Auto-accept role checks in rated battlegrounds and rated arenas. Uncheck to choose roles individually below.",
          type = "toggle",
          width = "double",
          order = 1,
          set = function(_, val)
            NS.db.global.role.enabled = val
          end,
          get = function(_)
            return NS.db.global.role.enabled
          end,
        },
        description = {
          name = "Enable by role:",
          type = "description",
          fontSize = "medium",
          width = "full",
          order = 2,
          disabled = function()
            return not NS.db.global.role.enabled
          end,
        },
        allRoles = {
          name = "All",
          type = "toggle",
          width = 0.5,
          order = 3,
          disabled = function()
            return not NS.db.global.role.enabled
          end,
          set = function(_, val)
            NS.db.global.role.all = val
          end,
          get = function(_)
            return NS.db.global.role.all
          end,
        },
        tank = {
          name = "Tank",
          type = "toggle",
          width = 0.5,
          order = 4,
          disabled = function()
            return not NS.db.global.role.enabled or NS.db.global.role.all
          end,
          set = function(_, val)
            NS.db.global.role.tank = val
          end,
          get = function(_)
            return NS.db.global.role.tank
          end,
        },
        healer = {
          name = "Healer",
          type = "toggle",
          width = 0.5,
          order = 5,
          disabled = function()
            return not NS.db.global.role.enabled or NS.db.global.role.all
          end,
          set = function(_, val)
            NS.db.global.role.healer = val
          end,
          get = function(_)
            return NS.db.global.role.healer
          end,
        },
        dps = {
          name = "DPS",
          type = "toggle",
          width = 0.5,
          order = 6,
          disabled = function()
            return not NS.db.global.role.enabled or NS.db.global.role.all
          end,
          set = function(_, val)
            NS.db.global.role.dps = val
          end,
          get = function(_)
            return NS.db.global.role.dps
          end,
        },
      },
    },
    autoResurrect = {
      name = "Auto Resurrect",
      type = "group",
      inline = true,
      order = 5,
      args = {
        enable = {
          name = "Enable Auto Resurrect",
          desc = "Auto-accept resurrection from a friend, spell, or by being in range of your body.",
          type = "toggle",
          width = 1.5,
          order = 1,
          set = function(_, val)
            NS.db.global.resurrect = val
          end,
          get = function(_)
            return NS.db.global.resurrect
          end,
        },
        test = {
          name = function()
            return "Test " .. ((NS.testMode and "(On)") or "(Off)")
          end,
          desc = "Show placeholder text and unlock the frame for repositioning. Click again to lock it back in place.",
          type = "execute",
          width = 1.5,
          order = 2,
          func = function()
            if NS.testMode then
              NS.DisableTestMode()
            else
              NS.EnableTestMode()
            end
            AceConfigRegistry:NotifyChange(AddonName)
          end,
        },
        spacer1 = { name = " ", type = "description", order = 3, width = "full" },
        enableText = {
          name = "Enable Body Res text",
          desc = '(i.e. "Body Res in 01:14", "Body Res Available", "Body Taken")',
          type = "toggle",
          width = 1.5,
          order = 4,
          set = function(_, val)
            NS.db.global.text = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.global.text
          end,
        },
        enablePopupText = {
          name = "Enable GY Popup Body Res text",
          desc = "Show body res status text inside the graveyard spirit healer popup.",
          type = "toggle",
          width = 1.5,
          order = 4.5,
          set = function(_, val)
            NS.db.global.popuptext = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.global.popuptext
          end,
        },
        spacer1b = { name = " ", type = "description", order = 4.6, width = "full" },
        spacer2 = { name = " ", type = "description", order = 5, width = "full" },
        delay = {
          name = "Resurrect delay (seconds)",
          desc = "How long to wait before auto-accepting a resurrect or retrieving your body. Lets you manually decline or wait.",
          type = "range",
          width = 1.5,
          order = 6,
          min = 0,
          max = 10,
          step = 1,
          disabled = function()
            return not NS.db.global.resurrect
          end,
          set = function(_, val)
            NS.db.global.resurrectDelay = val
          end,
          get = function(_)
            return NS.db.global.resurrectDelay
          end,
        },
        fontsize = {
          type = "range",
          name = "Font Size",
          width = 1.5,
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
        spacer4 = { name = " ", type = "description", order = 9, width = "full" },
        font = {
          type = "select",
          name = "Font",
          width = 2.0,
          order = 10,
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
        spacer5 = { name = " ", type = "description", order = 11, width = 0.1 },
        color = {
          type = "color",
          name = "Color",
          width = 1.0,
          order = 12,
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
        spacer6 = { name = " ", type = "description", order = 13, width = "full" },
        outline = {
          type = "select",
          name = "Outline",
          width = 2.0,
          order = 14,
          values = {
            ["OUTLINE"] = "Outline",
            ["THICKOUTLINE"] = "Thick Outline",
            ["MONOCHROME, OUTLINE"] = "Monochrome Outline",
            ["MONOCHROME, THICKOUTLINE"] = "Monochrome Thick Outline",
            [""] = "None",
          },
          set = function(_, val)
            NS.db.global.outline = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.global.outline
          end,
        },
        spacer7 = { name = " ", type = "description", order = 15, width = 0.1 },
        shadowColor = {
          type = "color",
          name = "Shadow Color",
          width = 1.0,
          order = 16,
          hasAlpha = true,
          set = function(_, val1, val2, val3, val4)
            NS.db.global.shadowColor.r = val1
            NS.db.global.shadowColor.g = val2
            NS.db.global.shadowColor.b = val3
            NS.db.global.shadowColor.a = val4
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.global.shadowColor.r,
              NS.db.global.shadowColor.g,
              NS.db.global.shadowColor.b,
              NS.db.global.shadowColor.a
          end,
        },
        spacer8 = { name = " ", type = "description", order = 17, width = "full" },
        shadowOffsetX = {
          type = "range",
          name = "Shadow Offset X",
          width = 1.5,
          order = 18,
          min = -10,
          max = 10,
          step = 1,
          set = function(_, val)
            NS.db.global.shadowOffsetX = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.global.shadowOffsetX
          end,
        },
        shadowOffsetY = {
          type = "range",
          name = "Shadow Offset Y",
          width = 1.5,
          order = 19,
          min = -10,
          max = 10,
          step = 1,
          set = function(_, val)
            NS.db.global.shadowOffsetY = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.global.shadowOffsetY
          end,
        },
      },
    },
    -- disablegroup = {
    --   name = "Choose what content this should not work in",
    --   type = "group",
    --   inline = true,
    --   order = 5,
    --   args = {
    --     description = {
    --       name = "These settings override any relevant maps selected in the maps tab settings.",
    --       type = "description",
    --       order = 1,
    --     },
    --     spacer1 = { type = "description", order = 2, name = " " },
    --     disableblitz = {
    --       name = "Disable in 8v8 Rated Blitz",
    --       desc = "Toggling this feature on will disable in rated blitz.",
    --       type = "toggle",
    --       width = "double",
    --       order = 3,
    --       set = function(_, val)
    --         NS.db.global.disableblitz = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.disableblitz
    --       end,
    --     },
    --     disablerated = {
    --       name = "Disable in 10v10 Rated Battlegrounds",
    --       desc = "Toggling this feature on will disable in non-blitz rated bgs.",
    --       type = "toggle",
    --       width = "double",
    --       order = 4,
    --       set = function(_, val)
    --         NS.db.global.disablerated = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.disablerated
    --       end,
    --     },
    --     disablerandom = {
    --       name = "Disable in Random Battlegrounds",
    --       desc = "Toggling this feature on will disable in random bgs.",
    --       type = "toggle",
    --       width = "double",
    --       order = 5,
    --       set = function(_, val)
    --         NS.db.global.disablerandom = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.disablerandom
    --       end,
    --     },
    --     disableepic = {
    --       name = "Disable in Epic Battlegrounds",
    --       desc = "Toggling this feature on will disable in epic bgs.",
    --       type = "toggle",
    --       width = "double",
    --       order = 6,
    --       set = function(_, val)
    --         NS.db.global.disableepic = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.disableepic
    --       end,
    --     },
    --     disablebrawl = {
    --       name = "Disable in Brawls",
    --       desc = "Toggling this feature on will disable in pvp brawls.",
    --       type = "toggle",
    --       width = "double",
    --       order = 7,
    --       set = function(_, val)
    --         NS.db.global.disablebrawl = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.disablebrawl
    --       end,
    --     },
    --   },
    -- },
    -- allmaps = {
    --   name = "Enable for all maps",
    --   desc = "Toggling this feature on will enable in all battleground maps.",
    --   type = "toggle",
    --   width = "double",
    --   order = 6,
    --   set = function(_, val)
    --     NS.db.global.allmaps = val
    --     NS.OnDbChanged()
    --   end,
    --   get = function(_)
    --     return NS.db.global.allmaps
    --   end,
    -- },
    -- normalgroup = {
    --   name = "Battlegrounds",
    --   type = "group",
    --   inline = true,
    --   order = 7,
    --   disabled = function(info)
    --     return info[3]
    --       and (
    --         (NS.db.global.disableblitz and NS.db.global.disablerated and NS.db.global.disablerandom)
    --         or NS.db.global.allmaps
    --       )
    --   end,
    --   args = {
    --     arathibasin = {
    --       name = "Arathi Basin",
    --       desc = "Turn on for Arathi Basin.",
    --       type = "toggle",
    --       width = "full",
    --       order = 1,
    --       set = function(_, val)
    --         NS.db.global.arathibasin = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.arathibasin
    --       end,
    --     },
    --     deephaulravine = {
    --       name = "Deephaul Ravine",
    --       desc = "Turn on for Deephaul Ravine.",
    --       type = "toggle",
    --       width = "full",
    --       order = 2,
    --       set = function(_, val)
    --         NS.db.global.deephaulravine = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.deephaulravine
    --       end,
    --     },
    --     deepwindgorge = {
    --       name = "Deepwind Gorge",
    --       desc = "Turn on for Deepwind Gorge.",
    --       type = "toggle",
    --       width = "full",
    --       order = 3,
    --       set = function(_, val)
    --         NS.db.global.deepwindgorge = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.deepwindgorge
    --       end,
    --     },
    --     eyeofthestorm = {
    --       name = "Eye of the Storm",
    --       desc = "Turn on for Eye of the Storm.",
    --       type = "toggle",
    --       width = "full",
    --       order = 4,
    --       set = function(_, val)
    --         NS.db.global.eyeofthestorm = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.eyeofthestorm
    --       end,
    --     },
    --     seethingshore = {
    --       name = "Seething Shore",
    --       desc = "Turn on for Seething Shore.",
    --       type = "toggle",
    --       width = "full",
    --       order = 5,
    --       set = function(_, val)
    --         NS.db.global.seethingshore = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.seethingshore
    --       end,
    --     },
    --     silvershardmines = {
    --       name = "Silvershard Mines",
    --       desc = "Turn on for Silvershard Mines.",
    --       type = "toggle",
    --       width = "full",
    --       order = 6,
    --       set = function(_, val)
    --         NS.db.global.silvershardmines = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.silvershardmines
    --       end,
    --     },
    --     thebattleforgilneas = {
    --       name = "The Battle for Gilneas",
    --       desc = "Turn on for The Battle for Gilneas.",
    --       type = "toggle",
    --       width = "full",
    --       order = 7,
    --       set = function(_, val)
    --         NS.db.global.thebattleforgilneas = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.thebattleforgilneas
    --       end,
    --     },
    --     templeofkotmogu = {
    --       name = "Temple of Kotmogu",
    --       desc = "Turn on for Temple of Kotmogu.",
    --       type = "toggle",
    --       width = "full",
    --       order = 8,
    --       set = function(_, val)
    --         NS.db.global.templeofkotmogu = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.templeofkotmogu
    --       end,
    --     },
    --     twinpeaks = {
    --       name = "Twin Peaks",
    --       desc = "Turn on for Twin Peaks.",
    --       type = "toggle",
    --       width = "full",
    --       order = 9,
    --       set = function(_, val)
    --         NS.db.global.twinpeaks = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.twinpeaks
    --       end,
    --     },
    --     warsonggulch = {
    --       name = "Warsong Gulch",
    --       desc = "Turn on for Warsong Gulch.",
    --       type = "toggle",
    --       width = "full",
    --       order = 10,
    --       set = function(_, val)
    --         NS.db.global.warsonggulch = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.warsonggulch
    --       end,
    --     },
    --   },
    -- },
    -- epicgroup = {
    --   name = "Epic Battlegrounds",
    --   type = "group",
    --   inline = true,
    --   order = 8,
    --   disabled = function(info)
    --     return info[3] and (NS.db.global.disableepic or NS.db.global.allmaps)
    --   end,
    --   args = {
    --     alteracvalley = {
    --       name = "Alterac Valley",
    --       desc = "Turn on for Alterac Valley.",
    --       type = "toggle",
    --       width = "full",
    --       order = 1,
    --       set = function(_, val)
    --         NS.db.global.alteracvalley = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.alteracvalley
    --       end,
    --     },
    --     ashran = {
    --       name = "Ashran",
    --       desc = "Turn on for Ashran.",
    --       type = "toggle",
    --       width = "full",
    --       order = 2,
    --       set = function(_, val)
    --         NS.db.global.ashran = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.ashran
    --       end,
    --     },
    --     battleforwintergrasp = {
    --       name = "Battle for Wintergrasp",
    --       desc = "Turn on for Battle for Wintergrasp.",
    --       type = "toggle",
    --       width = "full",
    --       order = 3,
    --       set = function(_, val)
    --         NS.db.global.battleforwintergrasp = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.battleforwintergrasp
    --       end,
    --     },
    --     classicashran = {
    --       name = "Classic Ashran",
    --       desc = "Turn on for Classic Ashran.",
    --       type = "toggle",
    --       width = "full",
    --       order = 4,
    --       set = function(_, val)
    --         NS.db.global.classicashran = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.classicashran
    --       end,
    --     },
    --     isleofconquest = {
    --       name = "Isle of Conquest",
    --       desc = "Turn on for Isle of Conquest.",
    --       type = "toggle",
    --       width = "full",
    --       order = 5,
    --       set = function(_, val)
    --         NS.db.global.isleofconquest = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.isleofconquest
    --       end,
    --     },
    --     korraksrevenge = {
    --       name = "Korrak's Revenge",
    --       desc = "Turn on for Korrak's Revenge.",
    --       type = "toggle",
    --       width = "full",
    --       order = 6,
    --       set = function(_, val)
    --         NS.db.global.korraksrevenge = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.korraksrevenge
    --       end,
    --     },
    --     tarrenmillvssouthshore = {
    --       name = "Tarren Mill vs Southshore",
    --       desc = "Turn on for Tarren Mill vs Southshore.",
    --       type = "toggle",
    --       width = "full",
    --       order = 7,
    --       set = function(_, val)
    --         NS.db.global.tarrenmillvssouthshore = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.tarrenmillvssouthshore
    --       end,
    --     },
    --   },
    -- },
    -- brawlgroup = {
    --   name = "Brawl Battlegrounds",
    --   type = "group",
    --   inline = true,
    --   order = 9,
    --   disabled = function(info)
    --     return info[3] and (NS.db.global.disablebrawl or NS.db.global.allmaps)
    --   end,
    --   args = {
    --     arathiblizzard = {
    --       name = "Arathi Blizzard",
    --       desc = "Turn on for Arathi Blizzard.",
    --       type = "toggle",
    --       width = "full",
    --       order = 1,
    --       set = function(_, val)
    --         NS.db.global.arathiblizzard = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.arathiblizzard
    --       end,
    --     },
    --     compstomp = {
    --       name = "Comp Stomp",
    --       desc = "Turn on for Comp Stomp.",
    --       type = "toggle",
    --       width = "full",
    --       order = 2,
    --       set = function(_, val)
    --         NS.db.global.compstomp = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.compstomp
    --       end,
    --     },
    --     cookingimpossible = {
    --       name = "Cooking Impossible",
    --       desc = "Turn on for Cooking Impossible.",
    --       type = "toggle",
    --       width = "full",
    --       order = 3,
    --       set = function(_, val)
    --         NS.db.global.cookingimpossible = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.cookingimpossible
    --       end,
    --     },
    --     deepsix = {
    --       name = "Deep Six",
    --       desc = "Turn on for Deep Six.",
    --       type = "toggle",
    --       width = "full",
    --       order = 4,
    --       set = function(_, val)
    --         NS.db.global.deepsix = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.deepsix
    --       end,
    --     },
    --     deepwinddunk = {
    --       name = "Deepwind Dunk",
    --       desc = "Turn on for Deepwind Dunk.",
    --       type = "toggle",
    --       width = "full",
    --       order = 5,
    --       set = function(_, val)
    --         NS.db.global.deepwinddunk = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.deepwinddunk
    --       end,
    --     },
    --     gravitylapse = {
    --       name = "Gravity Lapse",
    --       desc = "Turn on for Gravity Lapse.",
    --       type = "toggle",
    --       width = "full",
    --       order = 6,
    --       set = function(_, val)
    --         NS.db.global.gravitylapse = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.gravitylapse
    --       end,
    --     },
    --     templeofhotmogu = {
    --       name = "Temple of Hotmogu",
    --       desc = "Turn on for Temple of Hotmogu.",
    --       type = "toggle",
    --       width = "full",
    --       order = 7,
    --       set = function(_, val)
    --         NS.db.global.templeofhotmogu = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.templeofhotmogu
    --       end,
    --     },
    --     warsongscramble = {
    --       name = "Warsong Scramble",
    --       desc = "Turn on for Warsong Scramble.",
    --       type = "toggle",
    --       width = "full",
    --       order = 8,
    --       set = function(_, val)
    --         NS.db.global.warsongscramble = val
    --         NS.OnDbChanged()
    --       end,
    --       get = function(_)
    --         return NS.db.global.warsongscramble
    --       end,
    --     },
    --   },
    -- },
  },
}
