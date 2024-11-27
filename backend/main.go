package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	_ "github.com/lib/pq"
	"log"
	"net/http"
)

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

func registerFarmer(w http.ResponseWriter, r *http.Request) {
	connStr := "user=postgres dbname=farmersmarket password=2004Amina host=farmersmarket.cpywg2ws46ft.eu-north-1.rds.amazonaws.com port=5432 sslmode=require"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Printf("Database connection error: %v", err)
		http.Error(w, fmt.Sprintf("Error connecting to the database: %v", err), http.StatusInternalServerError)
		return
	}
	defer db.Close()

	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		log.Println("Request made with invalid HTTP method")
		return
	}

	var registrationData map[string]interface{}
	decoder := json.NewDecoder(r.Body)
	err = decoder.Decode(&registrationData)
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

func main() {
	http.HandleFunc("/register_farmer", registerFarmer)
	fmt.Println("Server is running at http://localhost:8080")
	log.Println("Server started on port 8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
