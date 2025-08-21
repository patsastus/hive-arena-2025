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

local function indexMap(state)
	local index = {}
	for _,v in ipairs(state.map) do
		index[v.row .. ":" .. v.col] = v
	end

	for _,v in ipairs(state.entities) do
		index[v.row .. ":" .. v.col].entity = v
	end

	return index
end

local directions = {"NW", "NE", "E", "SE", "SW", "W"}

local function makeOrders(state, player, index)

	local orders = {}

	for _,v in ipairs(state.entities) do
		if v.type == "BEE" and v.player == player then

			local cell = index[v.row .. ":" .. v.col]
			local terrain = cell.type

			local type = "MOVE"
			if terrain == "FIELD" then
				type = "FORAGE"
			elseif cell.influence ~= player and state.resources[player + 1] >= 24 then
				type = "BUILD_HIVE"
			end

			local order = {
				row = v.row,
				col = v.col,
				type = type,
				direction = directions[math.random(1, #directions)]
			}

			table.insert(orders, order)

		elseif v.type == "HIVE" and v.player == player then
			if state.resources[player + 1] >= 12 then

				local order = {
					row = v.row,
					col = v.col,
					type = "SPAWN",
					direction = directions[math.random(1, #directions)]
				}

				table.insert(orders, order)
			end
		end
	end

	return orders
end

local function runGame()
	local state = run("cli/arena_cli --map=map.txt --players=4")

	while not state.gameOver do

		local index = indexMap(state)

		local porders = {}
		for p = 0, state.numPlayers - 1 do
			table.insert(porders, makeOrders(state, p, index))
		end

		print("orders:", #porders)

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
