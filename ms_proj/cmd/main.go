package main

import (
	"log"
	"ms_proj/backend/database"

	"ms_proj/backend/routes"

	"github.com/gin-gonic/gin"
)

func main() {
	// Initialize the database connection
	database.InitDB()
	// Create a Gin router instance
	router := gin.Default()

	// Register all application routes
	routes.RegisterRoutes(router)

	// Start the server
	log.Println("Server is running on http://localhost:8080")
	if err := router.Run(":8080"); err != nil {
		log.Fatalf("Failed to start the server: %v", err)
	}
}
