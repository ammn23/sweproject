package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"

	_ "github.com/lib/pq"
)

var db *sql.DB

func initDB() (*sql.DB, error) {
	connStr := "user=postgres dbname=farmersmarket password=2004Amina host=farmersmarket.cpywg2ws46ft.eu-north-1.rds.amazonaws.com port=5432 sslmode=require"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, fmt.Errorf("error connecting to the database: %w", err)
	}

	// Optionally test the connection
	if err = db.Ping(); err != nil {
		return nil, fmt.Errorf("error verifying database connection: %w", err)
	}

	return db, nil
}

type Users struct {
	ID          int    `json:"id"`
	Email       string `json:"email"`
	Name        string `json:"name"`
	PhoneNumber int    `json:"phone_number"`
	Password    string `json:"password"`
	Username    string `json:"username"`
}

type Farmer struct {
	FarmerID int    `json:"farmer_id"`
	UserID   int    `json:"user_id"`
	GovID    string `json:"gov_id"`
}

type Farm struct {
	FarmID   int     `json:"farm_id"`
	FarmerID int     `json:"farmer_id"`
	Location string  `json:"location"`
	Size     float64 `json:"size"`
	Name     string  `json:"name"`
}

type Buyer struct {
	BuyerID       int    `json:"buyer_id"`
	UserID        int    `json:"user_id"`
	DeliveryAddr  string `json:"delivery_address"`
	PaymentMethod string `json:"payment_method"`
}

type LoginRequest struct {
	Identifier string `json:"identifier"`
	Password   string `json:"password"`
	Role       string `json:"role"`
}

type LoginResponse struct {
	UserID int    `json:"userId"`
	Name   string `json:"name"`
}

func registerBuyer(w http.ResponseWriter, r *http.Request) {

	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		log.Println("Request made with invalid HTTP method")
		return
	}

	var registrationData map[string]interface{}
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&registrationData)
	if err != nil {
		log.Printf("JSON decoding error: %v", err)
		http.Error(w, fmt.Sprintf("Error decoding JSON: %v", err), http.StatusBadRequest)
		return
	}

	// Extract and validate fields
	name, ok := registrationData["name"].(string)
	if !ok {
		http.Error(w, "Missing or invalid 'name' field", http.StatusBadRequest)
		log.Println("Error: 'name' field is missing or invalid")
		return
	}

	email, ok := registrationData["email"].(string)
	if !ok {
		http.Error(w, "Missing or invalid 'email' field", http.StatusBadRequest)
		log.Println("Error: 'email' field is missing or invalid")
		return
	}

	phoneNumberFloat, ok := registrationData["phone_number"].(float64)
	if !ok {
		http.Error(w, "Missing or invalid 'phone_number' field", http.StatusBadRequest)
		log.Println("Error: 'phone_number' field is missing or invalid")
		return
	}
	phoneNumber := int(phoneNumberFloat)

	deliveryAddress, ok := registrationData["delivery_address"].(string)
	if !ok {
		http.Error(w, "Missing or invalid 'delivery_address' field", http.StatusBadRequest)
		log.Println("Error: 'delivery_address' field is missing or invalid")
		return
	}

	paymentMethod, ok := registrationData["payment_method"].(string)
	if !ok {
		http.Error(w, "Missing or invalid 'payment_method' field", http.StatusBadRequest)
		log.Println("Error: 'payment_method' field is missing or invalid")
		return
	}

	username, ok := registrationData["username"].(string)
	if !ok {
		http.Error(w, "Missing or invalid 'username' field", http.StatusBadRequest)
		log.Println("Error: 'username' field is missing or invalid")
		return
	}

	password, ok := registrationData["password"].(string)
	if !ok {
		http.Error(w, "Missing or invalid 'password' field", http.StatusBadRequest)
		log.Println("Error: 'password' field is missing or invalid")
		return
	}

	// Insert into users table
	var userID int
	err = db.QueryRow(`
		INSERT INTO public.users (email, name, phone_number, password, username)
		VALUES ($1, $2, $3, $4, $5) RETURNING userID
	`, email, name, phoneNumber, password, username).Scan(&userID)
	if err != nil {
		log.Printf("Database insertion error for user: %v", err)
		http.Error(w, fmt.Sprintf("Error inserting user: %v", err), http.StatusInternalServerError)
		return
	}

	// Insert into buyers table
	_, err = db.Exec(`
		INSERT INTO public.buyer (userid, delivery_address, payment_method)
		VALUES ($1, $2, $3)
	`, userID, deliveryAddress, paymentMethod)
	if err != nil {
		log.Printf("Database insertion error for buyer: %v", err)
		http.Error(w, fmt.Sprintf("Error inserting buyer: %v", err), http.StatusInternalServerError)
		return
	}

	// Success response
	log.Printf("Buyer registered successfully with UserID: %d", userID)
	response := map[string]string{"message": "Buyer registered successfully"}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

