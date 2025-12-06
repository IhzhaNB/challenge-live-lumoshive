package main

import (
	"fmt"
	"pt-go-bus/dto"
	"pt-go-bus/handler"
	"pt-go-bus/service"
)

func main() {
	fmt.Println("=== SISTEM CEK TIKET PT. GOBUS ===")

	// Setup
	ticketService := service.NewTicketService()
	ticketHandler := handler.NewTicketHandler(ticketService)

	req1 := dto.NewRequest("Sidik", "Bekasi")
	ticketHandler.CheckTicket(req1)
}
