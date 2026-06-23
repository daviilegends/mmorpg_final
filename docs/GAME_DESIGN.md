# Game Design Document — Cozy Realms Online

## Game Concept

Cozy Realms Online is a small 3D low-poly online RPG prototype inspired by classic MMORPGs, cozy farming games, and personal housing systems. The player lives in a peaceful fantasy world where they can own a house, farm crops, cook food, store items, and explore the outdoors.

## Core Loop

```
Explore → Gather/Plant → Harvest → Cook → Heal/Store → Improve Home → Explore Again
```

The game should feel rewarding even without combat.

## Player Goals

- Build and personalize a cozy home
- Grow crops and harvest them
- Cook food to heal and progress
- Explore a small fantasy world
- Store and manage items
- Eventually interact with other players online

## Main Mechanics

### Movement & Exploration
- WASD movement in a 3D low-poly world
- Top-down or slightly angled third-person camera
- Interaction system (Press E) for objects, doors, chests, stations

### Farming
- Plant seeds in soil plots
- Crops grow through stages over time
- Harvest crops into inventory
- Starting crops: Carrot, Potato, Wheat, Berry

### Cooking
- Combine ingredients at a cooking station
- Produce food items that heal the player
- Simple recipes (e.g., Carrot Soup = Carrot + Water)

### Housing
- House exterior and interior
- Enter/exit via door interaction
- Chest storage inside the house
- Future: bed, decorations, closet

### Inventory & Storage
- Resource-based item definitions
- Stackable items with types (seed, crop, food, misc)
- Chest storage separate from player inventory

### Health
- Max health / current health
- Food items heal the player
- No complex combat early on

### Save/Load
- Local save system
- Saves: player position, health, inventory, chest, crops, house state

## Style Direction

- 3D low-poly cozy fantasy
- Soft colors, simple geometry
- Peaceful atmosphere
- No realistic graphics

## Future Ideas

- Online multiplayer town hub
- NPC shops and trading
- Fishing, animals, gathering
- Small dungeons
- Seasonal events
- Character customization
- Guilds (much later)
