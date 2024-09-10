fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'karos7804'
description 'Simple Garage'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}
client_scripts {
    'client/*.lua',
} 
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
} 

files {
    'locales/*.json'
  }