func registerFarmer(w http.ResponseWriter, r *http.Request) {

	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		log.Println("Request made with invalid HTTP method")
		return
	}

	var registrationData map[string]interface{}
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&registrationData)
	if err != nil {
		log.Printf("JSON decoding error: %v", err)
		http.Error(w, fmt.Sprintf("Error decoding JSON: %v", err), http.StatusBadRequest)
		return
	}

	// Extract fields from request
	name, ok := registrationData["name"].(string)
	if !ok {
		http.Error(w, "Missing or invalid 'name' field", http.StatusBadRequest)
		log.Println("Error: 'name' field is missing or invalid")
		return
	}

	email, ok := registrationData["email"].(string)
	if !ok {
		http.Error(w, "Missing or invalid 'email' field", http.StatusBadRequest)
		log.Println("Error: 'email' field is missing or invalid")
		return
	}

	phoneNumberFloat, ok := registrationData["phone_number"].(float64)
	if !ok {
		http.Error(w, "Missing or invalid 'phone_number' field", http.StatusBadRequest)
		log.Println("Error: 'phone_number' field is missing or invalid")
		return
	}
	phoneNumber := int(phoneNumberFloat)

	password, ok := registrationData["password"].(string)
	if !ok {
		http.Error(w, "Missing or invalid 'password' field", http.StatusBadRequest)
		log.Println("Error: 'password' field is missing or invalid")
		return
	}

	username, ok := registrationData["username"].(string)
	if !ok {
		http.Error(w, "Missing or invalid 'username' field", http.StatusBadRequest)
		log.Println("Error: 'username' field is missing or invalid")
		return
	}

	// Insert user into database
	var userID int
	err = db.QueryRow(`
		INSERT INTO public.users (email, name, phone_number, password, username)
		VALUES ($1, $2, $3, $4, $5) RETURNING userID
	`, email, name, phoneNumber, password, username).Scan(&userID)
	if err != nil {
		log.Printf("Database insertion error for user: %v", err)
		http.Error(w, fmt.Sprintf("Error inserting user: %v", err), http.StatusInternalServerError)
		return
	}

	// Insert farmer into database
	govid, ok := registrationData["govid"].(string)
	if !ok {
		http.Error(w, "Missing or invalid 'govid' field", http.StatusBadRequest)
		log.Println("Error: 'govid' field is missing or invalid")
		return
	}

	var farmerID int
	err = db.QueryRow(`
		INSERT INTO public.farmer (userid, govid)
		VALUES ($1, $2) RETURNING farmerID
	`, userID, govid).Scan(&farmerID)
	if err != nil {
		log.Printf("Database insertion error for farmer: %v", err)
		http.Error(w, fmt.Sprintf("Error inserting farmer: %v", err), http.StatusInternalServerError)
		return
	}

	// Insert farm into database
	location, ok := registrationData["location"].(string)
	if !ok {
		http.Error(w, "Missing or invalid 'location' field", http.StatusBadRequest)
		log.Println("Error: 'location' field is missing or invalid")
		return
	}

	farmSize, ok := registrationData["farm_size"].(float64)
	if !ok {
		http.Error(w, "Missing or invalid 'farm_size' field", http.StatusBadRequest)
		log.Println("Error: 'farm_size' field is missing or invalid")
		return
	}

	_, err = db.Exec(`
		INSERT INTO public.farm (farmerid, location, size, name)
		VALUES ($1, $2, $3, $4)
	`, farmerID, location, farmSize, name+"'s Farm")
	if err != nil {
		log.Printf("Database insertion error for farm: %v", err)
		http.Error(w, fmt.Sprintf("Error inserting farm: %v", err), http.StatusInternalServerError)
		return
	}

	// Success response
	log.Printf("Farmer registered successfully with UserID: %d, FarmerID: %d", userID, farmerID)
	response := map[string]string{"message": "Farmer registered successfully"}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

