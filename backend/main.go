package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"strings"

	"syscall"
	"time"

	//"github.com/gorilla/websocket"
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

type Product struct {
	ProductID   int     `json:"product_id"`
	ProductName string  `json:"product_name"`
	FarmName    string  `json:"farm_name"`
	Price       float64 `json:"price"`
}

type EditProduct struct {
	Name        string   `json:"name"`
	Category    string   `json:"category"`
	Price       float64  `json:"price"`
	Quantity    int      `json:"quantity"`
	Description string   `json:"description"`
	Images      []string `json:"images"`
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

func farmerDashboard(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid request method. Use GET.", http.StatusMethodNotAllowed)
		return
	}
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 2 || pathParts[len(pathParts)-1] == "" {
		http.Error(w, "userid is required in the URL path", http.StatusBadRequest)
		return
	}

	// Convert userid from string to integer
	userID, err := strconv.Atoi(pathParts[len(pathParts)-1])
	if err != nil {
		log.Printf("Invalid userid: %v", err)
		http.Error(w, "userid must be a valid integer", http.StatusBadRequest)
		return
	}

	// Log the received userID
	log.Printf("Received userid: %s", userID)

	// Retrieve farmerid from farmer table
	var farmerID int
	err = db.QueryRow("SELECT farmerid FROM farmer WHERE userid = $1", userID).Scan(&farmerID)
	if err != nil {
		if err == sql.ErrNoRows {
			log.Printf("No farmer found for userid: %s", userID)
			http.Error(w, "No farmer found for the given userid", http.StatusNotFound)
		} else {
			log.Printf("Error querying farmer table: %v", err)
			http.Error(w, "Error querying database", http.StatusInternalServerError)
		}
		return
	}

	log.Printf("Retrieved farmerid: %s", farmerID)

	// Retrieve farms associated with the farmerid
	rows, err := db.Query("SELECT farmid, name FROM farm WHERE farmerid = $1", farmerID)
	if err != nil {
		log.Printf("Error querying farm table: %v", err)
		http.Error(w, "Error querying database", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// Build the response
	var farms []map[string]interface{}
	for rows.Next() {
		var farmID int
		var name string
		if err := rows.Scan(&farmID, &name); err != nil {
			log.Printf("Error scanning farm row: %v", err)
			http.Error(w, "Error processing database results", http.StatusInternalServerError)
			return
		}
		// Add farm details to the response slice
		farms = append(farms, map[string]interface{}{
			"farmid": farmID,
			"name":   name,
		})
	}

	if len(farms) == 0 {
		log.Printf("No farms found for farmerid: %s", farmerID)
		http.Error(w, "No farms found for the given farmer", http.StatusNotFound)
		return
	}

	// Log the farms found
	log.Printf("Farms found: %+v", farms)

	// Return JSON response
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(farms); err != nil {
		log.Printf("Error encoding response: %v", err)
		http.Error(w, "Error generating response", http.StatusInternalServerError)
	}
}

func getFarmerInfo(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid request method. Use GET.", http.StatusMethodNotAllowed)
		return
	}

	// Extract userid from the URL path
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 2 || pathParts[len(pathParts)-1] == "" {
		http.Error(w, "userid is required in the URL path", http.StatusBadRequest)
		return
	}

	// Convert userid from string to integer
	userID, err := strconv.Atoi(pathParts[len(pathParts)-1])
	if err != nil {
		log.Printf("Invalid userid: %v", err)
		http.Error(w, "userid must be a valid integer", http.StatusBadRequest)
		return
	}

	log.Printf("Received userid: %d", userID)

	// Retrieve farmer details
	var name, email, profilePicture string
	var phoneNumber int

	err = db.QueryRow("SELECT name, email, phone_number, profile_pic FROM users WHERE userid = $1", userID).
		Scan(&name, &email, &phoneNumber, &profilePicture)
	if err != nil {
		if err == sql.ErrNoRows {
			log.Printf("No farmer found for userid: %d", userID)
			http.Error(w, "No farmer found for the given userid", http.StatusNotFound)
		} else {
			log.Printf("Error querying users table: %v", err)
			http.Error(w, "Error querying database", http.StatusInternalServerError)
		}
		return
	}

	// Build the response
	response := map[string]interface{}{
		"name":           name,
		"email":          email,
		"phoneNumber":    phoneNumber,
		"profilePicture": profilePicture,
	}

	// Return JSON response
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(response); err != nil {
		log.Printf("Error encoding response: %v", err)
		http.Error(w, "Error generating response", http.StatusInternalServerError)
	}
}

type FarmerUpdateRequest struct {
	Name           string `json:"name"`
	Email          string `json:"email"`
	PhoneNumber    int    `json:"phoneNumber"`
	ProfilePicture string `json:"profilePicture"`
}

func updateFarmerInfo(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPut {
		http.Error(w, "Invalid request method. Use PUT.", http.StatusMethodNotAllowed)
		return
	}

	// Extract userid from the URL path
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 2 || pathParts[len(pathParts)-1] == "" {
		http.Error(w, "userid is required in the URL path", http.StatusBadRequest)
		return
	}

	// Convert userid from string to integer
	userID, err := strconv.Atoi(pathParts[len(pathParts)-1])
	if err != nil {
		log.Printf("Invalid userid: %v", err)
		http.Error(w, "userid must be a valid integer", http.StatusBadRequest)
		return
	}

	// Parse JSON body
	var req FarmerUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		log.Printf("Error decoding request body: %v", err)
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Update farmer table
	_, err = db.Exec(`
		UPDATE users
		SET name = $1, email = $2, phone_number = $3, profile_pic = $4
		WHERE userid = $5`,
		req.Name, req.Email, req.PhoneNumber, req.ProfilePicture, userID,
	)
	if err != nil {
		log.Printf("Error updating users table: %v", err)
		http.Error(w, "Error updating users information", http.StatusInternalServerError)
		return
	}

	// Respond with the updated data
	response := map[string]interface{}{
		"name":           req.Name,
		"email":          req.Email,
		"phoneNumber":    req.PhoneNumber,
		"profilePicture": req.ProfilePicture,
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(response); err != nil {
		log.Printf("Error encoding response: %v", err)
		http.Error(w, "Error generating response", http.StatusInternalServerError)
	}
}

func farmerProducts(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid request method. Use GET.", http.StatusMethodNotAllowed)
		return
	}

	// Extract userid from the URL path
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 2 || pathParts[len(pathParts)-1] == "" {
		http.Error(w, "userid is required in the URL path", http.StatusBadRequest)
		return
	}

	// Convert userid from string to integer
	userID, err := strconv.Atoi(pathParts[len(pathParts)-1])
	if err != nil {
		log.Printf("Invalid userid: %v", err)
		http.Error(w, "userid must be a valid integer", http.StatusBadRequest)
		return
	}

	// Query to fetch products for the given farmer
	query := `
		SELECT p.productid, p.name, f.name AS farm_name, p.price
		FROM product p
		INNER JOIN farm f ON p.farmid = f.farmid
		WHERE f.farmerid = (SELECT farmerid FROM farmer WHERE userid = $1)`
	rows, err := db.Query(query, userID)
	if err != nil {
		log.Printf("Error querying products: %v", err)
		http.Error(w, "Error fetching products", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// Collect products into a list
	products := []Product{}
	for rows.Next() {
		var product Product
		if err := rows.Scan(&product.ProductID, &product.ProductName, &product.FarmName, &product.Price); err != nil {
			log.Printf("Error scanning row: %v", err)
			http.Error(w, "Error processing products", http.StatusInternalServerError)
			return
		}
		products = append(products, product)
	}

	// Encode the response as JSON
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(products); err != nil {
		log.Printf("Error encoding response: %v", err)
		http.Error(w, "Error generating response", http.StatusInternalServerError)
	}
}

func deleteProduct(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodDelete {
		http.Error(w, "Invalid request method. Use DELETE.", http.StatusMethodNotAllowed)
		return
	}

	// Extract productid from the URL path
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 2 || pathParts[len(pathParts)-1] == "" {
		http.Error(w, "productid is required in the URL path", http.StatusBadRequest)
		return
	}

	// Convert productid from string to integer
	productID, err := strconv.Atoi(pathParts[len(pathParts)-1])
	if err != nil {
		log.Printf("Invalid productid: %v", err)
		http.Error(w, "productid must be a valid integer", http.StatusBadRequest)
		return
	}

	// Delete the product from the database
	query := `DELETE FROM product WHERE productid = $1`
	_, err = db.Exec(query, productID)
	if err != nil {
		log.Printf("Error deleting product: %v", err)
		http.Error(w, "Error deleting product", http.StatusInternalServerError)
		return
	}

	// Respond with success
	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, "Product deleted successfully")
}

func getProductInfo(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid request method. Use GET.", http.StatusMethodNotAllowed)
		return
	}

	// Extract productID from the URL
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 2 || pathParts[len(pathParts)-1] == "" {
		http.Error(w, "productID is required in the URL path", http.StatusBadRequest)
		return
	}

	productID, err := strconv.Atoi(pathParts[len(pathParts)-1])
	if err != nil {
		log.Printf("Invalid productID: %v", err)
		http.Error(w, "productID must be a valid integer", http.StatusBadRequest)
		return
	}

	log.Printf("Received productID: %d", productID)

	// Initialize response variables
	var productName, category, description string
	var price float32
	var quantity int
	var imageUrls []string

	// Fetch product details from the "product" table
	productQuery := `
		SELECT name, category, price, quantity, description 
		FROM product 
		WHERE productid = $1`
	row := db.QueryRow(productQuery, productID)
	err = row.Scan(&productName, &category, &price, &quantity, &description)
	if err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "Product not found", http.StatusNotFound)
		} else {
			log.Printf("Error querying product: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
		}
		return
	}

	// Fetch image URLs from the "pimage" table
	imageQuery := `
		SELECT image_url 
		FROM pimage 
		WHERE productid = $1`
	rows, err := db.Query(imageQuery, productID)
	if err != nil {
		log.Printf("Error querying images: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// Collect image URLs
	for rows.Next() {
		var imageUrl string
		if err := rows.Scan(&imageUrl); err != nil {
			log.Printf("Error scanning image URL: %v", err)
			continue
		}
		imageUrls = append(imageUrls, imageUrl)
	}

	if err := rows.Err(); err != nil {
		log.Printf("Error iterating image rows: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Prepare the response JSON
	response := map[string]interface{}{
		"name":        productName,
		"category":    category,
		"price":       price,
		"quantity":    quantity,
		"description": description,
		"images":      imageUrls,
	}

	// Send the response as JSON
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(response); err != nil {
		log.Printf("Error encoding JSON response: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
	}
}

func updateProductInfo(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPut {
		http.Error(w, "Invalid request method. Use PUT.", http.StatusMethodNotAllowed)
		return
	}

	// Extract productId from the URL
	productIdStr := r.URL.Path[len("/update_product_info/"):]
	productId, err := strconv.Atoi(productIdStr)
	if err != nil {
		http.Error(w, "Invalid product ID", http.StatusBadRequest)
		return
	}

	// Decode the incoming JSON body
	var product EditProduct
	err = json.NewDecoder(r.Body).Decode(&product)
	if err != nil {
		http.Error(w, "Invalid JSON payload", http.StatusBadRequest)
		return
	}

	// Start a transaction to ensure atomicity
	tx, err := db.Begin()
	if err != nil {
		log.Printf("Error starting transaction: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	defer func() {
		if p := recover(); p != nil {
			tx.Rollback()
			http.Error(w, "Internal server error", http.StatusInternalServerError)
		}
	}()

	// Update the product in the product table
	productUpdateQuery := `
		UPDATE product 
		SET name = $1, category = $2, price = $3, quantity = $4, description = $5 
		WHERE productid = $6
	`
	_, err = tx.Exec(productUpdateQuery, product.Name, product.Category, product.Price, product.Quantity, product.Description, productId)
	if err != nil {
		tx.Rollback()
		log.Printf("Error updating product: %v", err)
		http.Error(w, "Failed to update product", http.StatusInternalServerError)
		return
	}

	// If new images are provided, update the pimage table
	if len(product.Images) > 0 {
		// Delete existing images for the product
		deleteImagesQuery := `
			DELETE FROM pimage WHERE productid = $1
		`
		_, err = tx.Exec(deleteImagesQuery, productId)
		if err != nil {
			tx.Rollback()
			log.Printf("Error deleting existing images: %v", err)
			http.Error(w, "Failed to update product images", http.StatusInternalServerError)
			return
		}

		// Insert the new images
		imageInsertQuery := `
			INSERT INTO pimage (productid, image_url) VALUES ($1, $2)
		`
		for _, imageUrl := range product.Images {
			_, err = tx.Exec(imageInsertQuery, productId, imageUrl)
			if err != nil {
				tx.Rollback()
				log.Printf("Error inserting new image: %v", err)
				http.Error(w, "Failed to update product images", http.StatusInternalServerError)
				return
			}
		}
	}

	// Commit the transaction
	if err = tx.Commit(); err != nil {
		log.Printf("Error committing transaction: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Respond with success message
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	response := map[string]string{"message": "Product updated successfully"}
	json.NewEncoder(w).Encode(response)
}

func getFarmInfo(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		log.Printf("Invalid request method. Use GET.", http.StatusMethodNotAllowed)
		http.Error(w, "Invalid request method. Use GET.", http.StatusMethodNotAllowed)
		return
	}

	// Extract farmId from the URL
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 3 || pathParts[len(pathParts)-1] == "" {
		log.Printf("Invalid path: %v", r.URL.Path)
		http.Error(w, "farmId is required in the URL path", http.StatusBadRequest)
		return
	}

	farmId, err := strconv.Atoi(pathParts[len(pathParts)-1])
	if err != nil {
		log.Printf("Invalid farm ID: %v", r.URL.Path)
		http.Error(w, "Invalid farmId. It must be an integer.", http.StatusBadRequest)
		return
	}

	log.Printf("Received following farmid: %v", farmId)

	// Query to fetch farm details
	var farmName, location string
	var size float64
	farmQuery := `
		SELECT name, size, location 
		FROM farm 
		WHERE farmid = $1
	`
	err = db.QueryRow(farmQuery, farmId).Scan(&farmName, &size, &location)
	if err != nil {
		if err == sql.ErrNoRows {
			log.Printf("Error finding farm: %v", err)
			http.Error(w, "Farm not found", http.StatusNotFound)
		} else {
			log.Printf("Error fetching farm: %v", err)
			http.Error(w, "Failed to fetch farm details", http.StatusInternalServerError)
		}
		return
	}

	// Query to fetch inventory items (resources) for the farm
	resourceQuery := `
		SELECT itemid, name, type, quantity 
		FROM inventory_item 
		WHERE farmid = $1
	`
	rows, err := db.Query(resourceQuery, farmId)
	if err != nil {
		log.Printf("Error fetching inventory item: %v", err)
		http.Error(w, "Failed to fetch farm resources", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// Collect resources
	resources := []map[string]interface{}{}
	for rows.Next() {
		var resourceName string
		var resourceType string
		var quantity, itemId int
		if err := rows.Scan(&itemId, &resourceName, &resourceType, &quantity); err != nil {
			log.Printf("Error scanning inventory item: %v", err)
			http.Error(w, "Error reading resource data", http.StatusInternalServerError)
			return
		}
		resources = append(resources, map[string]interface{}{
			"itemId":   itemId,
			"name":     resourceName,
			"type":     resourceType,
			"quantity": quantity,
		})
	}

	// Construct the response
	response := map[string]interface{}{
		"farm_name": farmName,
		"size":      size,
		"location":  location,
		"resources": resources,
	}

	// Send the response
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
	return
}

func updateFarmInfo(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPut {
		log.Printf("Invalid request method. Use PUT.")
		http.Error(w, "Invalid request method. Use PUT.", http.StatusMethodNotAllowed)
		return
	}

	// Extract farmId from URL
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 3 || pathParts[len(pathParts)-1] == "" {
		log.Printf("Invalid path: %v", r.URL.Path)
		http.Error(w, "farmId is required in the URL path", http.StatusBadRequest)
		return
	}

	farmId, err := strconv.Atoi(pathParts[len(pathParts)-1])
	if err != nil {
		log.Printf("Invalid farm ID: %v", err)
		http.Error(w, "Invalid farmId. It must be an integer.", http.StatusBadRequest)
		return
	}

	// Parse request body
	var requestBody struct {
		FarmName  string  `json:"farm_name"`
		Size      float64 `json:"size"`
		Location  string  `json:"location"`
		Resources []struct {
			ItemId   int    `json:"itemid"`
			Type     string `json:"type"`
			Name     string `json:"name"`
			Quantity int    `json:"quantity"`
		} `json:"resources"`
	}
	if err := json.NewDecoder(r.Body).Decode(&requestBody); err != nil {
		log.Printf("Error parsing request body: %v", err)
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Update farm details
	updateFarmQuery := `
        UPDATE farm
        SET name = $1, size = $2, location = $3
        WHERE farmid = $4
    `
	_, err = db.Exec(updateFarmQuery, requestBody.FarmName, requestBody.Size, requestBody.Location, farmId)
	if err != nil {
		log.Printf("Error updating farm details: %v", err)
		http.Error(w, "Failed to update farm details", http.StatusInternalServerError)
		return
	}

	updateQuery := `
    UPDATE inventory_item
    SET type = $1, name = $2, quantity = $3
    WHERE itemid = $4;
`

	// Loop through resources and update each
	for _, resource := range requestBody.Resources {
		_, err := db.Exec(
			updateQuery,
			resource.Type, // $1: New type
			resource.Name, // $2: New name
			resource.Quantity,
			resource.ItemId, // $7: Existing name
		)
		if err != nil {
			log.Printf("Error updating resource: %v", err)
			http.Error(w, "Failed to update resources", http.StatusInternalServerError)
			return
		}
	}

	// Send updated farm data as response
	response := map[string]interface{}{
		"farm_name": requestBody.FarmName,
		"size":      requestBody.Size,
		"location":  requestBody.Location,
		"resources": requestBody.Resources,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

type NewProduct struct {
	FarmID      int      `json:"farmid"`
	Name        string   `json:"name"`
	Category    string   `json:"category"`
	Price       float64  `json:"price"`
	Quantity    int      `json:"quantity"`
	Description string   `json:"description"`
	Images      []string `json:"images"`
}

func createNewProduct(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		log.Printf("Invalid request method. Use POST. Status: %d", http.StatusMethodNotAllowed)
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	// Extract and validate user ID
	userID := r.URL.Path[len("/create_new_product/"):]
	if _, err := strconv.Atoi(userID); err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	// Decode and validate new product
	var newProduct NewProduct
	if err := json.NewDecoder(r.Body).Decode(&newProduct); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Validate product details
	if newProduct.Name == "" {
		http.Error(w, "Product name is required", http.StatusBadRequest)
		return
	}
	if newProduct.Price <= 0 {
		http.Error(w, "Invalid price", http.StatusBadRequest)
		return
	}
	if newProduct.Quantity < 0 {
		http.Error(w, "Quantity cannot be negative", http.StatusBadRequest)
		return
	}

	// Begin transaction
	tx, err := db.Begin()
	if err != nil {
		log.Printf("Failed to begin transaction: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Ensure transaction is rolled back if not committed
	defer func() {
		if err := tx.Rollback(); err != nil && err != sql.ErrTxDone {
			log.Printf("Transaction rollback error: %v", err)
		}
	}()

	// Insert product data
	productQuery := `INSERT INTO product (farmid, name, category, price, quantity, description, available) 
                     VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING productid`

	var productID int64
	err = tx.QueryRow(productQuery,
		newProduct.FarmID,
		newProduct.Name,
		newProduct.Category,
		newProduct.Price,
		newProduct.Quantity,
		newProduct.Description,
		newProduct.Quantity,
	).Scan(&productID)

	if err != nil {
		log.Printf("Failed to insert product: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Insert product images
	imageQuery := `INSERT INTO pimage (productid, image_url) VALUES ($1, $2)`
	for _, imageURL := range newProduct.Images {
		_, err := tx.Exec(imageQuery, productID, imageURL)
		if err != nil {
			log.Printf("Failed to insert product image: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		log.Printf("Failed to commit transaction: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Product created successfully with ID: %d", productID)
}

type ProductResponse struct {
	ID            int     `json:"id"`
	Name          string  `json:"name"`
	FarmName      string  `json:"farm_name"`
	Price         float64 `json:"price"`
	Available     int     `json:"available"`
	FirstImageURL string  `json:"first_image_url"`
	Category      string  `json:"category"`
	Description   string  `json:"description"`
}

func searchProductsWithImages(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	query := `
        SELECT 
            p.productid AS id,
            p.name,
            f.name AS farm_name,
            p.price,
            p.quantity AS available,
            (SELECT pi.image_url 
             FROM pimage pi 
             WHERE pi.productid = p.productid 
             LIMIT 1) AS first_image_url,
            p.category,
            p.description
        FROM product p
        JOIN farm f ON p.farmid = f.farmid
        WHERE 1=1
    `

	// Build query parameters
	var params []interface{}
	paramCount := 1

	// Add category filter
	if category := r.URL.Query().Get("category"); category != "" {
		query += fmt.Sprintf(" AND p.category = $%d", paramCount)
		params = append(params, category)
		paramCount++
	}

	// Add price range filters
	if minPrice := r.URL.Query().Get("min_price"); minPrice != "" {
		if price, err := strconv.ParseFloat(minPrice, 64); err == nil {
			query += fmt.Sprintf(" AND p.price >= $%d", paramCount)
			params = append(params, price)
			paramCount++
		}
	}

	if maxPrice := r.URL.Query().Get("max_price"); maxPrice != "" {
		if price, err := strconv.ParseFloat(maxPrice, 64); err == nil {
			query += fmt.Sprintf(" AND p.price <= $%d", paramCount)
			params = append(params, price)
			paramCount++
		}
	}

	// Add location filter
	if location := r.URL.Query().Get("location"); location != "" {
		query += fmt.Sprintf(" AND f.location LIKE $%d", paramCount)
		params = append(params, "%"+location+"%")
		paramCount++
	}

	// Add ordering
	query += " ORDER BY p.price ASC"

	// Execute query
	rows, err := db.Query(query, params...)
	if err != nil {
		log.Printf("Database query error: %v", err)
		http.Error(w, "Error fetching products", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var products []ProductResponse
	for rows.Next() {
		var p ProductResponse
		var imageURL sql.NullString
		err := rows.Scan(
			&p.ID,
			&p.Name,
			&p.FarmName,
			&p.Price,
			&p.Available,
			&imageURL,
			&p.Category,
			&p.Description,
		)
		if err != nil {
			log.Printf("Error scanning row: %v", err)
			continue
		}
		if imageURL.Valid {
			p.FirstImageURL = imageURL.String
		}
		products = append(products, p)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(products)
}

// Structure for included_in table
type IncludedInRequest struct {
	UserID           int     `json:"user_id"`
	ProductID        int     `json:"product_id"`
	SelectedQuantity int     `json:"selected_quantity"`
	TotalPrice       float64 `json:"total_price"`
}

func addToIncludedIn(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	log.Printf("Received request to add_to_included_in")

	var req IncludedInRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		log.Printf("Error decoding request body: %v", err)
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	log.Printf("Received data: %+v", req)

	// First get buyerid from users table
	var buyerID int
	err := db.QueryRow(`
        SELECT b.buyerid 
        FROM buyer b 
        JOIN users u ON b.userid = u.userid 
        WHERE u.userid = $1`, req.UserID).Scan(&buyerID)
	if err != nil {
		if err == sql.ErrNoRows {
			log.Printf("Buyer with user ID %d not found", req.UserID)
			http.Error(w, "Buyer not found", http.StatusNotFound)
			return
		}
		log.Printf("Error getting buyer ID: %v", err)
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}

	// Check product availability
	var available int
	err = db.QueryRow("SELECT available FROM product WHERE productid = $1", req.ProductID).Scan(&available)
	if err != nil {
		log.Printf("Error checking product availability: %v", err)
		http.Error(w, "Error checking product availability", http.StatusInternalServerError)
		return
	}

	if available < req.SelectedQuantity {
		log.Printf("Requested quantity %d exceeds available stock %d", req.SelectedQuantity, available)
		http.Error(w, "Selected quantity exceeds available stock", http.StatusBadRequest)
		return
	}

	// Start transaction
	tx, err := db.Begin()
	if err != nil {
		log.Printf("Error starting transaction: %v", err)
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}
	defer tx.Rollback()

	// Delete existing entry if exists
	_, err = tx.Exec(`
        DELETE FROM included_in 
        WHERE productid = $1 AND buyerid = $2`,
		req.ProductID, buyerID)
	if err != nil {
		log.Printf("Error deleting existing cart item: %v", err)
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}

	// Insert into included_in
	_, err = tx.Exec(`
        INSERT INTO included_in (productid, buyerid, quantity, price)
        VALUES ($1, $2, $3, $4)`,
		req.ProductID, buyerID, req.SelectedQuantity, req.TotalPrice)
	if err != nil {
		log.Printf("Error inserting into included_in: %v", err)
		http.Error(w, "Error adding to cart", http.StatusInternalServerError)
		return
	}

	// Update cart total
	_, err = tx.Exec(`
        DELETE FROM cart WHERE buyerid = $1`, buyerID)
	if err != nil {
		log.Printf("Error clearing existing cart entry: %v", err)
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}

	// Insert new cart total
	_, err = tx.Exec(`
        INSERT INTO cart (buyerid, total_cost)
        VALUES ($1, $2)`,
		buyerID, req.TotalPrice)
	if err != nil {
		log.Printf("Error updating cart total: %v", err)
		http.Error(w, "Error updating cart", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"message": "Successfully added to cart"})
}

// Structure for payment creation
type PaymentRequest struct {
	BuyerID int       `json:"buyer_id"`
	Date    time.Time `json:"date"`
	Amount  float64   `json:"amount"`
	Method  string    `json:"method"`
	Status  string    `json:"status"`
}

// Handler for /create_payment
func createPayment(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req PaymentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	var paymentID int
	err := db.QueryRow(`
        INSERT INTO payment (date, amount, method, status, buyerid)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING paymentid`,
		req.Date, req.Amount, req.Method, req.Status, req.BuyerID).Scan(&paymentID)

	if err != nil {
		http.Error(w, "Failed to create payment", http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"payment_id": paymentID,
	}
	json.NewEncoder(w).Encode(response)
}

// Structure for order creation
type OrderRequest struct {
	BuyerID     int    `json:"buyer_id"`
	DateOrdered string `json:"date_ordered"`
	DateShipped string `json:"date_shipped"`
	Address     string `json:"address"`
	PaymentID   int    `json:"payment_id"`
}

// Handler for /create_order
func createOrder(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req OrderRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	var orderID int
	err := db.QueryRow(`
        INSERT INTO orderu (status, date_ordered, date_shipped, address, buyerid, paymentid)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING orderid`,
		"Processing", req.DateOrdered, req.DateShipped, req.Address, req.BuyerID, req.PaymentID).Scan(&orderID)

	if err != nil {
		http.Error(w, "Failed to create order", http.StatusInternalServerError)
		return
	}

	// Create order in created_from table
	_, err = db.Exec(`
        INSERT INTO created_from (orderid, buyerid)
        VALUES ($1, $2)`,
		orderID, req.BuyerID)

	if err != nil {
		http.Error(w, "Failed to link order", http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"order_id": orderID,
	}
	json.NewEncoder(w).Encode(response)
}

type ChatMessage struct {
	MessageID  int       `json:"messageid"`
	Content    string    `json:"content"`
	Timestamp  time.Time `json:"timestamp"`
	SenderID   int       `json:"sender_id"`
	ReceiverID int       `json:"receiver_id"`
}

type Negotiation struct {
	NegotiationID int     `json:"negotiationid"`
	ProductID     int     `json:"product_id"`
	BuyerID       int     `json:"buyer_id"`
	FarmerID      int     `json:"farmer_id"`
	OfferedPrice  float64 `json:"offered_price"`
	Status        string  `json:"status"`
}

func getOrCreateChat(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var request struct {
		BuyerID  int `json:"buyer_id"`
		FarmerID int `json:"farmer_id"`
	}

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	var chatID int
	err := db.QueryRow(`
        SELECT chatid 
        FROM communication 
        WHERE buyerid = $1 AND farmerid = $2
    `, request.BuyerID, request.FarmerID).Scan(&chatID)

	if err == sql.ErrNoRows {
		err = db.QueryRow(`
            INSERT INTO chat DEFAULT VALUES RETURNING chatid
        `).Scan(&chatID)
		if err != nil {
			http.Error(w, "Error creating chat", http.StatusInternalServerError)
			return
		}

		_, err = db.Exec(`
            INSERT INTO communication (chatid, buyerid, farmerid)
            VALUES ($1, $2, $3)
        `, chatID, request.BuyerID, request.FarmerID)
		if err != nil {
			http.Error(w, "Error linking chat", http.StatusInternalServerError)
			return
		}
	} else if err != nil {
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"chat_id": chatID,
	})
}

func sendMessage(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var msg struct {
		ChatID     int    `json:"chat_id"`
		SenderID   int    `json:"sender_id"`
		ReceiverID int    `json:"receiver_id"`
		Content    string `json:"content"`
	}

	if err := json.NewDecoder(r.Body).Decode(&msg); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	var messageID int
	err := db.QueryRow(`
        INSERT INTO message (timestamp, content, senderid, receiverid, chatid)
        VALUES (CURRENT_TIMESTAMP, $1, $2, $3, $4)
        RETURNING messageid
    `, msg.Content, msg.SenderID, msg.ReceiverID, msg.ChatID).Scan(&messageID)

	if err != nil {
		http.Error(w, "Error sending message", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message_id": messageID,
		"status":     "sent",
	})
}

func getChatMessages(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	chatID := r.URL.Query().Get("chatId")
	if chatID == "" {
		http.Error(w, "chatId is required", http.StatusBadRequest)
		return
	}

	rows, err := db.Query(`
        SELECT messageid, content, timestamp, senderid, receiverid
        FROM message
        WHERE chatid = $1
        ORDER BY timestamp ASC
    `, chatID)
	if err != nil {
		http.Error(w, "Error fetching messages", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var messages []ChatMessage
	for rows.Next() {
		var msg ChatMessage
		err := rows.Scan(&msg.MessageID, &msg.Content, &msg.Timestamp,
			&msg.SenderID, &msg.ReceiverID)
		if err != nil {
			log.Printf("Error scanning message: %v", err)
			continue
		}
		messages = append(messages, msg)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(messages)
}

func makeOffer(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var offer Negotiation
	if err := json.NewDecoder(r.Body).Decode(&offer); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	var negotiationID int
	err := db.QueryRow(`
        INSERT INTO negotiations (farmerid, buyerid, offered_price, status)
        VALUES ($1, $2, $3, 'Pending')
        RETURNING negotiationid
    `, offer.FarmerID, offer.BuyerID, offer.OfferedPrice).Scan(&negotiationID)

	if err != nil {
		http.Error(w, "Error creating offer", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"negotiation_id": negotiationID,
		"status":         "Pending",
	})
}

// Delivery options structure

type DeliveryOption struct {
	Method string `json:"method"`

	Cost float64 `json:"cost"`

	Available bool `json:"available"`
}

// Order structure (Updated to use 'user_id' instead of 'buyer_id')

type Order struct {
	UserID int `json:"user_id"` // Changed from 'buyer_id' to 'user_id'

	DeliveryMethod string `json:"delivery_method"`

	DeliveryAddress string `json:"delivery_address"`

	PaymentMethod string `json:"payment_method"`

	TotalCost float64 `json:"total_cost"`
}

// In-memory data for delivery options

var deliveryOptions = []DeliveryOption{

	{Method: "Home Delivery", Cost: 3.0, Available: true},

	{Method: "Pick-Up Points", Cost: 0.0, Available: true},

	{Method: "Third-Party Delivery", Cost: 5.0, Available: true},
}

// Function to handle getting delivery options

func getDeliveryOptions(w http.ResponseWriter, r *http.Request) {

	w.Header().Set("Content-Type", "application/json")

	if r.Method == http.MethodGet {

		// Return available delivery options

		json.NewEncoder(w).Encode(deliveryOptions)

		return

	}

	http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)

}

// Function to handle creating an order

func createOrder2(w http.ResponseWriter, r *http.Request) {

	if r.Method == http.MethodPost {

		var order Order

		// Read and log the raw request body

		bodyBytes, err := ioutil.ReadAll(r.Body)

		if err != nil {

			http.Error(w, "Unable to read request body", http.StatusBadRequest)

			return

		}

		log.Println("Received order request body:", string(bodyBytes)) // Log the request body for debugging

		// Decode the incoming JSON body into the Order struct

		if err := json.Unmarshal(bodyBytes, &order); err != nil {

			log.Println("Error decoding JSON:", err) // Log the error for debugging

			http.Error(w, "Invalid request body", http.StatusBadRequest)

			return

		}

		// Check if selected delivery method is available

		selectedMethod := order.DeliveryMethod

		var deliveryCost float64

		var validMethod bool

		for _, option := range deliveryOptions {

			if strings.EqualFold(option.Method, selectedMethod) && option.Available {

				deliveryCost = option.Cost

				validMethod = true

				break

			}

		}

		if !validMethod {

			http.Error(w, "Selected delivery method is unavailable", http.StatusBadRequest)

			return

		}

		// Calculate total cost (Assuming you have a way to calculate the order total)

		totalOrderCost := order.TotalCost + deliveryCost

		// Return the order details along with calculated total cost

		order.TotalCost = totalOrderCost

		w.Header().Set("Content-Type", "application/json")

		json.NewEncoder(w).Encode(order)

		return

	}

	http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)

}

// SalesReportData represents the data for the sales report

type SalesReportData struct {
	TotalSales float64 `json:"totalSales"`

	TotalRevenue float64 `json:"totalRevenue"`

	TopSellingProducts []string `json:"topSellingProducts"`

	ReportGeneratedAt time.Time `json:"reportGeneratedAt"`
}

// fetchSalesData queries sales data based on report type (daily, weekly, monthly)

func fetchSalesData(farmerID int, startDate, endDate time.Time, reportType string) ([]map[string]interface{}, error) {

	var query string

	// Adjust the query based on the report type (daily, weekly, monthly)

	switch reportType {

	case "daily":

		query = `

			SELECT p.name AS product_name, SUM(ci.quantity) AS total_quantity, SUM(ci.quantity * p.price) AS total_sales

			FROM cart c

			JOIN included_in ci ON c.cartid = ci.cartid

			JOIN product p ON ci.productid = p.productid

			WHERE c.date_ordered BETWEEN $1 AND $2 AND c.farmerid = $3

			GROUP BY p.name, c.date_ordered

			ORDER BY total_sales DESC

		`

	case "weekly":

		query = `

			SELECT p.name AS product_name, SUM(ci.quantity) AS total_quantity, SUM(ci.quantity * p.price) AS total_sales

			FROM cart c

			JOIN included_in ci ON c.cartid = ci.cartid

			JOIN product p ON ci.productid = p.productid

			WHERE c.date_ordered BETWEEN $1 AND $2 AND c.farmerid = $3

			GROUP BY p.name, EXTRACT(week FROM c.date_ordered)

			ORDER BY total_sales DESC

		`

	case "monthly":

		query = `

			SELECT p.name AS product_name, SUM(ci.quantity) AS total_quantity, SUM(ci.quantity * p.price) AS total_sales

			FROM cart c

			JOIN included_in ci ON c.cartid = ci.cartid

			JOIN product p ON ci.productid = p.productid

			WHERE c.date_ordered BETWEEN $1 AND $2 AND c.farmerid = $3

			GROUP BY p.name, EXTRACT(month FROM c.date_ordered)

			ORDER BY total_sales DESC

		`

	default:

		return nil, fmt.Errorf("invalid report type: %s", reportType)

	}

	// Execute the query

	rows, err := db.Query(query, startDate, endDate, farmerID)

	if err != nil {

		return nil, err

	}

	defer rows.Close()

	// Process and return the sales data

	var salesData []map[string]interface{}

	for rows.Next() {

		var productName string

		var totalSales float64

		var totalQuantity int

		if err := rows.Scan(&productName, &totalQuantity, &totalSales); err != nil {

			return nil, err

		}

		salesData = append(salesData, map[string]interface{}{

			"product_name": productName,

			"total_quantity": totalQuantity,

			"total_sales": totalSales,
		})

	}

	return salesData, nil

}

// Function to generate the sales report

func generateSalesReport(w http.ResponseWriter, r *http.Request) {

	if r.Method != http.MethodGet {

		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)

		return

	}

	// Get query parameters

	userIdStr := r.URL.Query().Get("userId")

	startDateStr := r.URL.Query().Get("startDate")

	endDateStr := r.URL.Query().Get("endDate")

	reportType := r.URL.Query().Get("reportType")

	// Parse userId

	userId, err := strconv.Atoi(userIdStr)

	if err != nil {

		http.Error(w, "Invalid userId format", http.StatusBadRequest)

		return

	}

	// Parse startDate and endDate

	startDate, err := time.Parse("2006-01-02", startDateStr)

	if err != nil {

		http.Error(w, "Invalid start date format", http.StatusBadRequest)

		return

	}

	endDate, err := time.Parse("2006-01-02", endDateStr)

	if err != nil {

		http.Error(w, "Invalid end date format", http.StatusBadRequest)

		return

	}

	// Fetch sales data

	salesData, err := fetchSalesData(userId, startDate, endDate, reportType)

	if err != nil {

		http.Error(w, "Failed to retrieve sales data", http.StatusInternalServerError)

		return

	}

	// Process the sales data

	var totalSales, totalRevenue float64

	var topSellingProducts []string

	for _, data := range salesData {

		totalSales += data["total_sales"].(float64)

		totalRevenue += data["total_sales"].(float64) // Assuming price * quantity is total_sales

		topSellingProducts = append(topSellingProducts, data["product_name"].(string))

	}

	// Generate and send the report

	report := SalesReportData{

		TotalSales: totalSales,

		TotalRevenue: totalRevenue,

		TopSellingProducts: topSellingProducts,

		ReportGeneratedAt: time.Now(),
	}

	w.Header().Set("Content-Type", "application/json")

	json.NewEncoder(w).Encode(report)

}

// BuyerReportData represents the data for the buyer report

type BuyerReportData struct {
	TotalPurchases int `json:"totalPurchases"`

	TotalSpent float64 `json:"totalSpent"`

	PreferredProducts []string `json:"preferredProducts"`

	ReportGeneratedAt time.Time `json:"reportGeneratedAt"`
}

// fetchBuyerPurchaseData queries the purchase data for the buyer within the date range

func fetchBuyerPurchaseData(buyerID int, startDate, endDate time.Time) ([]map[string]interface{}, error) {

	query := `

		SELECT p.name AS product_name, SUM(ci.quantity) AS total_quantity, SUM(ci.quantity * p.price) AS total_spent

		FROM cart c

		JOIN included_in ci ON c.cartid = ci.cartid

		JOIN product p ON ci.productid = p.productid

		WHERE c.buyerid = $1 AND c.date_ordered BETWEEN $2 AND $3

		GROUP BY p.name

	`

	rows, err := db.Query(query, buyerID, startDate, endDate)

	if err != nil {

		return nil, err

	}

	defer rows.Close()

	var purchaseData []map[string]interface{}

	for rows.Next() {

		var productName string

		var totalSpent float64

		var totalQuantity int

		if err := rows.Scan(&productName, &totalQuantity, &totalSpent); err != nil {

			return nil, err

		}

		purchaseData = append(purchaseData, map[string]interface{}{

			"product_name": productName,

			"quantity": totalQuantity,

			"total_spent": totalSpent,
		})

	}

	return purchaseData, nil

}

// Function to generate the buyer report

func generateBuyerReport(w http.ResponseWriter, r *http.Request) {

	if r.Method != http.MethodGet {

		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)

		return

	}

	// Get query parameters

	userIdStr := r.URL.Query().Get("userId")

	startDateStr := r.URL.Query().Get("startDate")

	endDateStr := r.URL.Query().Get("endDate")

	// Parse userId

	userId, err := strconv.Atoi(userIdStr)

	if err != nil {

		http.Error(w, "Invalid userId format", http.StatusBadRequest)

		return

	}

	// Parse startDate and endDate

	startDate, err := time.Parse("2006-01-02", startDateStr)

	if err != nil {

		http.Error(w, "Invalid start date format", http.StatusBadRequest)

		return

	}

	endDate, err := time.Parse("2006-01-02", endDateStr)

	if err != nil {

		http.Error(w, "Invalid end date format", http.StatusBadRequest)

		return

	}

	// Fetch buyer purchase data

	purchaseData, err := fetchBuyerPurchaseData(userId, startDate, endDate)

	if err != nil {

		http.Error(w, "Failed to retrieve purchase data", http.StatusInternalServerError)

		return

	}

	// Process the purchase data

	var totalPurchases int

	var totalSpent float64

	var preferredProducts []string

	for _, purchase := range purchaseData {

		totalPurchases += purchase["quantity"].(int)

		totalSpent += purchase["total_spent"].(float64)

		preferredProducts = append(preferredProducts, purchase["product_name"].(string))

	}

	// Generate and send the report

	report := BuyerReportData{

		TotalPurchases: totalPurchases,

		TotalSpent: totalSpent,

		PreferredProducts: preferredProducts,

		ReportGeneratedAt: time.Now(),
	}

	w.Header().Set("Content-Type", "application/json")

	json.NewEncoder(w).Encode(report)

}

// InventoryReportData represents the data for the inventory report

type InventoryReportData struct {
	LowStockCount int `json:"lowStockCount"`

	ReportGeneratedAt time.Time `json:"reportGeneratedAt"`
}

// fetchInventoryData queries the inventory data for the given farm and checks for low stock

func fetchInventoryData(farmerID int) ([]map[string]interface{}, error) {

	query := `

		SELECT p.name AS product_name, i.quantity AS total_quantity

		FROM inventory_item i

		JOIN product p ON i.farmid = p.farmid

		WHERE i.farmid = $1 AND i.quantity < 10

		ORDER BY i.quantity ASC

	`

	rows, err := db.Query(query, farmerID)

	if err != nil {

		return nil, err

	}

	defer rows.Close()

	var inventoryData []map[string]interface{}

	for rows.Next() {

		var productName string

		var totalQuantity int

		if err := rows.Scan(&productName, &totalQuantity); err != nil {

			return nil, err

		}

		inventoryData = append(inventoryData, map[string]interface{}{

			"product_name": productName,

			"total_quantity": totalQuantity,
		})

	}

	return inventoryData, nil

}

// Function to generate the inventory report

func generateInventoryReport(w http.ResponseWriter, r *http.Request) {

	if r.Method != http.MethodGet {

		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)

		return

	}

	// Get query parameters

	userIdStr := r.URL.Query().Get("userId")

	// Parse userId

	userId, err := strconv.Atoi(userIdStr)

	if err != nil {

		http.Error(w, "Invalid userId format", http.StatusBadRequest)

		return

	}

	// Fetch inventory data

	inventoryData, err := fetchInventoryData(userId)

	if err != nil {

		http.Error(w, "Failed to retrieve inventory data", http.StatusInternalServerError)

		return

	}

	// Process the inventory data

	var lowStockCount int

	for _, data := range inventoryData {

		if data["total_quantity"].(int) < 10 {

			lowStockCount++

		}

	}

	// Generate and send the report

	report := InventoryReportData{

		LowStockCount: lowStockCount,

		ReportGeneratedAt: time.Now(),
	}

	w.Header().Set("Content-Type", "application/json")

	json.NewEncoder(w).Encode(report)

}

// sendOrderStatusNotification sends a notification when an order status changes

func sendOrderStatusNotification(orderID, userID int, newStatus string) error {

	// Create the notification message

	message := fmt.Sprintf("Your order (ID: %d) status has changed to: %s", orderID, newStatus)

	// Insert the notification into the database

	_, err := db.Exec(`

		INSERT INTO public.notification (recipientid, message, status)

		VALUES ($1, $2, $3)`,

		userID, message, "unread")

	if err != nil {

		return fmt.Errorf("failed to insert notification: %v", err)

	}

	// Here, we would trigger the real-time notification (e.g., WebSocket or Push Notification)

	return nil

}

// This function is triggered when the order status is updated in the database

func updateOrderStatus(w http.ResponseWriter, r *http.Request) {

	// Parse the order status from the request

	var orderID int

	var userID int

	var newStatus string

	// You would extract the data (orderID, userID, newStatus) from the request body or query parameters

	// For simplicity, we're hardcoding values

	orderID = 123 // Example order ID

	userID = 6 // Example user ID (buyer)

	newStatus = "Shipped"

	// Send notification to the buyer (or user)

	err := sendOrderStatusNotification(orderID, userID, newStatus)

	if err != nil {

		http.Error(w, "Failed to send notification", http.StatusInternalServerError)

		return

	}

	w.WriteHeader(http.StatusOK)

	fmt.Fprintf(w, "Order status updated and notification sent.")

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
	http.HandleFunc("/farmer_dashboard/", farmerDashboard)
	http.HandleFunc("/get_farmer_info/", getFarmerInfo)
	http.HandleFunc("/update_farmer_info/", updateFarmerInfo)
	http.HandleFunc("/farmer_products/", farmerProducts)
	http.HandleFunc("/delete_product/", deleteProduct)

	http.HandleFunc("/get_product_info/", getProductInfo)
	http.HandleFunc("/update_product_info/", updateProductInfo)
	http.HandleFunc("/create_new_product/", createNewProduct)
	http.HandleFunc("/add_to_included_in", addToIncludedIn)
	http.HandleFunc("/create_payment", createPayment)
	http.HandleFunc("/create_order", createOrder)

	http.HandleFunc("/get_farm_info/", getFarmInfo)
	http.HandleFunc("/update_farm_info/", updateFarmInfo)

	http.HandleFunc("/products_with_images", searchProductsWithImages)

	http.HandleFunc("/chat", getOrCreateChat)
	http.HandleFunc("/messages", sendMessage)
	http.HandleFunc("/chat_messages", getChatMessages)
	http.HandleFunc("/make_offer", makeOffer)

	// Setup routes for delivery options and order creation 3.8
	http.HandleFunc("/delivery_options", getDeliveryOptions)
	http.HandleFunc("/create_order", createOrder2)
	// Setup routes 3.9(reports)
	http.HandleFunc("/reports/farmer/sales", generateSalesReport)
	http.HandleFunc("/reports/farmer/inventory", generateInventoryReport)
	http.HandleFunc("/reports/buyer", generateBuyerReport)
	//3.10
	//http.HandleFunc("/ws", handleConnections)`

	fmt.Println("Server is running at http://localhost:8080")
	log.Println("Server started on port 8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
