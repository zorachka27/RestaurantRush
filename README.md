# Restaurant Rush

This repository is the foundation for a Roblox restaurant tycoon game called Restaurant Rush.

## Step 1 and Step 2

These steps establish:

- a clean Roblox project structure
- data saving and loading via DataStoreService
- a starter restaurant model
- a money + progression base
- a customer loop where NPCs enter, sit, order, wait, eat, pay, and leave

## Project structure

- `default.project.json` — Rojo project mapping for Roblox Studio
- `src/Shared/Config.lua` — global tables for food, worker, and restaurant configuration
- `src/ServerScriptService/Bootstrap.server.lua` — boots the server systems
- `src/ServerScriptService/Services/DataService.lua` — safe DataStore saving/loading
- `src/ServerScriptService/Services/RestaurantService.lua` — restaurant + customer flow
- `src/StarterPlayer/StarterPlayerScripts/ClientController.client.lua` — minimal HUD and client-side sync

## Optional Roblox Studio workflow

If you want to use Roblox Studio directly without Rojo, recreate this folder structure inside the Explorer:

- ReplicatedStorage > Shared > Config (ModuleScript)
- ServerScriptService > Bootstrap (Script)
- ServerScriptService > Services > DataService (ModuleScript)
- ServerScriptService > Services > RestaurantService (ModuleScript)
- StarterPlayer > StarterPlayerScripts > ClientController (LocalScript)

## Current feature focus

Step 2 adds the core customer loop:

- customers walk in
- select a table
- order food
- wait for their food
- eat and pay
- leave the restaurant

This is the next milestone in the full Restaurant Rush progression loop:

Cook → Serve → Earn → Upgrade → Expand → Unlock