func login(w http.ResponseWriter, r *http.Request) {
	// Validate HTTP method
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	// Parse and validate login request
	var loginReq LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&loginReq); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Validate input fields
	if err := validateLoginRequest(loginReq); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Authenticate user
	userDetails, err := authenticateUser(loginReq)
	if err != nil {
		// Error handling with appropriate status codes
		switch {
		case errors.Is(err, sql.ErrNoRows):
			http.Error(w, "User not found", http.StatusNotFound)
		case errors.Is(err, ErrInvalidCredentials):
			http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		case errors.Is(err, ErrUserNotActivated):
			http.Error(w, "User not activated", http.StatusForbidden)
		default:
			log.Printf("Login error: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
		}
		return
	}

	// Respond with user details
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(userDetails)
}

// Custom error types
var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrUserNotActivated   = errors.New("user not activated")
)

func validateLoginRequest(req LoginRequest) error {
	// Trim and validate input fields
	req.Identifier = strings.TrimSpace(req.Identifier)
	req.Role = strings.TrimSpace(req.Role)

	if req.Identifier == "" {
		return errors.New("identifier is required")
	}
	if req.Password == "" {
		return errors.New("password is required")
	}
	if req.Role == "" {
		return errors.New("role is required")
	}

	return nil
}

func authenticateUser(req LoginRequest) (*LoginResponse, error) {
	var userID int
	var storedPassword string
	var usersName string
	var isActive bool
	var userType string

	// Unified query to fetch user details
	query := `
    SELECT 
        u.userid, 
        u.password, 
        u.name, 
        CASE 
            WHEN f.userid IS NOT NULL THEN f.is_active 
            ELSE true 
        END as is_active,
        CASE 
            WHEN f.userid IS NOT NULL THEN 'Farmer'
            WHEN b.userid IS NOT NULL THEN 'Buyer'
            ELSE NULL 
        END as user_type
    FROM public.users u
    LEFT JOIN public.farmer f ON u.userid = f.userid
    LEFT JOIN public.buyer b ON u.userid = b.userid
    WHERE u.email = $1 OR u.username = $1
    `

	err := db.QueryRow(query, req.Identifier).Scan(
		&userID, &storedPassword, &usersName, &isActive, &userType,
	)

	// Extensive logging for debugging
	log.Printf("Query Params - Identifier: %s, Role: %s", req.Identifier, req.Role)
	log.Printf("Database Fetch - Error: %v", err)

	if err != nil {
		if err == sql.ErrNoRows {
			log.Printf("No user found with identifier: %s", req.Identifier)
		}
		return nil, err
	}

	// Log additional details
	log.Printf("Found User - ID: %d, Name: %s, Type: %s, Active: %v",
		userID, usersName, userType, isActive)

	// Log password details for debugging
	log.Printf("Stored Password: %s", storedPassword)
	log.Printf("Provided Password: %s", req.Password)

	// Verify password
	passwordMatch := storedPassword == req.Password
	log.Printf("Password Match: %v", passwordMatch)

	// Bcrypt comparison (if passwords are hashed)
	// bcryptErr := bcrypt.CompareHashAndPassword([]byte(storedPassword), []byte(req.Password))
	// log.Printf("Bcrypt Comparison Error: %v", bcryptErr)

	// Password check
	if !passwordMatch {
		log.Printf("Password mismatch for user: %s", req.Identifier)
		return nil, ErrInvalidCredentials
	}

	// Role-specific checks
	if req.Role != userType {
		log.Printf("Role Mismatch - Expected: %s, Found: %s", req.Role, userType)
		return nil, ErrInvalidCredentials
	}

	// Check user activation status
	if !isActive {
		log.Printf("User not active: %s", req.Identifier)
		return nil, ErrUserNotActivated
	}

	return &LoginResponse{
		UserID: userID,
		Name:   usersName,
	}, nil
}

func main() {
	var err error
	db, err = initDB()
	if err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer func() {
		if err := db.Close(); err != nil {
			log.Printf("Error closing database: %v", err)
		}
	}()

	// Handle shutdown gracefully
	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
		<-sigChan
		log.Println("Shutting down server...")
		os.Exit(0)
	}()

	http.HandleFunc("/register_farmer", registerFarmer)
	http.HandleFunc("/register_buyer", registerBuyer)
	http.HandleFunc("/login", login)
	fmt.Println("Server is running at http://localhost:8080")
	log.Println("Server started on port 8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
