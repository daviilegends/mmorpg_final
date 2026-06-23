# CLAUDE.md

## Project Name

**Cozy Realms Online**
A small 3D low-poly online RPG prototype inspired by classic MMORPGs, cozy farming games, and personal housing systems.

This is **not** a full World of Warcraft-scale MMORPG.
The goal is to build a small, playable, expandable online RPG with:

* Player movement
* Cozy fantasy world
* Personal house
* Farming
* Inventory
* Cooking
* Food-based healing
* Simple exploration
* Future multiplayer support

---

## Core Rule

Build this project in small, testable milestones.

Do **not** attempt to build the full MMORPG at once.

The first priority is a fun offline vertical slice. Multiplayer comes later.

---

## Tech Stack

### Engine

Use **Godot 4.x**.

### Language

Use **GDScript** unless there is a strong reason to use C#.

### Visual Style

Use a **3D low-poly cozy fantasy style** with a top-down, isometric, or slightly angled third-person camera.

Avoid realistic graphics.

### Target Platform

Initial target:

* Windows desktop
* Local development
* Single-player prototype

Future target:

* Online multiplayer desktop game

---

## Game Vision

The player lives in a cozy fantasy world where they can:

* Own a personal house
* Plant and harvest crops
* Cook food
* Store items
* Explore outdoor areas
* Heal using food they created
* Customize their space
* Eventually interact with other players online

The game should feel simple, peaceful, expandable, and personal.

---

## Main Inspiration

Use these only as broad inspiration:

* World of Warcraft: open world, fantasy adventure, online feeling
* Stardew Valley: farming, cozy progression
* Albion Online: camera angle, simple online RPG structure
* RuneScape: simple readable world, progression, gathering
* Animal Crossing: personal space and cozy lifestyle

Do **not** copy copyrighted names, maps, UI, characters, logos, or exact mechanics.

---

## Development Philosophy

Always prefer:

* Simple systems over complex systems
* Readable code over clever code
* Modular scenes over giant scenes
* Small commits over large rewrites
* Working prototypes over perfect architecture
* Placeholder assets over waiting for final art

Avoid:

* Premature multiplayer
* Huge open worlds
* Complex combat systems early
* Classes, races, guilds, raids, dungeons, or factions in the first phase
* Overengineering
* Large code rewrites without explaining why

---

## First Milestone: Offline Vertical Slice

The first playable version must include:

1. A controllable player character
2. A small outdoor map
3. Camera follow system
4. Basic interaction system
5. Inventory
6. Farming plot
7. Plant seed
8. Crop growth stages
9. Harvest crop
10. Cooking simple food
11. Food heals the player
12. Player house exterior
13. Player house interior
14. Chest storage
15. Save/load local progress

Do not add multiplayer before this milestone is stable.

---

## Second Milestone: Local Multiplayer Prototype

Only after the offline vertical slice works:

1. Two players can connect locally
2. Players can see each other
3. Player position is synchronized
4. Basic nameplate above player
5. Simple chat
6. No combat yet
7. No economy yet
8. No global persistence yet

---

## Third Milestone: Online Persistence

After basic multiplayer:

1. Account or player ID system
2. Save player inventory
3. Save player position
4. Save crop states
5. Save house storage
6. Save basic character data
7. Server-authoritative decisions for important state

---

## Suggested Future Backend

Do not implement backend until requested.

Possible future options:

* Nakama
* Colyseus
* Custom Node.js server
* Custom Go server

Default future recommendation: **Nakama** or **Colyseus**.

For now, keep the game offline and modular enough to support networking later.

---

## Folder Structure

Use a clean folder structure similar to this:

```text
res://
  assets/
    audio/
    fonts/
    icons/
    materials/
    models/
    textures/
  scenes/
    player/
    world/
    house/
    farming/
    inventory/
    ui/
    items/
    npcs/
  scripts/
    core/
    player/
    world/
    house/
    farming/
    inventory/
    ui/
    items/
    save/
  resources/
    items/
    crops/
    recipes/
  autoload/
  docs/
```

Keep related scenes and scripts close together.

Do not dump everything into one folder.

---

## Documentation Files

Maintain these files inside `docs/`:

```text
docs/GAME_DESIGN.md
docs/PROJECT_LOG.md
docs/ROADMAP.md
docs/ASSET_CREDITS.md
docs/TECHNICAL_NOTES.md
```

Update them when important changes happen.

### GAME_DESIGN.md

Should contain:

* Game concept
* Core loop
* Player goals
* Main mechanics
* Style direction
* Future ideas

### PROJECT_LOG.md

Should contain:

* Date
* What changed
* What works
* What is broken
* Next recommended step

### ROADMAP.md

Should contain:

