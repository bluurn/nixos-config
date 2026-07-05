package main

import "testing"

func TestGreeting(t *testing.T) {
	got := Greeting("Nix")
	want := "Hello, Nix!"

	if got != want {
		t.Fatalf("Greeting() = %q, want %q", got, want)
	}
}
