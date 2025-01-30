fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_scripts {
	'@ox_lib/init.lua',
   'client/client.lua'
}

server_scripts {
   'server/server.lua',
}

shared_scripts {
    'shared/config.lua'
}

dependencies {
    'rsg-core',
    'ox_target',
	'ox_lib'
}

lua54 'yes'