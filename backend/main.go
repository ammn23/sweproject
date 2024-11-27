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

	connStr := "user=postgres dbname=farmersmarket password=2004Amina host=farmersmarket.cpywg2ws46ft.eu-north-1.rds.amazonaws.com port=5432 sslmode=disable"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error connecting to the database: %v", err), http.StatusInternalServerError)
		return
	}
	defer db.Close()

	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	var registrationData map[string]interface{}
	decoder := json.NewDecoder(r.Body)
	err = decoder.Decode(&registrationData)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	// Create user
	user := Users{
		Email:       registrationData["email"].(string),
		Name:        registrationData["name"].(string),
		PhoneNumber: int(registrationData["phone_number"].(float64)),
		Password:    registrationData["password"].(string),
		Username:    registrationData["username"].(string),
	}

	// Insert into users table
	var userID int
	err = db.QueryRow(`
		INSERT INTO public.users (email, name, phone_number, password, username)
		VALUES ($1, $2, $3, $4, $5) RETURNING userID
	`, user.Email, user.Name, user.PhoneNumber, user.Password, user.Username).Scan(&userID)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error inserting user: %v", err), http.StatusInternalServerError)
		return
	}

	// Create farmer
	farmer := Farmer{
		UserID: userID,
		GovID:  registrationData["govid"].(string),
	}

	// Insert into farmer table
	var farmerID int
	err = db.QueryRow(`
		INSERT INTO public.farmer (userid, govid)
		VALUES ($1, $2) RETURNING farmerID
	`, farmer.UserID, farmer.GovID).Scan(&farmerID)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error inserting farmer: %v", err), http.StatusInternalServerError)
		return
	}

	// Create farm
	farm := Farm{
		FarmerID: farmerID,
		Location: registrationData["location"].(string),
		Size:     registrationData["farm_size"].(float64),
		Name:     registrationData["name"].(string),
	}

	// Insert into farm table
	_, err = db.Exec(`
		INSERT INTO public.farm (farmerid, location, size, name)
		VALUES ($1, $2, $3, $4)
	`, farm.FarmerID, farm.Location, farm.Size, farm.Name)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error inserting farm: %v", err), http.StatusInternalServerError)
		return
	}

	// Return success response
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Farmer registered successfully"))
}

func main() {
	http.HandleFunc("/register_farmer", registerFarmer)
	fmt.Println("Server is running at http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
