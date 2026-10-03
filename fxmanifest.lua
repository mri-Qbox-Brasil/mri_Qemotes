fx_version 'cerulean'
game 'gta5'

name 'mri_Qemotes'
description 'Menu de emotes da MRI Qbox sobre o rpemotes-reborn'
author 'MRI Qbox Team'
version '1.5.1'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

ox_lib 'locale'

dependencies {
    'ox_lib',
    'rpemotes-reborn',
}

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client/catalog.lua',
    'client/animate.lua',
    'client/preview.lua',
    'client/main.lua',
    'client/compat.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/**/*',
    'locales/*.json',
    'data/emotes.lua',
}
