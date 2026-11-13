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
| community_bridge **0.13.6+** | Yes | [community_bridge](https://github.com/TheOrderFivem/community_bridge/releases) ([Qbox](https://github.com/Qbox-project/qbx_core), [QBCore](https://github.com/qbcore-framework/qb-core) or [ESX](https://github.com/esx-framework/esx_core)) |
| Target / inventory | Yes      | Any that [community_bridge](https://github.com/TheOrderFivem/community_bridge) supports ([ox_target](https://github.com/overextended/ox_target), [qb-target](https://github.com/qbcore-framework/qb-target), [ox_inventory](https://github.com/overextended/ox_inventory), qb-inventory, ...) |
| Banking script    | Only for society commission | Renewed-Banking, qb-management, okokBanking, esx_banking or custom (`Config.BankScript`) |

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
   - If you use society commission, start your banking script before gldnrmz-buyers.
4. Every item a shop buys must exist in your inventory's item list.
5. Edit `config.lua` to match your server setup and preferences.

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

`dispatch.call(shopId, coords)` runs on the seller's client; errors are caught. The pawn shop's default sends the alert through community_bridge (any supported dispatch); a tk_dispatch version is included as a commented example.

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

## 🆕 Changes in 2.1.0
- The pawn shop's police alert uses community_bridge by default instead of tk_dispatch.

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
- [community_bridge](https://github.com/TheOrderFivem/community_bridge) by The Order

---

## 📝 License Footer
Attribution required. Redistribution only permitted with original credit and license. Commercial use strictly prohibited.

<!-- gldnrmz-links -->
---

## 🔗 Links

<p align="center">
  <a href="https://discord.gg/7YHJ7774jA"><img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord" /></a>
  <a href="https://forum.cfx.re/u/gldnrmz/summary"><img src="https://img.shields.io/badge/Cfx.re-F40552?style=for-the-badge&logoColor=white" alt="Cfx.re forum" /></a>
  <a href="https://5metrics.dev/resources?search=gldnrmz"><img src="https://img.shields.io/badge/5Metrics-00BFFF?style=for-the-badge&logoColor=white" alt="5Metrics" /></a>
  <a href="https://gldnrmz.tebex.io"><img src="https://img.shields.io/badge/Tebex-FFD700?style=for-the-badge&logoColor=black" alt="Tebex store" /></a>
  <a href="https://www.buymeacoffee.com/gldnrmz"><img src="https://img.shields.io/badge/Buy%20me%20a%20coffee-FF813F?style=for-the-badge&logo=buymeacoffee&logoColor=white" alt="Buy me a coffee" /></a>
</p>