* Current milestone
* Completed tasks
* Next tasks
* Blocked tasks
* Future ideas

### ASSET_CREDITS.md

Should contain:

* Asset name
* Author
* Source link
* License
* Usage notes

### TECHNICAL_NOTES.md

Should contain:

* Architecture decisions
* Known limitations
* Save system notes
* Multiplayer preparation notes

---

## Asset Policy

Only use assets that are legally safe.

Allowed asset sources:

* Kenney
* Quaternius
* KayKit
* Poly Haven
* ambientCG
* OpenGameArt, only after checking license
* itch.io free assets, only after checking license
* Pixabay audio
* Sonniss GDC audio bundles
* Freesound, only after checking license

Preferred licenses:

* CC0
* Public domain
* Royalty-free commercial use

Always document assets in:

```text
docs/ASSET_CREDITS.md
```

Do not use ripped assets from commercial games.

Do not use World of Warcraft assets.

Do not use copyrighted music.

Do not use Pokémon, Blizzard, Nintendo, Riot, or other protected characters, names, models, UI, sounds, or logos.

---

## Coding Standards

Use clear, simple GDScript.

Prefer:

* Small scripts
* Descriptive names
* One responsibility per script
* Signals for communication when appropriate
* Resources for item/crop/recipe data
* Comments only when they clarify non-obvious behavior

Avoid:

* Giant manager classes
* Hardcoded item data everywhere
* Duplicated logic
* Deep inheritance unless necessary
* Complex abstractions too early

---

## Naming Conventions

Use clear English names.

Examples:

```text
PlayerController
InventoryManager
ItemResource
CropResource
FarmingPlot
CookingStation
HouseInterior
ChestStorage
SaveManager
InteractionArea
```

Scene names should be readable.

Script names should match their main class or responsibility.

---

## Core Systems

### Player System

The player needs:

* Movement
* Camera follow
* Interaction ray/area
* Health
* Energy, optional later
* Inventory access

Keep the player controller simple.

---

### Interaction System

The player should be able to interact with:

* Doors
* Chests
* Farming plots
* Cooking stations
* Items
* NPCs later

Use a reusable interaction interface or base pattern.

Every interactable object should expose:

* Display name
* Interaction prompt
* Interaction behavior

Example prompts:

```text
Press E to open chest
Press E to plant seed
Press E to harvest carrot
Press E to enter house
```

---

### Inventory System

The inventory should support:

* Item ID
* Item name
* Icon
* Stack size
* Quantity
* Item type
* Optional healing value
* Optional food value
* Optional seed/crop relationship

Use resource-based item definitions where possible.

Do not hardcode every item inside UI scripts.

---

### Farming System

The farming system should support:

* Empty soil plot
* Plant seed
* Growth stages
* Harvest crop
* Add crop to inventory
* Save/load crop state

Keep growth simple at first.

Use real-time seconds or debug-short growth timers during development.

Example crops:

* Carrot
* Potato
* Wheat
* Berry

---

### Cooking System

The cooking system should support:

* Simple recipes
* Required ingredients
* Output food item
* Food heals player

Example recipes:

```text
Carrot Soup = Carrot + Water
Berry Snack = Berry
Baked Potato = Potato
```

Keep cooking UI simple.

---

### Health System

The player should have:

* Max health
* Current health
* Take damage function
* Heal function

Food items should call the heal system.

No complex combat is needed early.

---

### House System

The house system should include:

* House exterior
* Door interaction
* House interior scene
* Chest storage
* Optional bed later
* Optional closet later
* Optional decoration later

The house should feel personal and expandable.

Do not create advanced building placement yet.

---

### Chest Storage

Chest storage should support:

* Storing items from inventory
* Taking items back
* Saving chest contents
* Loading chest contents

Keep it separate from player inventory.

---

### Save System

The local save system should eventually save:

* Player position
* Player health
* Inventory
* Chest contents
* Crop states
* House state

Use a simple, understandable format.

Do not add encryption or cloud saves early.

---

### UI System

The UI should be clean and simple.

Initial UI:

* Health bar
* Inventory panel
* Interaction prompt
* Chest panel
* Cooking panel
* Simple item tooltip

Avoid complex MMORPG UI early.

No minimap needed in the first milestone.

---

## Multiplayer Rules For Later

Do not add multiplayer until the offline vertical slice is complete.

When multiplayer begins:

* Server must own important game state
* Client should not be trusted for inventory or rewards
* Player movement can be client-predicted later, but keep it simple first
* Synchronize only what is needed
* Do not synchronize every object every frame

Multiplayer priority order:

1. Player joins
2. Player movement sync
3. Player nameplate
4. Chat
5. Persistent inventory
6. Persistent farming
7. Persistent housing

---

## Design Boundaries

