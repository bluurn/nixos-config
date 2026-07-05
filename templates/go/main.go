package main

import "fmt"

func main() {
	fmt.Println(Greeting("Nix"))
}

func Greeting(name string) string {
	return "Hello, " + name + "!"
}
