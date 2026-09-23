# Restaurant Rush

This repository is the foundation for a Roblox restaurant tycoon game called Restaurant Rush.

## Step 1: Foundation

This step establishes the project structure and the core systems needed for future gameplay features:

- Modular game configuration
- Data saving/loading via DataStoreService
- Starter restaurant generation
- Player progression state
- Remote event setup for client HUD updates
- A simple money/upgrade loop

## Project structure

- `default.project.json` — Rojo project mapping for Roblox Studio
- `src/Shared/Config.lua` — global tables for food, worker, and restaurant configuration
- `src/ServerScriptService/Bootstrap.server.lua` — boots the server systems
- `src/ServerScriptService/Services/DataService.lua` — safe DataStore saving/loading
- `src/ServerScriptService/Services/RestaurantService.lua` — player state management and restaurant setup
- `src/StarterPlayer/StarterPlayerScripts/ClientController.client.lua` — minimal HUD and client-side sync

## How to use in Roblox Studio

1. Install Rojo and sync this project into Roblox Studio.
2. Open the generated project in Studio.
3. Press Play.
4. A basic restaurant model will appear in Workspace and a HUD will appear on screen.

## Current state

This step is intentionally lightweight and modular so later steps can add:

- customers
- workers
- cooking stations
- food orders
- upgrades
- shops
- saved progression
- events
- world unlocks

This is the first milestone in building the full Restaurant Rush game loop:

Cook → Serve → Earn → Upgrade → Expand → Unlock
