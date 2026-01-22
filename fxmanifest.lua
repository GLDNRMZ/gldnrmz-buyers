fx_version 'cerulean'

game 'gta5'

version "1.0.0"

author 'GLDNRMZ#8700'

client_scripts {
	"client/main.lua"
}

server_scripts {
	"server/main.lua"
}

shared_scripts {
    '@ox_lib/init.lua',
	"config.lua"
}