Do not implement these early:

* Raids
* Guilds
* Auction house
* Complex economy
* PvP
* Advanced crafting
* Mounts
* Talent trees
* Classes
* Procedural world generation
* Massive server architecture
* Cosmetics shop
* Real-money purchases

These can be future ideas, not first milestone tasks.

---

## Current Gameplay Loop

The first core loop is:

```text
Explore → Gather/Plant → Harvest → Cook → Heal/Store → Improve Home → Explore Again
```

The game should feel rewarding even without combat.

---

## First Test Map

Create a very small test map:

* Grass ground
* A few trees
* A player spawn point
* One house
* One farming area
* One chest
* One cooking station
* One collectible item
* One invisible boundary or simple terrain edge

Do not build a large world yet.

---

## Placeholder Assets

Use placeholder assets freely.

Acceptable placeholders:

* Cubes
* Capsules
* Simple low-poly models
* Temporary icons
* Temporary UI panels
* Temporary sounds

Do not block progress because final art is missing.

---

## Git Workflow

Use Git from the beginning.

Recommended branches:

```text
main
dev
feature/player-movement
feature/inventory
feature/farming
feature/house
feature/save-system
```

Commit small changes.

Commit messages should be clear.

Examples:

```text
Add basic player movement
Create first test map
Add inventory item resource
Add simple farming plot
Add local save manager
```

---

## Claude Code Working Rules

When asked to implement something:

1. Inspect the project structure first.
2. Explain the files that need to change.
3. Make the smallest reasonable change.
4. Avoid unrelated edits.
5. Keep the project runnable.
6. Update documentation if needed.
7. Suggest how to test the change in Godot.

Do not silently rewrite large parts of the project.

Ask before making major architectural changes.

---

## Response Style For Claude

When answering, use this format:

```text
Summary:
- What changed

Files changed:
- file path
- file path

How to test:
- Step 1
- Step 2
- Step 3

Notes:
- Any limitation or next step
```

Keep explanations practical.

Avoid long theory unless requested.

---

## Common Prompts To Use

### Create Project Structure

```text
Create the initial Godot project folder structure for this 3D low-poly cozy online RPG prototype. Do not implement gameplay yet. Add docs/GAME_DESIGN.md, docs/ROADMAP.md, docs/PROJECT_LOG.md, docs/ASSET_CREDITS.md, and docs/TECHNICAL_NOTES.md with useful starter content.
```

### Add Player Movement

```text
Add a simple 3D player controller for Godot 4. The player should move with WASD, rotate toward movement direction, and work with a top-down or angled camera. Keep it simple and explain how to test it.
```

### Add Test Map

```text
Create a small test map scene with grass ground, a few placeholder trees, a house exterior, a farming area, a chest, and a cooking station. Use placeholder assets only.
```

### Add Interaction System

```text
Create a reusable interaction system. The player should see an interaction prompt when near an interactable object and press E to interact. Add one test interactable object.
```

### Add Inventory

```text
Create a simple inventory system using item resources. Support item ID, name, icon placeholder, max stack size, quantity, item type, and optional healing value.
```

### Add Farming

```text
Add a simple farming plot system. The player can plant a seed, wait for growth stages, harvest the crop, and receive an item in inventory.
```

### Add Cooking

```text
Add a simple cooking station. The player can combine ingredients from inventory into a food item. Food items should heal the player.
```

### Add House Interior

```text
Add a house door interaction that moves the player between the outdoor map and a simple house interior scene.
```

### Add Chest Storage

```text
Add a chest storage system separate from player inventory. The player can move items between inventory and chest storage.
```

### Add Save System

```text
Add a local save/load system that saves player position, health, inventory, chest contents, and farming plot states.
```

### Prepare For Multiplayer Later

```text
Review the current architecture and suggest changes needed to make the project easier to convert into multiplayer later. Do not implement networking yet.
```

---

## Definition Of Done For First Prototype

The first prototype is done when:

* The player can move around a small 3D map
* The player can enter and exit their house
* The player can open inventory
* The player can plant a seed
* The crop grows
* The crop can be harvested
* The harvested item enters inventory
* The player can cook food
* The food heals the player
* The player can store items in a chest
* The game can save and load progress

Only after this, start multiplayer.

---

## Long-Term Vision

The long-term version may include:

* Online town hub
* Player houses
* Farming zones
* Crafting
* Cooking
* Gathering
* Fishing
* Animals
* NPC shops
* Player trading
* Small dungeons
* Seasonal events
* Character customization
* Clothing/closet system
* Decorations
* Guilds much later

But the first version must stay small.

---

## Final Instruction

Always protect the scope.

The goal is not to build the biggest MMORPG.

The goal is to build a small, personal, playable online RPG that can grow over time.
