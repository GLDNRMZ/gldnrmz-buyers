# gldnrmz-buyers

Flexible, optimized buyer and shop system for FiveM. Designed for server owners and developers to easily configure multiple buyer types, locations, and item sales. Supports standalone and framework-based environments.

---

## ✨ Features
- Multiple buyer/shop types: drugs, pawn, meat, fish, Rx, etc.
- Highly configurable locations, items, and prices
- Time-restricted and job-restricted shops
- Society commission support for shops
- Randomized or fixed ped locations
- Blip and dispatch integration (optional)
- Progress bars, animations, and context menus
- Optimized for performance and security
- Supports ox_lib, community_bridge, and custom banking
- No hard dependency on any framework

---

## 📦 Requirements
| Dependency         | Required | Link |
|-------------------|----------|------|
| ox_lib            | Yes      | [overextended/ox_lib](https://github.com/overextended/ox_lib) |
| community_bridge  | Yes      | [community_bridge](https://github.com/TheOrderFivem/community_bridge/releases) |
| Banking Script    | Yes      | (Configurable: Renewed-Banking, qb-management, okokBanking, esx_banking, custom) |
| Target System     | Yes      | (community_bridge Target) |
| Inventory System  | Yes      | (community_bridge Inventory) |

---

## ⚡ Installation
1. Download or clone this repository into your resources folder.
2. Ensure `ox_lib` and `community_bridge` are installed and started before this resource.
3. Add to your `server.cfg`:
   ```
   ensure ox_lib
   ensure community_bridge
   ensure gldnrmz-buyers
   ```
   - If using a banking script, ensure it starts before gldnrmz-buyers.
4. Edit `config.lua` to match your server setup and preferences.

---

## ⚙️ Configuration
All configuration is handled in `config.lua`.

Example: Adding a new shop
```lua
Config.Shops["pawnshop"] = {
    label = "Pawn Shop",
    model = 'a_m_m_paparazzi_01',
    pedScenario = "WORLD_HUMAN_STAND_IMPATIENT",
    locations = { vec4(-1457.73, -401.52, 34.84, 210.67) },
    timeRestricted = false,
    open = 8,
    close = 20,
    society = { enabled = true, account = "pawn", percent = 10 },
    items = {
        ['goldchain'] = { price = { min = 350, max = 350 }, label = 'Gold Chain' },
        ['diamond_ring'] = { price = { min = 800, max = 800 }, label = 'Diamond Ring' },
    }
}
```

- **BankScript**: Set your banking system (`Renewed-Banking`, `qb-management`, etc.)
- **Shops**: Define buyers, locations, items, restrictions, blips, and more
- **Society**: Enable/disable commission and set account/percent
- **Items**: Set price ranges and labels for each item

---

## 📘 Advanced Documentation
### Shop Config Fields
| Field           | Type      | Description |
|-----------------|-----------|-------------|
| label           | string    | Display name for shop |
| model           | string    | Ped model name |
| pedScenario     | string    | Ped scenario animation |
| locations       | table     | Array of vec4 locations |
| timeRestricted  | bool      | If true, shop only open between `open` and `close` |
| open/close      | int       | Hours (0-24) shop opens/closes |
| restrictedJobs  | table     | Jobs blocked from using shop |
| progress        | table     | Progress bar config |
| animation       | table     | Animation dict/anim |
| blip            | table     | Blip config (enabled, sprite, color, scale, label) |
| dispatch        | table     | Dispatch config (enabled, chance, call) |
| society         | table     | Society commission config |
| items           | table     | Items and price config |

### Blip & Icon Reference
- [GTA V Blip List](https://docs.fivem.net/docs/game-references/blips/)
- Icons: FontAwesome, ox_lib context

### Global Settings
| Setting           | Default | Description |
|-------------------|---------|-------------|
| MaxSellDistance   | 10.0    | Max distance (m) from the buyer, checked server-side |
| SpawnDistance     | 75.0    | Peds only spawn while a player is within this range |
| QuoteTimeout      | 120     | Seconds a negotiated price list stays valid |
| RelocateMinutes   | 60      | How often `randomizeLocations` buyers move (0 = restart only) |
| Logging           | true    | Logs sales via ox_lib `lib.logger` |

`dispatch.call(shopId, coords)` runs on the seller's client; errors are caught.

### Validation & Safety
The sale is a three-step server-authoritative flow:
1. **startNegotiation** — server checks restricted jobs and distance, then starts a timer.
2. **getQuote** — rejected if the progress duration hasn't actually elapsed; prices are rolled and locked in.
3. **sell** — only quoted items, only while near the buyer, before the quote expires, rate-limited. Items are removed before payment.

Randomized buyer locations are chosen by the server and synced to all players via GlobalState, so everyone sees the dealer in the same spot.

> Opening hours (`timeRestricted`) are enforced on the client only — the server has no game clock.

---

## ❗ Troubleshooting
| Issue                        | Cause/Notes                          | Solution |
|------------------------------|--------------------------------------|----------|
| Shop not spawning            | Missing dependency or config error   | Check ox_lib, community_bridge, config.lua |
| Items not selling            | Item not listed in config            | Add item to shop's `items` table |
| No payment received          | Banking script not configured        | Set `Config.BankScript` and ensure dependency is started |
| Dispatch not triggering      | Dispatch disabled or chance = 0      | Enable in config and set chance > 0 |
| Debugging                    | Use print statements in server/main.lua for validation |

---

## 📄 License / Usage Rules
- **No selling, reselling, or commercial use**
- **Do not remove author credit**
- **Modification allowed for personal/server use only**
- **Do not redistribute as your own work**

---

## 👤 Credit
- Author: GLDNRMZ#8700
- [ox_lib](https://github.com/overextended/ox_lib) by overextended
- [community_bridge](https://github.com/GLDNRMZ/community_bridge) by GLDNRMZ

---

## 📝 License Footer
Attribution required. Redistribution only permitted with original credit and license. Commercial use strictly prohibited.
