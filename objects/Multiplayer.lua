Multiplayer = {}

-- W.I.P MULTIPLAYER WRAPPER
-- UNTESTED
-- TODO: FINISH UP AND ADD TO GAME STATE

Multiplayer.received_data = {}
Multiplayer.players = {
	[0] = {index = 0}
}

local sock = require "lib.sock"
local GAME_PORT = 5029

local function getPlayerFromIndex(index)
	for k,v in pairs(self.players) do
		if v.index == index then
			return k
		end
	end
end

function Multiplayer:host()
	local server = sock.newServer("*", GAME_PORT)

	server:on("connect", function(data, client)
		local playerTable = {}

		playerTable.index = client:getIndex()

		table.insert(self.players, playerTable)
		server:sendToAll("players_table", self.players)
	end)

	server:on("wrapper_receive", function(data, client)
		if data.sendTo == "all" then
			server:sendToAllBut(client, "wrapper_receive", data)
			table.insert(self.received_data, data.data)
			return
		end

		if data.sendTo == 0 then
			table.insert(self.received_data, data.data)
			return
		end

		if not (data
		and data.sendTo
		and self.players[data.sendTo]) then
			return
		end

		local index = self.players[data.sendTo].index
		local receivingClient = self.server:getClientByIndex(index)

		receivingClient:send("wrapper_receive", {
			name = data.name,
			data = data.data,
			gotFrom = getPlayerFromIndex(client:getIndex())
		})
	end)
end

function Multiplayer:update()
	if self.client then
		self.client:update()
	end
	if self.server then
		self.server:update()
	end
end

function Multiplayer:send(playerNumber, name, data)
	if self.server then
		local player = self.players[playerNumber]
		if not player then return end

		local client = self.server:getClientByIndex(player.index)

		client:send("wrapper_receive", {
			data = data,
			name = name,
			gotFrom = 0
		})
		return
	end
end

function Multiplayer:receive(dataName)
	local receivedData = {}

	for k,v in pairs(Multiplayer.received_data) do
		
	end
end