package routes

import (
	"ms_proj/backend/controllers"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(router *gin.Engine) {
	// Health check route
	router.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "pong"})
	})

	// Authentication routes
	router.POST("/register", controllers.RegisterUser)
	router.POST("/login", controllers.Login)

}
