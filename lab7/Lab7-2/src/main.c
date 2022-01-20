#include "stm32l476xx.h"
#define SET_REG(REG, MASK, VAL) {((REG)=((REG) & (MASK)) | (VAL));};
//define GPIO pin
#define X0 0b1000000	//PB6
#define X1 0b10000000	//PB7
#define X2 0b100000000	//PB8
#define X3 0b1000000000	//PB9
#define Y0 0b100		//PC2
#define Y1 0b1000		//PC3
#define Y2 0b10000		//PC4
#define Y3 0b100000		//PC5

unsigned int x_pin[4] = {X0, X1, X2, X3};
unsigned int y_pin[4] = {Y0, Y1, Y2, Y3};
int table[4][4] = {1, 2, 3, 10,
					4, 5, 6, 11,
					7, 8, 9, 12,
					15, 0, 14, 13};

void GPIO_init ();
void EXTI_config ();
void NVIC_config ();
void EXTI2_IRQHandler ();
void EXTI3_IRQHandler ();
void EXTI4_IRQHandler ();
void EXTI9_5_IRQHandler ();
int keypad_scan();
//void SysTick_config ();
//void SysTick_Handler ();

int main () {
	NVIC_config();
	EXTI_config();
	GPIO_init();

	while(1){
		SET_REG(GPIOB->ODR, 0xFFFFFC3F, x_pin[0])
		SET_REG(GPIOB->ODR, 0xFFFFFC3F, x_pin[1])
		SET_REG(GPIOB->ODR, 0xFFFFFC3F, x_pin[2])
		SET_REG(GPIOB->ODR, 0xFFFFFC3F, x_pin[3])

		SET_REG(GPIOA->ODR, 0xFFDF, 0x20)
	}
}

void GPIO_init () {
	// enable GPIOA, B, C
	SET_REG(RCC->AHB2ENR, 0xFFFFFFF8, 0x7)

	//initial the LED
	// set PA5 as output mode
	SET_REG(GPIOA->MODER, 0xFFFFF3FF, 0x400)
	// set output speed register of PA5
	SET_REG(GPIOA->OSPEEDR, 0xFFFFF3FF, 0xC00)

	// initial the keypad
	//set pins PB6-9 as output mode
	SET_REG(GPIOB->MODER, 0xFFF00FFF, 0x55000)
	// Set output speed register of PB6-9
	SET_REG(GPIOB->OSPEEDR, 0xFFF00FFF, 0xFF000)
	//set pins PC2-5 as input mode6t
	SET_REG(GPIOC->MODER, 0xFFFFF00F, 0x0)
	// Keep PUPDR of pins PC2-5 as pull-down
	SET_REG(GPIOC->PUPDR, 0xFFFFF00F, 0xAA0)
	// Set output speed register of PC2-5
	SET_REG(GPIOC->OSPEEDR, 0xFFFFF00F, 0xFF0)
}

void EXTI_config () {
	// enable SYSCFG
	SET_REG(RCC->APB2ENR, 0xFFFFFFFE, 0x1)

	// configure EXTI2-5 as PC2-5
	SET_REG(SYSCFG->EXTICR[0], 0xFFFF00FF, 0x2200)
	SET_REG(SYSCFG->EXTICR[1], 0xFFFFFF00, 0x22)

	//set line 2-5 as not masked
	SET_REG(EXTI->IMR1, 0xFFFFFF00, 0x3C)

	//
	SET_REG(EXTI->FTSR1, 0xFFFFFF00, 0x3C)
}

void NVIC_config () {
	//enable the interrupt exception
	NVIC_EnableIRQ(EXTI2_IRQn);
	NVIC_EnableIRQ(EXTI3_IRQn);
	NVIC_EnableIRQ(EXTI4_IRQn);
	NVIC_EnableIRQ(EXTI9_5_IRQn);
	// enable the interrupt pending of NVIC
	//SET_REG(SCB->ICSR, 0xFFBFFFFF, 0x400000)
}

void EXTI2_IRQHandler () {
	int i, j, num;
	//SET_REG(NVIC->ICPR[0], 0x0, 0x00000400)
	num = keypad_scan();
	//while(keypad_scan() == num)
	for(i = 0; i < num; i++){
		//turn off the LED
		SET_REG(GPIOA->ODR, 0xFFDF, 0x0)
		for(j = 0; j < 150000; j++){}
		//turn on the LED
		SET_REG(GPIOA->ODR, 0xFFDF, 0x20)
		for(j = 0; j < 150000; j++){}
	}
	//turn off the LED
	//SET_REG(GPIOA->ODR, 0xFFDF, 0x0)
	//clear the interrupt request
	SET_REG(EXTI->PR1, 0xFFFFFFFB, 0x4)


}

void EXTI3_IRQHandler () {
	int i, j, num;
	//SET_REG(NVIC->ICPR[0], 0x0, 0x00000400)
	num = keypad_scan();
	//while(keypad_scan() == num)
	for(i = 0; i < num; i++){
		//turn off the LED
		SET_REG(GPIOA->ODR, 0xFFDF, 0x0)
		for(j = 0; j < 150000; j++){}
		//turn on the LED
		SET_REG(GPIOA->ODR, 0xFFDF, 0x20)
		for(j = 0; j < 150000; j++){}
	}
	//turn off the LED
	//SET_REG(GPIOA->ODR, 0xFFDF, 0x0)
	//clear the interrupt request
	SET_REG(EXTI->PR1, 0xFFFFFFF7, 0x8)

}

void EXTI4_IRQHandler () {
	int i, j, num;
	//SET_REG(NVIC->ICPR[0], 0x0, 0x00000400)
	num = keypad_scan();
	//while(keypad_scan() == num)
	for(i = 0; i < num; i++){
		//turn off the LED
		SET_REG(GPIOA->ODR, 0xFFDF, 0x0)
		for(j = 0; j < 150000; j++){}
		//turn on the LED
		SET_REG(GPIOA->ODR, 0xFFDF, 0x20)
		for(j = 0; j < 150000; j++){}
	}
	//turn off the LED
	//SET_REG(GPIOA->ODR, 0xFFDF, 0x0)
	//clear the interrupt request
	SET_REG(EXTI->PR1, 0xFFFFFFEf, 0x10)

}

void EXTI9_5_IRQHandler () {
	int i, j, num;
	//SET_REG(NVIC->ICPR[0], 0x0, 0x00800000)
	num = keypad_scan();
	//while(keypad_scan() == num)
	for(i = 0; i < num; i++){
		//turn off the LED
		SET_REG(GPIOA->ODR, 0xFFDF, 0x0)
		for(j = 0; j < 150000; j++){}
		//turn on the LED
		SET_REG(GPIOA->ODR, 0xFFDF, 0x20)
		for(j = 0; j < 150000; j++){}
	}
	//turn off the LED
	//SET_REG(GPIOA->ODR, 0xFFDF, 0x0)
	//clear the interrupt request
	SET_REG(EXTI->PR1, 0xFFFFFFDF, 0x20)
}

int keypad_scan(){
	int read_val;

	for(int i = 0; i < 4; i++){
		SET_REG(GPIOB->ODR, 0xFFFFFC3F, x_pin[i])

		for(int j = 0; j < 4; j++){
			read_val = GPIOC->IDR & y_pin[j];

			if(read_val != 0){
				return table[j][i];
			}
		}
	}
	return -1;
}
