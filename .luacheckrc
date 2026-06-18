-- Static analysis for the auto-body-res WoW addon.  Run from the repo root: luacheck .
--
-- Tailored to the addon: WoW globals seeded from its .luarc.json and completed
-- with a luacheck harvest of APIs the code actually calls (luacheck has no WoW
-- API library of its own, unlike the LSP's WoW addon the .luarc.json leans on).
-- NOTE: luacheck must run under Lua <= 5.4 (it crashes on 5.5). The `luacheck`
-- on PATH is built against lua@5.4; we still lint WoW's 5.1 dialect via std.

std = "lua51"            -- WoW runs Lua 5.1
max_line_length = false  -- WoW addon lines are routinely wide

exclude_files = {
  ".libraries", "libs",
}

-- WoW idioms that aren't defects: `_ADDON` addon-load vararg; `self` on
-- `:` colon-method APIs that don't use it.
ignore = { "_ADDON", "212/self" }

-- Globals the addon DEFINES/WRITES (saved-vars, slash handlers).
globals = {
  "AutoBodyResDB", "SLASH_ABR1", "SLASH_ABR2", "SlashCmdList",
}

-- Blizzard client API the addon READS.
read_globals = {
  "AcceptResurrect", "C_AddOns", "C_DeathInfo", "C_PvP", "C_Timer", "CompleteLFGRoleCheck",
  "ConfirmReadyCheck", "CopyTable", "CreateFrame", "FrameUtil", "GetActiveBrawlInfo",
  "GetAddOnMetadata", "GetAreaSpiritHealerTime", "GetAvailableBrawlInfo",
  "GetBattlefieldWinner", "GetClassColor", "GetCorpseRecoveryDelay", "GetInstanceInfo",
  "GetLFGRoleUpdate", "GetPVPRoles", "GetSelfResurrectOptions", "GetTime", "InCombatLockdown",
  "IsInInstance", "LeaveBattlefield", "LibStub", "RepopMe", "RetrieveCorpse",
  "SECONDS_PER_MIN", "SecondsToClock", "StaticPopupDialogs", "StaticPopup_Hide",
  "StaticPopup_Show", "UIParent", "UnitClass", "UnitIsDeadOrGhost", "format", "hooksecurefunc",
  "issecretvalue", "tinsert", "wipe",
}
