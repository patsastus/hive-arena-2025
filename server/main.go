package main

import (
	"flag"
	"fmt"
	"runtime/debug"
)

func GitRevision() string {
	buildInfo, _ := debug.ReadBuildInfo()
	for _, info := range buildInfo.Settings {
		if info.Key == "vcs.revision" {
			return info.Value
		}
	}

	return ""
}

func main() {
	port := flag.Int("p", 8000, "port on which the server will listen")
	flag.Parse()

	fmt.Println("git revision: " + GitRevision())
	RunServer(*port)
}
