package handler

import (
	"fmt"
	"pt-go-bus/dto"
	"pt-go-bus/service"
)

type TicketHanlder struct {
	ticketService *service.TicketService
}

func NewTicketHandler(ticketService *service.TicketService) *TicketHanlder {
	return &TicketHanlder{
		ticketService: ticketService,
	}
}

func (h *TicketHanlder) CheckTicket(req dto.Request) {
	fmt.Println("\n--- Harga Tiket ---")

	// Panggil Service
	resp, err := h.ticketService.CheckTicket(req)

	// Tampilkan hasil
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	fmt.Printf("Penumpang : %s\n", resp.Passenger)
	fmt.Printf("Tujuan    : %s\n", resp.Destination)
	fmt.Printf("Harga     : Rp %.2f\n", resp.Price)
	fmt.Println("-------------------")
}
