package controllers

import (
	"ms_proj/backend/database"
	"ms_proj/backend/models"
	"ms_proj/backend/utils"
	"net/http"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

func RegisterUser(c *gin.Context) {
	var user models.User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error hashing password"})
		return
	}
	user.Password = string(hashedPassword)

	// Insert user into DB
	_, err = database.DB.NamedExec(`INSERT INTO users (email, name, phone_number, password, username) 
		VALUES (:email, :name, :phone_number, :password, :username)`, user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "User registered successfully"})
}

func RegisterFarmer(c *gin.Context) {
	var farmer models.Farmer
	if err := c.ShouldBindJSON(&farmer); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Insert farmer into DB
	_, err := database.DB.NamedExec(`INSERT INTO farmer (userid, govid) VALUES (:userid, :govid)`, farmer)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create farmer"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Farmer registered successfully, pending approval"})
}

func Login(c *gin.Context) {
	var credentials struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	if err := c.ShouldBindJSON(&credentials); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Fetch user from DB
	var user models.User
	err := database.DB.Get(&user, "SELECT * FROM users WHERE email=$1", credentials.Email)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	// Compare password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(credentials.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	// Generate JWT
	token := utils.GenerateJWT(user)
	c.JSON(http.StatusOK, gin.H{"token": token})
}
