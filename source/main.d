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

	auto pos = Coords(12, 4);
	auto move = new MoveOrder(game, player: 1, pos, Direction.SE);

	auto bee = cast(Bee) game.getEntityAt(pos);

	move.apply();
	writeln(move.status);

	writeln(game);
}
