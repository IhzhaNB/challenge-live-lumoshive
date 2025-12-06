package dto

type Request struct {
	Name, Destination string
}

// Constructor untuk membuat request
func NewRequest(name string, destination string) Request {
	return Request{
		Name:        name,
		Destination: destination,
	}
}
