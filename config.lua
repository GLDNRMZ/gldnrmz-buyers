Config = {}

Config.BankScript = 'Renewed-Banking' -- Options: 'Renewed-Banking', 'qb-management', 'okokBanking', 'esx_banking', 'custom'

Config.Shops = {
    ['drugdealer'] = {
        label = "Drug Dealer",
        model = 'cs_manuel',
        pedScenario = "WORLD_HUMAN_AA_SMOKE",
        randomizeLocations = true,
        locations = {
            vector4(-314.55, -1650.65, 30.85, 296.58),
            vector4(255.33, -1607.81, 30.52, 257.31),
            vector4(341.42, -1270.68, 31.09, 91.95),
            vector4(-156.28, -670.97, 33.5, 342.29),
            vector4(76.99, -871.88, 30.51, 56.77),
            vector4(-676.25, -995.57, 16.94, 230.28),
            vector4(-43.74, -1248.33, 28.34, 254.19),
            vector4(360.78, -1233.7, 31.51, 69.67),
            vector4(1004.5, -1573.01, 29.81, 6.29),
            vector4(871.63, -158.14, 77.34, 196.98),
            vector4(179.05, 293.17, 106.37, 336.12),
            vector4(-1518.39, 406.2, 106.88, 224.41),
            vector4(-1981.62, 203.78, 85.6, 136.78),
            vector4(-1952.47, -278.09, 40.97, 82.27),
            vector4(-1945.94, -547.59, 13.73, 132.09),
            vector4(-1477.58, -677.67, 28.04, 114.52),
            vector4(-787.36, -912.13, 17.09, 269.44),
            vector4(140.47, -286.61, 49.45, 32.48),
            vector4(262.42, 750.58, 198.7, 23.5),
            vector4(20.59, 338.08, 110.49, 125.43),
        },
        timeRestricted = true,
        open = 20,
        close = 7,
        restrictedJobs = { ['police'] = true },
        progress = {
            duration = 200000,
            label = 'Negotiating Price..',
        },
        animation = {
            dict = "amb@world_human_stand_guard@male@idle_a",
            anim = "idle_a",
        },
        blip = {
            enabled = false,
            sprite = 431,
            color = 5,
            scale = 0.8,
            label = "Pawn Shop"
        },
        dispatch = {
            enabled = true,
            chance = 90,
            call = function()
                exports.tk_dispatch:addCall({ 
                    title = 'Solicitation', 
                    code = '10-82', 
                    priority = 'Priority 2', 
                    coords = GetEntityCoords(PlayerPedId()), 
                    showLocation = true, 
                    showGender = true, 
                    playSound = true, 
                    blip = { color = 8, sprite = 279, scale = 1.0 }, 
                    jobs = {'police'}, 
                })
            end
        },
        items = {
            ['cokebaggy']       = { price = { min = 100, max = 140 }, label = 'Bag of Coke' },
            ['crack_baggy']     = { price = { min = 80, max = 120 }, label = 'Bag of Crack' },
            ['xtcbaggy']        = { price = { min = 60, max = 90 },  label = 'Bag of XTC' },
            ['oxy']             = { price = { min = 120, max = 150 }, label = 'Oxycodone' },
            ['meth_bag']        = { price = { min = 130, max = 170 }, label = 'Bag of Meth' },
            ['peyote']          = { price = { min = 80, max = 120 }, label = 'Peyote' },
            ['magicmushroom']   = { price = { min = 80, max = 120 }, label = 'Magic Mushroom' },
            ['coke_pure']       = { price = { min = 130, max = 170 }, label = 'Pure Coke' },
            ['heroin']          = { price = { min = 80, max = 120 }, label = 'Heroin' },
            ['weed_whitewidow'] = { price = { min = 80, max = 120 }, label = 'White Widow' },
            ['weed_skunk']      = { price = { min = 80, max = 120 }, label = 'Skunk' },
            ['weed_purplehaze'] = { price = { min = 80, max = 120 }, label = 'Purple Haze' },
            ['weed_ogkush']     = { price = { min = 80, max = 120 }, label = 'OG Kush' },
            ['weed_amnesia']    = { price = { min = 80, max = 120 }, label = 'Amnesia Haze' },
            ['weed_ak47']       = { price = { min = 80, max = 120 }, label = 'AK-47 Weed' },
        }
    },
    
    ['pawnshop'] = {
        label = "Pawn Shop",
        model = 'a_m_m_paparazzi_01',
        pedScenario = "WORLD_HUMAN_STAND_IMPATIENT",
        randomizeLocations = false,
        locations = {
            vec4(-1457.73, -401.52, 34.84, 210.67),
        },
  
        timeRestricted = false,      
        open = 8,
        close = 20,
        restrictedJobs = {},
        progress = {
            duration = 7000,
            label = 'Appraising Items..',
        },

        animation = {
            dict = "amb@world_human_stand_guard@male@idle_a",
            anim = "idle_a",
        },

        blip = {
            enabled = true,
            sprite = 431,
            color = 5,
            scale = 0.8,
            label = "Pawn Shop"
        },

        dispatch = {
            enabled = false,
            chance = 0,
            call = function() end
        },

        society = {
            enabled = true,
            account = "pawn", -- The society account name (must exist in your banking system)
            percent = 10,       -- 10% goes to society, 90% goes to player
        },

        items = {
            ['goldchain']                 = { price = { min = 350, max = 350 }, label = 'Gold Chain' },
            ['gold_ring']                 = { price = { min = 250, max = 250 }, label = 'Gold Ring' },
            ['diamond_ring']              = { price = { min = 800, max = 800 }, label = 'Diamond Ring' },
            ['ruby_ring']                 = { price = { min = 450, max = 450 }, label = 'Ruby Ring' },
            ['sapphire_ring']             = { price = { min = 500, max = 500 }, label = 'Sapphire Ring' },
            ['emerald_ring']              = { price = { min = 600, max = 600 }, label = 'Emerald Ring' },
            ['silver_ring']               = { price = { min = 50, max = 50 }, label = 'Silver Ring' },
            ['diamond_ring_silver']       = { price = { min = 550, max = 550 }, label = 'Silver Diamond Ring' },
            ['ruby_ring_silver']          = { price = { min = 250, max = 250 }, label = 'Silver Ruby Ring' },
            ['sapphire_ring_silver']      = { price = { min = 300, max = 300 }, label = 'Silver Sapphire Ring' },
            ['emerald_ring_silver']       = { price = { min = 400, max = 400 }, label = 'Silver Emerald Ring' },

            ['diamond_necklace']          = { price = { min = 900, max = 900 }, label = 'Diamond Necklace' },
            ['ruby_necklace']             = { price = { min = 500, max = 500 }, label = 'Ruby Necklace' },
            ['sapphire_necklace']         = { price = { min = 550, max = 550 }, label = 'Sapphire Necklace' },
            ['emerald_necklace']          = { price = { min = 650, max = 650 }, label = 'Emerald Necklace' },
            ['silverchain']               = { price = { min = 60, max = 60 }, label = 'Silver Chain' },
            ['diamond_necklace_silver']   = { price = { min = 600, max = 600 }, label = 'Silver Diamond Necklace' },
            ['ruby_necklace_silver']      = { price = { min = 300, max = 300 }, label = 'Silver Ruby Necklace' },
            ['sapphire_necklace_silver']  = { price = { min = 350, max = 350 }, label = 'Silver Sapphire Necklace' },
            ['emerald_necklace_silver']   = { price = { min = 450, max = 450 }, label = 'Silver Emerald Necklace' },

            ['goldearring']               = { price = { min = 200, max = 200 }, label = 'Gold Earring' },
            ['diamond_earring']           = { price = { min = 700, max = 700 }, label = 'Diamond Earring' },
            ['ruby_earring']              = { price = { min = 350, max = 350 }, label = 'Ruby Earring' },
            ['sapphire_earring']          = { price = { min = 400, max = 400 }, label = 'Sapphire Earring' },
            ['emerald_earring']           = { price = { min = 500, max = 500 }, label = 'Emerald Earring' },
            ['silverearring']             = { price = { min = 40, max = 40 }, label = 'Silver Earring' },
            ['diamond_earring_silver']    = { price = { min = 450, max = 450 }, label = 'Silver Diamond Earring' },
            ['ruby_earring_silver']       = { price = { min = 200, max = 200 }, label = 'Silver Ruby Earring' },
            ['sapphire_earring_silver']   = { price = { min = 250, max = 250 }, label = 'Silver Sapphire Earring' },
            ['emerald_earring_silver']    = { price = { min = 350, max = 350 }, label = 'Silver Emerald Earring' },

            ['10kgoldchain']              = { price = { min = 400, max = 400 }, label = '10k Gold Chain' },
            ['rolex']                     = { price = { min = 1500, max = 1500 }, label = 'Golden Watch' },

            ['carradio']                  = { price = { min = 40, max = 40 }, label = 'Car Radio' },
            ['yphone']                    = { price = { min = 30, max = 30 }, label = 'Phone' },
            ['laptop']                    = { price = { min = 250, max = 250 }, label = 'Laptop' },
            ['printer']                   = { price = { min = 250, max = 250 }, label = 'Printer' },
            ['painting']                  = { price = { min = 800, max = 800 }, label = 'Painting' },
            ['harddrive']                 = { price = { min = 50, max = 50 }, label = 'Hard Drive' },

            ['dj_gun_chain']              = { price = { min = 300, max = 300 }, label = 'Gun Chain' },
            ['dj_vagos_chain']            = { price = { min = 300, max = 300 }, label = 'Vagos Chain' },
            ['dj_cuban_chain']            = { price = { min = 300, max = 300 }, label = 'Cuban Chain' },
            ['dj_dollar_chain']           = { price = { min = 300, max = 300 }, label = 'Dollar Chain' },
            ['dj_diamond_ring']           = { price = { min = 800, max = 800 }, label = 'Diamond Ring' },
            ['dj_lion_ring']              = { price = { min = 350, max = 350 }, label = 'Lion Ring' },
            ['dj_king_ring']              = { price = { min = 350, max = 350 }, label = 'King Ring' },
            ['dj_skull_ring']             = { price = { min = 350, max = 350 }, label = 'Skull Ring' },
            ['dj_plat_earings']           = { price = { min = 450, max = 450 }, label = 'Platinum Earrings' },
            ['dj_gold_earings']           = { price = { min = 250, max = 250 }, label = 'Gold Earrings' },

            ['WEAPON_GOLFCLUB']            = { price = { min = 80, max = 80 }, label = 'Golf Club' },
            ['WEAPON_WRENCH']              = { price = { min = 50, max = 50 }, label = 'Wrench' },
            ['WEAPON_POOLCUE']             = { price = { min = 50, max = 50 }, label = 'Pool Cue' },

            ['diamond']                   = { price = { min = 2500, max = 2500 }, label = 'Uncut Diamond' },
            ['goldbar']                   = { price = { min = 3500, max = 3500 }, label = 'Gold Bar' },

            ['iphone']                    = { price = { min = 120, max = 120 }, label = 'iFruit Phone' },
            ['samsungphone']              = { price = { min = 100, max = 100 }, label = 'Hamsung Phone' },
            ['microwave']                 = { price = { min = 60, max = 60 }, label = 'Microwave' },
            ['coffemach']                 = { price = { min = 70, max = 70 }, label = 'Coffee Machine' },

            ['golfclubs']                 = { price = { min = 100, max = 100 }, label = 'Golf Clubs' },
            ['boombox']                   = { price = { min = 120, max = 120 }, label = 'Boombox' },
            ['acousticguitar']            = { price = { min = 150, max = 150 }, label = 'Acoustic Guitar' },
            ['electricguitar']            = { price = { min = 200, max = 200 }, label = 'Electric Guitar' },
            ['computer']                  = { price = { min = 500, max = 500 }, label = 'Gaming PC' },
            ['speakersystem']             = { price = { min = 150, max = 150 }, label = 'Speaker System' },
            ['plugstation']               = { price = { min = 300, max = 300 }, label = 'Plugstation 9' },
            ['gamebox']                   = { price = { min = 250, max = 250 }, label = 'Game Box 1XYZ' },
            ['bintenbo']                  = { price = { min = 200, max = 200 }, label = 'Bintenbo Fitch' },

        }
    },

    ['meatgrinder'] = {
        label = "Meat Grinder Shop",
        model = 's_m_m_linecook',
        pedScenario = "WORLD_HUMAN_CLIPBOARD",
        randomizeLocations = false,
        locations = {
            vec4(1709.37, 4728.19, 41.16, 128.95),
        },

        timeRestricted = false,
        open = 0,
        close = 24,

        restrictedJobs = {},

        progress = {
            duration = 7000,
            label = 'Weighing Meats..',
        },

        animation = {
            dict = "amb@world_human_stand_guard@male@idle_a",
            anim = "idle_a",
        },

        blip = {
            enabled = true,
            sprite = 141,
            color = 49,
            scale = 0.8,
            label = "Meat Grinder Shop"
        },

        dispatch = {
            enabled = false,
            chance = 0,
            call = function() end
        },

        items = {
            ['carcass']            = { price = { min = 135, max = 135 }, label = 'Carcass' },
            ['carcass2']           = { price = { min = 150, max = 150 }, label = 'Carcass 2' },
            ['carcass3']           = { price = { min = 170, max = 170 }, label = 'Carcass 3' },
            ['redcarcass']         = { price = { min = 220, max = 220 }, label = 'Red Carcass' },
            ['redcarcass2']        = { price = { min = 250, max = 250 }, label = 'Red Carcass 2' },
            ['redcarcass3']        = { price = { min = 280, max = 280 }, label = 'Red Carcass 3' },
            ['deerhide']           = { price = { min = 50, max = 50 }, label = 'Deer Hide' },
            ['antlers']            = { price = { min = 420, max = 420 }, label = 'Antlers' },
            ['mtlionpelt']         = { price = { min = 490, max = 490 }, label = 'Mt Lion Pelt' },
            ['mtlionfang']         = { price = { min = 510, max = 510 }, label = 'Mt Lion Fang' },
            ['coyotepelt']         = { price = { min = 210, max = 210 }, label = 'Coyote Pelt' },
            ['boarmeat']           = { price = { min = 220, max = 220 }, label = 'Boar Meat' },
            ['catfur']             = { price = { min = 40, max = 40 }, label = 'Cat Fur' },
            ['hawkfeathers']       = { price = { min = 70, max = 70 }, label = 'Hawk Feathers' },
            ['chimpfur']           = { price = { min = 90, max = 90 }, label = 'Chimp Fur' },
            ['choppelt']           = { price = { min = 100, max = 100 }, label = 'Chop Pelt' },
            ['cormorantfeathers']  = { price = { min = 80, max = 80 }, label = 'Cormorant Feathers' },
            ['cowhide']            = { price = { min = 60, max = 60 }, label = 'Cow Hide' },
            ['crowfeathers']       = { price = { min = 50, max = 50 }, label = 'Crow Feathers' },
            ['henfeathers']        = { price = { min = 35, max = 35 }, label = 'Hen Feathers' },
            ['huskyfur']           = { price = { min = 95, max = 95 }, label = 'Husky Fur' },
            ['porkbelly']          = { price = { min = 55, max = 55 }, label = 'Pork Belly' },
            ['pigeonfeathers']     = { price = { min = 45, max = 45 }, label = 'Pigeon Feathers' },
            ['poodlefur']          = { price = { min = 60, max = 60 }, label = 'Poodle Fur' },
            ['pugfur']             = { price = { min = 65, max = 65 }, label = 'Pug Fur' },
            ['rabbitfoot']         = { price = { min = 20, max = 20 }, label = 'Rabbit Foot' },
            ['rat']                = { price = { min = 10, max = 10 }, label = 'Rat' },
            ['retrieverpelt']      = { price = { min = 70, max = 70 }, label = 'Retriever Pelt' },
            ['rhesusfur']          = { price = { min = 85, max = 85 }, label = 'Rhesus Fur' },
            ['rottweilerpelt']     = { price = { min = 100, max = 100 }, label = 'Rottweiler Pelt' },
            ['seagullfeathers']    = { price = { min = 40, max = 40 }, label = 'Seagull Feathers' },
            ['westyfur']           = { price = { min = 60, max = 60 }, label = 'Westy Fur' },
            ['bobcatpelt']         = { price = { min = 180, max = 180 }, label = 'Bobcat Pelt' },
            ['bearpelt']           = { price = { min = 350, max = 350 }, label = 'Bear Pelt' },
            ['crocodileskin']      = { price = { min = 300, max = 300 }, label = 'Crocodile Skin' },
            ['donkeyhide']         = { price = { min = 70, max = 70 }, label = 'Donkey Hide' },
            ['eaglefeathers']      = { price = { min = 100, max = 100 }, label = 'Eagle Feathers' },
            ['ivory']              = { price = { min = 600, max = 600 }, label = 'Ivory' },
            ['falconfeathers']     = { price = { min = 90, max = 90 }, label = 'Falcon Feathers' },
            ['horsehide']          = { price = { min = 80, max = 80 }, label = 'Horse Hide' },
            ['sharkteeth']         = { price = { min = 150, max = 150 }, label = 'Shark Teeth' },
            ['leopardpelt']        = { price = { min = 250, max = 250 }, label = 'Leopard Pelt' },
            ['macawfeathers']      = { price = { min = 60, max = 60 }, label = 'Macaw Feathers' },
            ['lionmane']           = { price = { min = 300, max = 300 }, label = 'Lion Mane' },
            ['owlfeathers']        = { price = { min = 50, max = 50 }, label = 'Owl Feathers' },
            ['parrotfeathers']     = { price = { min = 65, max = 65 }, label = 'Parrot Feathers' },
            ['redpandafur']        = { price = { min = 120, max = 120 }, label = 'Red Panda Fur' },
            ['skunkfur']           = { price = { min = 55, max = 55 }, label = 'Skunk Fur' },
            ['sparrowfeathers']    = { price = { min = 30, max = 30 }, label = 'Sparrow Feathers' },
            ['tigersharkteeth']    = { price = { min = 200, max = 200 }, label = 'Tiger Shark Teeth' },
            ['vulturefeathers']    = { price = { min = 45, max = 45 }, label = 'Vulture Feathers' },
            ['warblerfeathers']    = { price = { min = 35, max = 35 }, label = 'Warbler Feathers' },
            ['wolfpelt']           = { price = { min = 140, max = 140 }, label = 'Wolf Pelt' },
            ['younghorsehide']     = { price = { min = 75, max = 75 }, label = 'Young Horse Hide' },
        }
    },

    ['rxbuyer'] = {
        label = "Rx Buyer",
        model = 'G_M_M_Fooliganz_01',
        pedScenario = "WORLD_HUMAN_SEAT_WALL",
        randomizeLocations = false,
        locations = {
            vec4(-177.52, 6392.94, 30.16, 191.48),
            vec4(807.35, -2397.51, 22.27, 330.21),
        },

        timeRestricted = false,
        open = 0,
        close = 24,

        restrictedJobs = {},

        progress = {
            duration = 7000,
            label = 'Counting Pills..',
        },

        animation = {
            dict = "amb@world_human_stand_guard@male@idle_a",
            anim = "idle_a",
        },

        blip = {
            enabled = false,
            sprite = 434,
            color = 2,
            scale = 0.8,
            label = "Sell Fish"
        },

        dispatch = {
            enabled = false,
            chance = 0,
            call = function() end
        },

        items = {
            ['ecstasy1']    = { price = { min = 50, max = 50 }, label = 'Ecstasy Orange' },
            ['ecstasy2']    = { price = { min = 50, max = 50 }, label = 'Ecstasy Yellow' },
            ['ecstasy3']    = { price = { min = 50, max = 50 }, label = 'Ecstasy Purple' },
            ['ecstasy4']    = { price = { min = 50, max = 50 }, label = 'Ecstasy Green' },
            ['ecstasy5']    = { price = { min = 50, max = 50 }, label = 'Ecstasy Red' },
            ['xanaxpack']   = { price = { min = 1000, max = 1000 }, label = 'Xanax Pack' },
            ['xanaxplate']  = { price = { min = 500, max = 500 }, label = 'Xanax Plate' },
            ['xanaxpill']   = { price = { min = 50, max = 50 }, label = 'Xanax Pill' },
        }
    },

    ['fishbuyer'] = {
        label = "Fish Buyer",
        model = 'a_m_m_farmer_01',
        pedScenario = "WORLD_HUMAN_CLIPBOARD",
        randomizeLocations = false,
        locations = {
            vec4(-1600.84, 5196.16, 3.36, 289.31),   -- Paleto pier-ish
            --vec4(-1817.45, -1193.25, 14.30, 320.0) -- Vespucci beach / docks
        },

        timeRestricted = false,
        open = 0,
        close = 24,

        restrictedJobs = {},

        progress = {
            duration = 5000,
            label = 'Appraising Catches..',
        },

        animation = {
            dict = "mp_common",
            anim = "givetake1_a",
        },

        blip = {
            enabled = false,
            sprite = 356, -- Fish hook-ish (change if you want)
            color = 3,
            scale = 0.8,
            label = "Fish Buyer"
        },

        dispatch = {
            enabled = false,
            chance = 0,
            call = function() end
        },

        items = {
            -- 🐟 Fish
            ['fish']            = { price = { min = 100, max = 125 }, label = 'Fish' },
            ['stripedbass']     = { price = { min = 100, max = 125 }, label = 'Striped Bass' },
            ['bluefish']        = { price = { min = 135, max = 160 }, label = 'Bluefish' },
            ['redfish']         = { price = { min = 200, max = 225 }, label = 'Redfish' },
            ['goldfish']        = { price = { min = 200, max = 225 }, label = 'Goldfish' },
            ['largemouthbass']  = { price = { min = 300, max = 320 }, label = 'Largemouth Bass' },
            ['swordfish']       = { price = { min = 300, max = 320 }, label = 'Swordfish' },
            ['salmon']          = { price = { min = 300, max = 320 }, label = 'Salmon' },
            ['eelfish']         = { price = { min = 300, max = 320 }, label = 'Eel' },
            ['catfish']         = { price = { min = 300, max = 320 }, label = 'Catfish' },
            ['rainbowtrout']    = { price = { min = 630, max = 660 }, label = 'Rainbow Trout' },
            ['tigershark']      = { price = { min = 630, max = 660 }, label = 'Tiger Shark' },
            ['stingraymeat']    = { price = { min = 700, max = 720 }, label = 'Stingray Meat' },
            ['tunafish']        = { price = { min = 705, max = 720 }, label = 'Tuna' },
            ['killerwhale']     = { price = { min = 730, max = 750 }, label = 'Killer Whale' },
            ['anglerfish']      = { price = { min = 730, max = 750 }, label = 'Anglerfish' },
            ['fishinghalibut']  = { price = { min = 730, max = 750 }, label = 'Halibut' },
            ['flyfish']         = { price = { min = 730, max = 750 }, label = 'Flyfish' },
            ['kingsalmon']      = { price = { min = 730, max = 750 }, label = 'King Salmon' },
            ['mahimahi']        = { price = { min = 730, max = 750 }, label = 'Mahi Mahi' },
            ['oceansturgeon']   = { price = { min = 730, max = 750 }, label = 'Ocean Sturgeon' },
            ['rockfish']        = { price = { min = 730, max = 750 }, label = 'Rockfish' },
            ['sockeyesalmon']   = { price = { min = 730, max = 750 }, label = 'Sockeye Salmon' },
            ['tarponfish']      = { price = { min = 730, max = 750 }, label = 'Tarpon' },

            -- 🦀 Crabs
            ['crawfish']        = { price = { min = 90, max = 110 }, label = 'Crawfish' },
            ['bluecrab']        = { price = { min = 115, max = 130 }, label = 'Blue Crab' },
            ['rockcrab']        = { price = { min = 140, max = 160 }, label = 'Rock Crab' },
            ['dungenesscrab']   = { price = { min = 160, max = 185 }, label = 'Dungeness Crab' },
            ['redcrab']         = { price = { min = 190, max = 215 }, label = 'Red Crab' },
            ['snowcrab']        = { price = { min = 230, max = 260 }, label = 'Snow Crab' },
            ['cookedcrab']      = { price = { min = 350, max = 400 }, label = 'Cooked Crab' },

            -- 💎 Gems
            ['diamond']         = { price = { min = 1000, max = 3000 }, label = 'Diamond' },
            ['emerald']         = { price = { min = 1000, max = 3000 }, label = 'Emerald' },
            ['sapphire']        = { price = { min = 1000, max = 3000 }, label = 'Sapphire' },
            ['ruby']            = { price = { min = 1000, max = 3000 }, label = 'Ruby' },
            ['yellowdiamond']   = { price = { min = 1000, max = 3000 }, label = 'Yellow Diamond' },
            ['captainskull']    = { price = { min = 4000, max = 10000 }, label = "Captain's Skull" },
        }
    },

}
