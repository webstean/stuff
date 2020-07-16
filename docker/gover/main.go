package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

var GitCommit string

func webhome(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Server", "A Go Web Server")
	w.WriteHeader(200)
}

type Version struct {
	version       string
	lastcommitsha string
	description   string
}

func webversion(w http.ResponseWriter, r *http.Request) {
	appversion := Version{"1.0", GitCommit, "pre-interview technical test"}

	js, err := json.Marshal(appversion)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(js)
}

func main() {
	fmt.Println("Starting Web Server...")
	http.HandleFunc("/", webhome)
	http.HandleFunc("/version", webversion)
	http.ListenAndServe(":3000", nil)
	fmt.Println("Listening on Port 3000...")
}
