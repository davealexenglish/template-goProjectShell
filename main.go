package main

import (
	"fmt"
	"github.com/davealexenglish/projectShell/pkg/user"
)

func main() {
	// Create a new user
	u := user.NewUser("Alice", "alice@example.com")

	fmt.Printf("Created user: %s\n", u.String())
	fmt.Printf("User ID: %s\n", u.ID)
	fmt.Printf("Valid email: %t\n", u.IsValidEmail())
}
