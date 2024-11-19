package database

import (
	"log"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

var DB *sqlx.DB

func InitDB() {
	var err error
	DB, err = sqlx.Connect("postgres", "user=ablajabdimalinov password= dbname=mileston_proj sslmode=disable")
	if err != nil {
		log.Fatalln("Failed to connect to DB:", err)
	}
}
