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
		SELECT name, type, quantity 
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
		var quantity int
		if err := rows.Scan(&resourceName, &resourceType, &quantity); err != nil {
			log.Printf("Error scanning inventory item: %v", err)
			http.Error(w, "Error reading resource data", http.StatusInternalServerError)
			return
		}
		resources = append(resources, map[string]interface{}{
			"name":     resourceName,
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

	http.HandleFunc("/get_farm_info/", getFarmInfo)

	fmt.Println("Server is running at http://localhost:8080")
	log.Println("Server started on port 8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
