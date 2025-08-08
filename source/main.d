import std.stdio;
import std.algorithm;
import std.range;

import game;
import terrain;
import order;

void main()
{
	auto map = loadMap("map.txt");
	auto game = new GameState(map[0], map[1], 3);

	writeln(game);
}
