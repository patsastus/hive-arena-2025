import std.algorithm;
import std.array;
import std.conv;

import terrain;
import order;
import utils;

const INIT_FIELD_FLOWERS = 120;
const INIT_HIVE_HP = 12;
const INIT_BEE_HP = 2;
const INIT_WALL_HP = 6;

class Entity
{
	Coords position;
	uint hp;
}

class Unit : Entity
{
	ubyte player;
}

class Bee : Unit
{
	this(Coords position, ubyte player)
	{
		this.position = position;
		this.player = player;
		this.hp = INIT_BEE_HP;
	}
}

class Hive : Unit
{
	this(Coords position, ubyte player)
	{
		this.position = position;
		this.player = player;
		this.hp = INIT_HIVE_HP;
	}
}

class Wall : Entity
{
	this(Coords position)
	{
		this.position = position;
		this.hp = INIT_WALL_HP;
	}
}

class GameState
{
	ubyte numPlayers;
	const Map hexes;

	uint[] playerFlowers;
	uint[Coords] fieldFlowers;
	Entity[Coords] entities;

	private static const ubyte[][] playerMappings = [
		[],
		[0, 1, 0, 0, 0, 0, 0],
		[0, 1, 0, 0, 2, 0, 0],
		[0, 1, 0, 2, 0, 3, 0],
		[0, 0, 1, 2, 0, 3, 4],
		[0, 1, 2, 3, 4, 5, 0],
		[0, 1, 2, 3, 4, 5, 6]
	];

	this(const Map hexes, const Spawn[] spawns, ubyte numPlayers)
	{
		assert(numPlayers >= 1 && numPlayers <= 6);

		this.numPlayers = numPlayers;
		this.hexes = hexes;

		// Create units for existing players

		foreach(spawn; spawns)
		{
			auto player = playerMappings[numPlayers][spawn.player];
			if (player == 0)
				continue;

			final switch (spawn.kind)
			{
				case Spawn.Kind.HIVE:
					entities[spawn.coords] = new Hive(spawn.coords, player);
					break;

				case Spawn.Kind.BEE:
					entities[spawn.coords] = new Bee(spawn.coords, player);
					break;
			}
		}

		// Prepare flower fields

		foreach(coords, terrain; hexes)
		{
			if (terrain == Terrain.FIELD)
				fieldFlowers[coords] = INIT_FIELD_FLOWERS;
		}

		this.playerFlowers = new uint[numPlayers + 1];
	}

	override string toString()
	{
		import std.format;

		auto res = "";

		auto top = hexes.keys.map!"a.row".minElement;
		auto bottom = hexes.keys.map!"a.row".maxElement;
		auto left = hexes.keys.map!"a.col".minElement;
		auto right = hexes.keys.map!"a.col".maxElement;

		foreach (row; top .. bottom + 1)
		{
			if (row % 2 == 1) res ~= "  ";
			foreach (col; left .. right + 1)
			{
				if (!Coords.valid(row, col)) continue;

				auto coords = Coords(row, col);
				char c1 = ' ';
				char c2 = ' ';
				if (coords in hexes)
				{
					c1 = terrain.terrainToChar(hexes[coords]);
					auto entity = entities.get(coords, null);

					if (auto bee = cast(Bee) entity)
					{
						c1 = 'B';
						c2 = bee.player.to!string[0];
					}
					else if (auto hive = cast(Hive) entity)
					{
						c1 = 'H';
						c2 = hive.player.to!string[0];
					}
					else if (auto wall = cast(Wall) entity)
					{
						c1 = 'W';
					}
				}
				res ~= format("%c%c  ", c1, c2);
			}
			res ~= '\n';
		}

		return res;
	}
}
