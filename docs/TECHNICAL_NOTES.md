# Technical Notes — Cozy Realms Online

## Engine & Configuration
- **Engine:** Godot 4.7
- **Language:** GDScript
- **Physics:** Jolt Physics
- **Renderer:** Forward Plus (D3D12 on Windows)
- **Window stretch:** canvas_items / expand

## Architecture Decisions

### Scene Structure
Each gameplay system gets its own scene folder under `scenes/` and script folder under `scripts/`. This keeps systems modular and makes future multiplayer conversion easier.

### Item/Crop/Recipe Data
Use Godot Resource files (`.tres`) for item definitions, crop definitions, and recipes. This avoids hardcoding data in scripts and makes it easy to add new content.

### Interaction System
All interactable objects will implement a common interface pattern: expose a display name, interaction prompt, and interaction behavior. This keeps the interaction system reusable across doors, chests, farming plots, cooking stations, and NPCs.

### Save System
Local saves use a simple dictionary-to-JSON approach. Save data includes: player position, health, inventory contents, chest contents, crop states, and house state.

## Known Limitations
- Single-player only (multiplayer deferred to Milestone 2)
- No encryption on save files
- Placeholder assets throughout

## Multiplayer Preparation Notes
- Keep game state in centralized managers (inventory, farming, housing) so they can be replaced with networked versions later
- Avoid direct node references across system boundaries — use signals
- Player controller should be structured so movement can be client-predicted later
- Important state (inventory, rewards) must be server-authoritative when networking is added
