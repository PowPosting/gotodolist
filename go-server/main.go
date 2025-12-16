package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"go-server/router"
)

func main() {
	r := router.Router()
	// fs := http.FileServer(http.Dir("build"))
	// http.Handle("/", fs)
	
	// Get port from environment variable or use 8080 as default
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	
	fmt.Printf("Starting server on port %s...\n", port)

	log.Fatal(http.ListenAndServe(":"+port, r))
}
