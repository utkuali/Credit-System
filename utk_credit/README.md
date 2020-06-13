# utk_credit

## Info

This script creates a new currency which you can name it to anything such as bitcoin, credit, coin, gold etc.

Value of credit is up to you. Value of the credit is determined by what you can buy with it. So if you want to make it very valuable you may want to sell a supercar for 10 credit, or if you want to make it more accessible you may want to sell a supercar for 10.000 credit, which makes credit still valuable but also not unreachable. The main purpose of this script is to generate a currency that can't be cloned, hacked, added with Lua executors and thus safely can be given to players. **You can also use client-side and server-side events to harness the full potential of the script, making it more global.**

## Installation

1. Run "credit.sql"

2. Open "config.lua" and edit settings to your liking

3. Edit "vehtable.lua" if you want to add add-on vehicles to the credit shop

## Requirements

- [ESX](https://github.com/ESX-Org/es_extended)

- [esx_menu_default](https://github.com/ESX-Org/esx_menu_default)

- [esx_menu_dialog](https://github.com/ESX-Org/esx_menu_dialog)

- [esx_vehicleshop](https://github.com/ESX-Org/esx_vehicleshop)

- [mythic_notify](https://github.com/mythicrp/mythic_notify)

## Using credit on other resources

- Getting current credit

server-side: ID is source of player

```lua

local xPlayer = ESX.GetPlayerFromId(source)
local credit = MySQL.Sync.fetchAll("SELECT amount FROM credit WHERE identifier = @identifier", {["@identifier"] = xPlayer.identifier})

credit = credit[1].amount -- credit is the currency

```

client-side: No need for id

```lua

local credit = exports["utk_credit"]:GetCredit()

```

- Adding credit (only server-side for security)

```lua

TriggerEvent("utk_c:addcredit", id, amount)

```

- Removing credit (only server-side for security)

```lua

TriggerEvent("utk_c:removecredit", id, amount)

```
