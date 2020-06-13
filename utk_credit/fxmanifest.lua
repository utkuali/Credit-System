fx_version "adamant"

game "gta5"

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    "server.lua"
}

client_scripts {
    "config.lua",
    "vehtable.lua",
    "client.lua"
}

export "GetCredit"