package service

import (
	"encoding/json"
	"errors"
	"pt-go-bus/data"
	"pt-go-bus/dto"
	"pt-go-bus/model"
)

type TicketService struct{}

func NewTicketService() *TicketService {
	return &TicketService{}
}

// Method check tiket
func (s *TicketService) CheckTicket(req dto.Request) (dto.Response, error) {
	// 1. Parse data JSON ke map
	var priceMap map[string]float64
	err := json.Unmarshal([]byte(data.Destination), &priceMap)
	if err != nil {
		return dto.Response{}, errors.New("Gagal membaca data destinasi")
	}

	// 2 cek apakah destinasi tersedia
	price, exists := priceMap[req.Destination]
	if !exists {
		return dto.Response{}, errors.New("Destination tidak ditemukan")
	}

	// 3. Buat model ticket (untuk data lengkap)
	ticket := model.Ticket{
		Passenger:   req.Name,
		Destination: req.Destination,
		Price:       price,
	}

	// 4. Convert ke DTO response
	return dto.Response{
		Passenger:   ticket.Passenger,
		Destination: ticket.Destination,
		Price:       ticket.Price,
	}, nil
}
