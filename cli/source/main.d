import std.stdio;
import std.json;
import std.getopt;
import std.algorithm;
import std.array;

import game;
import terrain;
import order;
import serialization;

void process(JSONValue data)
{
	auto game = deserializeGameState(data["gamestate"]);

	if (data["orders"].array.length != game.numPlayers)
		throw new Exception("Player count mismatch");

	Order[][] orders;
	foreach(Player p; 0 .. game.numPlayers)
		orders ~= data["orders"][p].array.map!(o => deserializeOrder(o, p, game)).array;

	auto processed = game.processOrders(orders);

	JSONValue result;
	result["gamestate"] = serialize(game);
	result["processed"] = processed.map!(a => serialize(a)).array;

	writeln(result);
}

void main(string[] args)
{
	string mapPath;
	ubyte players;
	string toProcess;

	getopt(args,
		"map", &mapPath,
		"players", &players,
		"process", &toProcess
	);

	if (mapPath.length != 0)
	{
		auto map = loadMap(mapPath);
		auto game = new GameState(map[0], map[1], players);

		writeln(serialize(game));
	}
	else if (toProcess.length != 0)
	{
		import std.file;

		auto txt = readText(toProcess);
		auto data = parseJSON(txt);

		process(data);
	}
	else
	{
		writeln("Usage:");
		writeln(args[0], " --map=<map file> --players=<number of players to spawn>");
		writeln(args[0], " --process=<json formatted game state and orders>");
	}
}
