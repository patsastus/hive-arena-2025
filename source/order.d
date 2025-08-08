import std.algorithm;

import game;
import terrain;

class Order
{
	enum Status
	{
		PENDING,
		INVALID_UNIT,
		BLOCKED,

		OK
	}

	GameState state;
	const ubyte player;
	const Coords coords;

	Status status;

	this(GameState state, ubyte player, Coords coords)
	{
		this.state = state;
		this.player = player;
		this.coords = coords;
	}

	T getUnit(T : Unit)()
	{
		auto unit = cast(T) state.getEntityAt(coords);
		if (unit is null || unit.player != player)
		{
			status = Status.INVALID_UNIT;
			return null;
		}

		return unit;
	}

	abstract void apply();
}

class TargetOrder : Order
{
	const Direction direction;

	this(GameState state, ubyte player, Coords coords, Direction direction)
	{
		super(state, player, coords);
		this.direction = direction;
	}
}

class MoveOrder : TargetOrder
{
	this(GameState state, ubyte player, Coords coords, Direction direction)
	{
		super(state, player, coords, direction);
	}

	override void apply()
	{
		auto bee = getUnit!Bee();
		if (bee is null) return;

		auto target = coords.neighbour(direction);
		auto targetTerrain = state.getTerrainAt(target);
		auto entity = state.getEntityAt(target);

		if (targetTerrain != Terrain.EMPTY || entity !is null)
		{
			status = Status.BLOCKED;
			return;
		}

		bee.position = target;

		state.entities.remove(coords);
		state.entities[target] = bee;

		status = Status.OK;
	}
}

// class AttackOrder : TargetOrder
// {
// 	this(GameState state)
// 	{
// 		super(state);
// 	}
//
// 	override void apply()
// 	{
// 		auto target = coords.neighbour(direction);
// 		auto targetHex = state.hexes[target];
//
// 		if (targetHex.kind.among(Terrain.BEE, Terrain.HIVE, Terrain.WALL))
// 		{
// 			targetHex.hp--;
// 			if (targetHex.hp <= 0)
// 				targetHex = Hex.init;
//
// 			state.hexes[target] = targetHex;
// 		}
//
// 		status = Status.OK;
// 	}
// }
//
// class ForageOrder : TargetOrder
// {
//
// }
//
// class BuildWallOrder : TargetOrder
// {
//
// }
//
// class HiveOrder : Order
// {
//
// }

// class SpawnOrder : Order
// {
// 	override void checkUnitType(GameState state)
// 	{
// 		if (!state.find!"hive"(coords))
// 			status = Status.INVALID_UNIT;
// 	}
// }
