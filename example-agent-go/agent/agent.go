package agent

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/gorilla/websocket"
	"io"
	"net/http"
	"os"
	"strings"
	"strconv"
	"errors"
)

func request(url string) string {

	resp, err := http.Get(url)
	if err != nil {
		fmt.Println("Could not get " + url)
		os.Exit(1)
	}
	defer resp.Body.Close()

	bodyBytes, _ := io.ReadAll(resp.Body)
	body := string(bodyBytes)

	if resp.StatusCode != 200 {
		fmt.Println("Error:", body)
		os.Exit(1)
	}

	return body
}

type JoinResponse struct {
	Id    uint
	Token string
}

func joinGame(host string, id uint, name string) JoinResponse {

	url := "http://" + host + fmt.Sprintf("/join?id=%d&name=%s", id, name)
	body := request(url)

	var response JoinResponse
	json.Unmarshal([]byte(body), &response)

	fmt.Printf("Joined game %d as player %d\n", id, response.Id)

	return response
}

type WebSocketMessage struct {
	Turn     uint
	GameOver bool
}

func startWebSocket(host string, id uint) *websocket.Conn {

	url := "ws://" + host + fmt.Sprintf("/ws?id=%d", id)

	ws, _, err := websocket.DefaultDialer.Dial(url, nil)

	if err != nil {
		fmt.Println("Websocket error: ", err)
		os.Exit(1)
	}

	return ws
}

type Coords struct {
	Row int
	Col int
}

func (c Coords) MarshalText() (text []byte, err error) {
	str := fmt.Sprintf("%d,%d", c.Row, c.Col)
	return ([]byte)(str), nil
}

func (c *Coords) UnmarshalText(text []byte) error {
	parts := strings.Split(string(text), ",")

	if len(parts) != 2 {
		return errors.New("Bad coords")
	}

	var err1, err2 error
	c.Row, err1 = strconv.Atoi(parts[0])
	c.Col, err2 = strconv.Atoi(parts[1])

	if err1 != nil { return err1 }
	if err2 != nil { return err2 }

	return nil
}

type Entity struct {
	Type   string
	Hp     uint
	Player uint
}

type Hex struct {
	Terrain   string
	Resources uint
	Influence uint
	Entity    *Entity
}

type GameState struct {
	NumPlayers          uint
	Turn                uint
	Hexes               map[Coords]Hex
	PlayerResources     []uint
	lastInfluenceChange uint
	Winners             map[uint]bool
	GameOver            bool
}

func getState(host string, id uint, token string) GameState {

	url := "http://" + host + fmt.Sprintf("/game?id=%d&token=%s", id, token)
	body := request(url)

	var response GameState
	json.Unmarshal([]byte(body), &response)

	return response
}

type Order struct {
	Type string `json:"type"`
	Coords Coords `json:"coords"`
	Direction string `json:"direction"`
}

func sendOrders(host string, id uint, token string, orders []Order) {
	url := "http://" + host + fmt.Sprintf("/orders?id=%d&token=%s", id, token)
	payload, err := json.Marshal(orders)

	resp, err := http.Post(url, "application/json", bytes.NewReader(payload))
	if err != nil {
		fmt.Println("Could not post to " + url)
		os.Exit(1)
	}
	defer resp.Body.Close()

	bodyBytes, _ := io.ReadAll(resp.Body)
	body := string(bodyBytes)

	if resp.StatusCode != 200 {
		fmt.Println("Error:", body)
		os.Exit(1)
	}
}

func Run(host string, id uint, name string, callback func(*GameState, uint) []Order ) {

	playerInfo := joinGame(host, id, name)
	ws := startWebSocket(host, id)

	for {
		var message WebSocketMessage
		err := ws.ReadJSON(&message)
		if err != nil {
			fmt.Println("Error:", err)
			os.Exit(1)
		}

		if message.GameOver {
			fmt.Println("Game is over")
			break
		} else {
			fmt.Printf("Starting turn %d\n", message.Turn)
		}

		state := getState(host, id, playerInfo.Token)
		orders := callback(&state, playerInfo.Id)

		sendOrders(host, id, playerInfo.Token, orders)
	}
}
