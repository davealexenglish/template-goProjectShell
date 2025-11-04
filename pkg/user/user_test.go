package user

import (
	"testing"
)

func TestNewUser(t *testing.T) {
	name := "John Doe"
	email := "john@example.com"

	u := NewUser(name, email)

	if u.Name != name {
		t.Errorf("Expected name %s, got %s", name, u.Name)
	}

	if u.Email != email {
		t.Errorf("Expected email %s, got %s", email, u.Email)
	}

	if u.ID == "" {
		t.Error("Expected non-empty ID")
	}
}

func TestIsValidEmail(t *testing.T) {
	tests := []struct {
		name  string
		email string
		want  bool
	}{
		{"valid email", "test@example.com", true},
		{"valid with subdomain", "test@mail.example.com", true},
		{"valid with plus", "test+tag@example.com", true},
		{"invalid no @", "testexample.com", false},
		{"invalid no domain", "test@", false},
		{"invalid no user", "@example.com", false},
		{"invalid spaces", "test @example.com", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			u := NewUser("Test", tt.email)
			got := u.IsValidEmail()
			if got != tt.want {
				t.Errorf("IsValidEmail() = %v, want %v for email %s", got, tt.want, tt.email)
			}
		})
	}
}

func TestUserString(t *testing.T) {
	u := &User{
		ID:    "test-id-123",
		Name:  "Jane Doe",
		Email: "jane@example.com",
	}

	result := u.String()
	expected := "User{ID: test-id-123, Name: Jane Doe, Email: jane@example.com}"

	if result != expected {
		t.Errorf("String() = %s, want %s", result, expected)
	}
}
