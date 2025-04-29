fx_version 'cerulean'
game 'gta5'

author 'Space Store'
description 'space_payments - sistema de pagamentos'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
