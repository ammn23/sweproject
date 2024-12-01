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
	"strconv"
	"strings"
	"syscall"
	"time"

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

// Struct Definitions
type DeliveryOption struct {
	Method string  `json:"method"`
	Cost   float64 `json:"cost"`
}

type Notification struct {
	UserID  int    `json:"user_id"`
	Title   string `json:"title"`
	Message string `json:"message"`
	Time    string `json:"time"`
}

type ReportRequest struct {
	UserID     int    `json:"user_id"`
	ReportType string `json:"report_type"`
	StartDate  string `json:"start_date"`
	EndDate    string `json:"end_date"`
}

// Handlers

// 3.8 Delivery Management
func getDeliveryOptions(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query("SELECT method, cost FROM delivery_options")
	if err != nil {
		http.Error(w, "Couldn't get delivery options", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var options []DeliveryOption
	for rows.Next() {
		var option DeliveryOption
		if err := rows.Scan(&option.Method, &option.Cost); err != nil {
			http.Error(w, "Error processing delivery data", http.StatusInternalServerError)
			return
		}
		options = append(options, option)
	}
	json.NewEncoder(w).Encode(options)
}

func calculateDelivery(w http.ResponseWriter, r *http.Request) {
	var request struct {
		Method      string  `json:"method"`
		TotalAmount float64 `json:"total_amount"`
	}

	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		http.Error(w, "Incorrect input", http.StatusBadRequest)
		return
	}

	var cost float64
	err = db.QueryRow("SELECT cost FROM delivery_options WHERE method = $1", request.Method).Scan(&cost)
	if err == sql.ErrNoRows {
		http.Error(w, "The delivery method is not available", http.StatusBadRequest)
		return
	} else if err != nil {
		http.Error(w, "Error in calculating the shipping cost", http.StatusInternalServerError)
		return
	}

	totalCost := request.TotalAmount + cost
	response := map[string]float64{
		"delivery_cost": cost,
		"total_cost":    totalCost,
	}
	json.NewEncoder(w).Encode(response)
}

// 3.9 Reporting and Analytics
func generateReport(w http.ResponseWriter, r *http.Request) {
	var req ReportRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request format", http.StatusBadRequest)
		return
	}

	var query string
	switch req.ReportType {
	case "sales":
		query = "SELECT date, revenue, product, quantity FROM sales_data WHERE date BETWEEN $1 AND $2"
	case "inventory":
		query = "SELECT product, stock, low_stock_threshold FROM inventory_data"
	case "buyer":
		query = "SELECT date, amount, product FROM buyer_data WHERE user_id = $1 AND date BETWEEN $2 AND $3"
	default:
		http.Error(w, "Invalid report type", http.StatusBadRequest)
		return
	}

	rows, err := db.Query(query, req.StartDate, req.EndDate)
	if err != nil {
		http.Error(w, "Report generation error", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var report []map[string]interface{}
	cols, _ := rows.Columns()
	for rows.Next() {
		row := make(map[string]interface{})
		values := make([]interface{}, len(cols))
		for i := range values {
			values[i] = new(interface{})
		}
		rows.Scan(values...)
		for i, col := range cols {
			row[col] = *(values[i].(*interface{}))
		}
		report = append(report, row)
	}
	json.NewEncoder(w).Encode(report)
}

// Handler for generating downloadable JSON reports
func downloadReport(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Only the POST method is allowed", http.StatusMethodNotAllowed)
		return
	}

	var req ReportRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request format", http.StatusBadRequest)
		return
	}

	// Query based on report type
	var query string
	switch req.ReportType {
	case "sales":
		query = "SELECT date, revenue, product, quantity FROM sales_data WHERE date BETWEEN $1 AND $2"
	case "inventory":
		query = "SELECT product, stock, low_stock_threshold FROM inventory_data"
	case "buyer":
		query = "SELECT date, amount, product FROM buyer_data WHERE user_id = $1 AND date BETWEEN $2 AND $3"
	default:
		http.Error(w, "Invalid report type", http.StatusBadRequest)
		return
	}

	rows, err := db.Query(query, req.StartDate, req.EndDate)
	if err != nil {
		http.Error(w, "Error receiving report data", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var report []map[string]interface{}
	cols, _ := rows.Columns()
	for rows.Next() {
		row := make(map[string]interface{})
		values := make([]interface{}, len(cols))
		for i := range values {
			values[i] = new(interface{})
		}
		rows.Scan(values...)
		for i, col := range cols {
			row[col] = *(values[i].(*interface{}))
		}
		report = append(report, row)
	}

	// Create a temporary file for the JSON report
	fileName := fmt.Sprintf("%s_report_%d.json", req.ReportType, time.Now().Unix())
	file, err := os.Create(fileName)
	if err != nil {
		http.Error(w, "Error creating the report file", http.StatusInternalServerError)
		return
	}
	defer file.Close()

	// Write the report to the file
	jsonEncoder := json.NewEncoder(file)
	jsonEncoder.SetIndent("", "  ")
	if err := jsonEncoder.Encode(report); err != nil {
		http.Error(w, "Error writing data to a file", http.StatusInternalServerError)
		return
	}

	// Serve the file for download
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=%s", fileName))
	w.Header().Set("Content-Type", "application/json")
	http.ServeFile(w, r, fileName)

	// Cleanup the temporary file after serving
	go func() {
		time.Sleep(1 * time.Minute)
		os.Remove(fileName)
	}()
}

// 3.10 Notifications
func sendNotification(w http.ResponseWriter, r *http.Request) {
	var notification Notification
	if err := json.NewDecoder(r.Body).Decode(&notification); err != nil {
		http.Error(w, "Invalid notification data", http.StatusBadRequest)
		return
	}

	_, err := db.Exec("INSERT INTO notifications (user_id, title, message, time) VALUES ($1, $2, $3, $4)",
		notification.UserID, notification.Title, notification.Message, time.Now())
	if err != nil {
		http.Error(w, "Error sending notification", http.StatusInternalServerError)
		return
	}

	w.Write([]byte("The notification has been sent successfully"))
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

	http.HandleFunc("/get_farm_info/", getFarmInfo)
	http.HandleFunc("/update_farm_info/", updateFarmInfo)

	http.HandleFunc("/delivery/options", getDeliveryOptions)
	http.HandleFunc("/delivery/calculate", calculateDelivery)
	http.HandleFunc("/reports/generate", generateReport)
	http.HandleFunc("/reports/download", downloadReport)
	http.HandleFunc("/notifications/send", sendNotification)

	fmt.Println("Server is running at http://localhost:8080")
	log.Println("Server started on port 8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
