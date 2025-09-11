package main

import (
	"fmt"
	"hive-arena/agent"
	"os"
	"strconv"
)

func think(state *agent.GameState) []agent.Order {
	orders := make([]agent.Order, 0)

	return orders
}

func main() {
	if len(os.Args) <= 3 {
		fmt.Println("Usage: ./agent <host> <gameid> <name>")
		os.Exit(1)
	}

	host := os.Args[1]
	idStr, _ := strconv.Atoi(os.Args[2])
	id := uint(idStr)
	name := os.Args[3]

	agent.Run(host, id, name, think)
}
