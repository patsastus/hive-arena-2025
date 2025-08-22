import std.random;
import std.conv;
import std.stdio;

import vibe.vibe;

alias GameID = uint;

class Game
{

}

class Server
{
	Game[GameID] games;

	this(ushort port)
	{
		auto router = new URLRouter;
		router.get("/game", &createGame);

		auto settings = new HTTPServerSettings();
		settings.port = port;

		listenHTTP(settings, router);
	}

	void createGame(HTTPServerRequest req, HTTPServerResponse res)
	{
		auto players = 0;
		if ("players" in req.query)
			players = req.query["players"].to!int;

		if (players < 2 || players > 6)
		{
			res.writeBody("Invalid number of players");
			res.statusCode = HTTPStatus.badRequest;
			return;
		}

		GameID id;
		do { id = uniform!GameID; } while (id in games);

		games[id] = new Game;

		res.writeJsonBody(["id": id]);
	}
}

void main()
{
	auto server = new Server(8000);
	runApplication();

	writeln("Are we there yet?");
}
