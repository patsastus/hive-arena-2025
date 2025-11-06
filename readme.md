# Hive Arena 2025

A friendly AI competition for the Hive students!

## Running the arena

- Install the Go compiler (for instance `brew install go` on MacOS, or `apt install golang-go` or `snap install go` on Ubuntu, or follow instructions from the official website).
- Run `go run ./server`. Optionally add the `-p <port>` option to select which port should the server listen on.

## Developing agents

Example agents are provided in Lua, Go and Python. These templates abstract the network communication and let you implement a simple callback that receives the current game state, and expects a list of commands to play for the turn.

See readme files in each directory.

## License

The Hive Arena source code is Copyright (c) Hive Helsinki 2025, and released under the MIT License
