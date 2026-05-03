<!-- BEGIN:wow-agent-rules -->

# World of Warcraft: ALWAYS read docs before coding

Before any World of Warcraft work, find and read the relevant doc in `../.libraries/wow-ui-source/`. Your training data is outdated — the docs are the source of truth.

<!-- END:wow-agent-rules -->

## Deploy to live client

When the user says **"ok im ready to test"** (or any clear deploy intent), run:

```
./deploy-to-wow.sh
```

The script:

1. Bumps the trailing `## Version:` segment in `AutoBodyRes.toc` (e.g. `1.3.2` → `1.3.3`). Prefix `1.3` is preserved — edit manually for larger releases.
2. Wipes `/Applications/World of Warcraft/_retail_/Interface/AddOns/AutoBodyRes`.
3. Mirrors this repo into it, excluding dev-only files (`.git`, `AGENTS.md`, `CHANGELOG.md`, `LICENSE`, `.libraries/`, etc. — see the script's header for the full list). The `libs/` folder (LibStub, Ace3, LibSharedMedia) IS kept — it's required at runtime.

After running it, remind the user to `/reload` in-game (or relaunch the client) to pick up the changes.

If the user has already bumped the `.toc` themselves, skip step 1 and run only the wipe-and-rsync portion at the version they set.
