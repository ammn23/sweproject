package models

type User struct {
	UserID      int    `db:"userid" json:"user_id"`
	Email       string `db:"email" json:"email" validate:"required,email"`
	Name        string `db:"name" json:"name" validate:"required"`
	PhoneNumber int64  `db:"phone_number" json:"phone_number" validate:"required"`
	Password    string `db:"password" json:"password" validate:"required,min=8"`
	Username    string `db:"username" json:"username" validate:"required"`
}

type Farmer struct {
	FarmerID int    `db:"farmerid" json:"farmer_id"`
	UserID   int    `db:"userid" json:"user_id"`
	GovID    string `db:"govid" json:"gov_id" validate:"required"`
}

type Buyer struct {
	BuyerID         int    `db:"buyerid" json:"buyer_id"`
	UserID          int    `db:"userid" json:"user_id"`
	PaymentMethod   string `db:"payment_method" json:"payment_method" validate:"required"`
	DeliveryAddress string `db:"delivery_address" json:"delivery_address" validate:"required"`
}
