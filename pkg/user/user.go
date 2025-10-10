package user

import (
	"fmt"
	"regexp"
	"github.com/google/uuid"
)

// User represents a user in the system
type User struct {
	ID    string
	Name  string
	Email string
}

// NewUser creates a new user with a generated UUID
func NewUser(name, email string) *User {
	return &User{
		ID:    uuid.New().String(),
		Name:  name,
		Email: email,
	}
}

// IsValidEmail checks if the user's email is valid
func (u *User) IsValidEmail() bool {
	// Simple email validation pattern
	pattern := `^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`
	matched, _ := regexp.MatchString(pattern, u.Email)
	return matched
}

// String returns a string representation of the user
func (u *User) String() string {
	return fmt.Sprintf("User{ID: %s, Name: %s, Email: %s}", u.ID, u.Name, u.Email)
}
