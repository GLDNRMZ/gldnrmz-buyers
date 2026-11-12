fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'gldnrmz-buyers'
author 'GLDNRMZ#8700'
description 'Configurable NPC buyers with server-authoritative pricing'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

dependencies {
    '/onesync',
    'ox_lib',
    'community_bridge',
}
