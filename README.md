[![Donate](https://img.shields.io/badge/Donate-PayPal-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TSTEG3PXK4HJ4&source=url)

# Fromage API
**Atelier801's Forum API written in Lua (5.1▲) using the Luvit runtime environment**

## About

The [Atelier801's Forum](https://atelier801.com/forums) is a forum created by the french company [Atelier801](http://societe.atelier801.com/) for players from [Transformice](https://www.transformice.com/), an online independent multiplayer free-to-play platform video game, and other smaller projects.

[Luvit](https://luvit.io/) is an open-source, asynchronous I/O Lua runtime environment that makes HTTP requests possible for the Lua programming language.

**Fromage API** is a [documented RESTful API](docs) that allows developers to make bots for the mentioned forum.

Join the **_[Fifty Shades of Lua](https://discord.gg/quch83R)_** [discord](https://discordapp.com/) to discuss about this library and to have a special support.

## Installation

- To install Luvit, visit https://luvit.io and follow the instructions provided for your platform.
	- If you have problems installing it on Windows, please use [Get-Lit](https://github.com/SinisterRectus/get-lit)
- To install **Fromage**, run `lit install Lautenschlager-id/fromage`
- Run your bot script using, for example, `luvit bot.lua`

## Base example

```Lua
local api = require("fromage")
local client = api()

coroutine.wrap(function()
	client.connect("Test#0000", "12345")

	if client.isConnected() then
		-- TODO
	end

	client.disconnect()
	os.execute("pause >nul")
end)()
```