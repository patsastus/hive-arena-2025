local json = require "lunajson"

local function runRaw(command, input)
	local path = os.tmpname()
	local fp = io.popen(command .. " > " .. path, "w")
	fp:write(input or "")
	fp:close()

	fp = io.open(path, "r")
	local res = fp:read("a")
	fp:close()

	return res
end

local function run(command, input)
	return json.decode(runRaw(command, input and json.encode(input) or nil))
end

local function printState(s)
	io.write(runRaw("lua etc/gamestate_print.lua", json.encode(s)))
end

local directions = {"NW", "NE", "E", "SE", "SW", "W"}

local function makeOrders(state, player)

	local orders = {}

	for _,v in ipairs(state.entities) do
		if v.type == "BEE" and v.player == player then
			local order = {
				row = v.row,
				col = v.col,
				type = "MOVE",
				direction = directions[math.random(1, #directions)]
			}

			table.insert(orders, order)
		end
	end

	return orders
end

local function runGame()
	local state = run("cli/arena_cli --map=map.txt --players=4")

	while not state.gameOver do
		local porders = {}
		for p = 0, state.numPlayers - 1 do
			table.insert(porders, makeOrders(state, p))
		end

		local payload = {
			gamestate = state,
			orders = porders
		}

		local result = run("cli/arena_cli", payload)

		state = result.gamestate
		printState(state)
	end

end

runGame()
