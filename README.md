# gldnrmz-buyers

A comprehensive and secure illegal shop/dealer system for QBCore, allowing players to sell specific items to configured NPC buyers.

## Features

- **Flexible Ped Spawning**: Configurable locations with support for randomization (spawn at one random spot) or all locations.
- **Customizable NPCs**: Set models, scenarios, and custom animations (dict/anim) for each dealer.
- **Time Restrictions**: Optional opening hours (e.g., only open at night).
- **Job Restrictions**: Blacklist specific jobs (e.g., police/ambulance) from interacting with dealers.
- **Secure Selling**: 
  - Server-side validation for distance and job checks to prevent exploits.
  - Configurable min/max sell prices per item.
- **Integration**:
  - **ox_target** for interaction.
  - **ox_lib** for progress bars and menus.
  - **Dispatch** support for police alerts on interaction.
  - Map blips with full customization.

## Dependencies

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)

## Installation

1. Download the resource and place it in your resources folder.
2. Add `ensure gldnrmz-buyers` to your `server.cfg`.
3. Configure your shops in `config.lua`.

## Configuration

The `config.lua` file allows you to create multiple dealers with unique behaviors.

### Example Configuration

```lua
Config = {}

Config.Shops = {
    ['exampleshop'] = {
        label = "Example Shop",
        model = 'a_m_m_business_01', -- Ped model
        pedScenario = "WORLD_HUMAN_STAND_MOBILE", -- Ped animation scenario (optional)
        randomizeLocations = false, -- true = spawns at 1 random loc, false = spawns at all locs
        locations = {
            vec4(100.0, 200.0, 30.0, 90.0), -- x, y, z, w (heading)
            vec4(150.0, 250.0, 30.0, 180.0),
        },
        timeRestricted = true, -- Enable opening hours
        open = 8, -- Open at 8 AM
        close = 22, -- Close at 10 PM
        restrictedJobs = { ['police'] = true, ['ambulance'] = true }, -- Jobs that cannot use this shop
        progress = {
            duration = 5000, -- Progress bar duration in ms
            label = 'Negotiating...', -- Progress bar text
        },
        animation = {
            dict = "amb@world_human_stand_guard@male@idle_a", -- Custom animation dictionary
            anim = "idle_a", -- Custom animation name
        },
        blip = {
            enabled = true,
            sprite = 500, 
            color = 2, 
            scale = 0.8, 
            label = "Example Shop"
        },
        dispatch = {
            enabled = true, -- Enable police dispatch on use
            chance = 50, -- % chance to call police
            call = function() 
                -- Add your dispatch export here
                -- Example: exports['ps-dispatch']:SuspiciousActivity()
            end
        },
        society = {
            enabled = true, -- Enable society payments
            account = "police", -- The society account name (must exist in your banking system)
            percent = 10,       -- 10% goes to society, 90% goes to player
        },
        items = {
            ['water'] = { price = { min = 5, max = 10 }, label = 'Water Bottle' }, -- Randomized price
            ['bread'] = { price = 5, label = 'Bread' }, -- Fixed price
        }
    },
}
```

## Security Note

This resource includes server-side validation to ensure players are:
1. Actually near the dealer (prevents remote execution).
2. Not employed in a restricted job (prevents job check bypass).
