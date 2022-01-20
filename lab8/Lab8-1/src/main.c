#include "stm32l476xx.h"
#define SET_REG(REG, MASK, VAL) {((REG)=((REG) & (MASK)) | (VAL));};

int UART_Transmit( uint8_t * arr, uint32_t size) {
	//TODO: Send str to UART and return how many bytes are successfully transmitted.
	for(int i=0; i < size; i++){
		USART3->TDR = *(arr+i);
		//USART_ISR_TC
		while((USART3->ISR & 0x40) == 0);
	}
	return size;
}

void init_UART() {
	// Initialize UART registers

	// USART2 clock3 enable
	SET_REG(RCC->APB1ENR1, 0xFFFBFFFF, 0x40000)



	// === Set Baud Rate as 9600
	SET_REG(USART3->BRR, 0xFFFFFF00, 4000000L/9600L)

	/*//AHB prescaler = 2
	SET_REG(RCC->CFGR, 0xFFFFFF0F, 0x80)
	SET_REG(USART3->BRR, 0xFFFFFF00, 2000000L/115200L)*/


	// === Set start bit 1, word length 8 bit
	SET_REG(USART3->CR1, 0xEFFFEFFF,  0x0)

	// === Set stop bit 1
	SET_REG(USART3->CR2, 0xFFFFCFFF, 0x0)

	// === Enable Rx/Tx
	SET_REG(USART3->CR1, 0xFFFFFFF3, 0xC)

	// === Enable UART
	SET_REG(USART3->CR1, 0xFFFFFFFE, 0x1)

}

void GPIO_init(){
	// enable GPIOA, B, C
	SET_REG(RCC->AHB2ENR, 0xFFFFFFF8, 0x7)

	// user button
	// set PC13 as input mode
	SET_REG(GPIOC->MODER, 0xF3FFFFFF, 0x0)
	// Set PC13_PUPDR as pull-up.
	SET_REG(GPIOC->PUPDR, 0xF3FFFFFF, 0x4000000)
	// set PC13 as very high speed
	SET_REG(GPIOC->OSPEEDR, 0xF3FFFFFF, 0xC000000)

	// UART PC10(TX), PC11(RX)
	// set PC10, PC11 as alternate function mode
	SET_REG(GPIOC->MODER, 0xFF0FFFFF, 0xA00000)
	// set PC10, PC11 as Push-pull
	SET_REG(GPIOC->OTYPER, 0xF3FF, 0x0)
	// set PC10, PC11 as no pull-up, no pull-down
	SET_REG(GPIOC->PUPDR, 0xFF0FFFFF, 0x0)
	// set PC10, PC11 as very high speed
	SET_REG(GPIOC->OSPEEDR, 0xFF0FFFFF, 0xF00000)
	// set PC10, PC11 as AF7(for USART1-3)
	SET_REG(GPIOC->AFR[1], 0xFFFF00FF, 0x7700)
}

int main(){

	init_UART();
	GPIO_init();
	int flag = 0;
	while(1){
		while((GPIOC->IDR & 0x2000)!=0){
			flag++;
		}
		if(flag > 500)
			UART_Transmit("Hello World!\012\015", 14);
			flag = 0;

	}

	return 0;
}
