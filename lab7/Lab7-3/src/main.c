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

int keypad_disable = 0;
void GPIO_init() {
	// enable GPIOA, B, C
	SET_REG(RCC->AHB2ENR, 0xFFFFFFF8, 0x7)

	//initial the buzzer
	// set PA0 as alternate function mode
	SET_REG(GPIOA->MODER, 0xFFFFFFFC, 0x2)
	// set output speed register of PA0
	SET_REG(GPIOA->OSPEEDR, 0xFFFFFFFC, 0x3)

	//initial max7219
	// set pins PB3-5 as output mode
	SET_REG(GPIOB->MODER, 0xFFFFF03F, 0x540)
	// set output speed register
	SET_REG(GPIOB->OSPEEDR, 0xFFFFF03F, 0xFC0)

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

	//initial the user button
	// set PC13 as input mode
	SET_REG(GPIOC->MODER, 0xF3FFFFFF, 0x0)
	// Set PC13_PUPDR as pull-up.
	SET_REG(GPIOC->PUPDR, 0xF3FFFFFF, 0x4000000)

}
int keypad_scan() {
	int read_val;

	for (int i = 0; i < 4; i++) {
		SET_REG(GPIOB->ODR, 0xFFFFFC3F, x_pin[i])

			for (int j = 0; j < 4; j++) {
				read_val = GPIOC->IDR & y_pin[j];

				if (read_val != 0) {
					return table[j][i];
				}
			}
	}
	return -1;
}

void SystemClock_Config() {
	// set HSI as system clock source

	// HSI16 clock enable
	SET_REG(RCC->CR, 0xFFFFFEFF, 0x100)

	// system clock switch to HSI16 oscillator
	SET_REG(RCC->CFGR, 0xFFFFFFFC, 0x1)
	// AHB prescaler, SYSCLK divided by 2
	// before going to SysTick, the clock will be divided by 8
	// so clk=1Mhz
	SET_REG(RCC->CFGR, 0xFFFFFF0F, 0x80)
}

void SysTick_config(int n) {

	// SysTick exception request enable
	SET_REG(SysTick->CTRL, 0xFFFFFFFD, 0x2)

	// RELOAD value=n*1000000
	SET_REG(SysTick->LOAD, 0xFF000000, n * 1000000)
	if (n == 0) {
		SET_REG(SysTick->LOAD, 0xFF000000, 1)
	}
	// counter enable
	SET_REG(SysTick->CTRL, 0xFFFFFFFE, 0x1)

	// display time on Max7219

	// clear
	for (int i = 1; i < 8; i++) {
		max7219_send(i, 0xF);
	}

	int display_num = n;
	int digit = display_num;

	if (display_num > 9) {
		for (int i = 1; i <= 2; i++) {
			max7219_send(i, digit % 10);
			digit = digit / 10;
		}
	}
	else {
		max7219_send(1, digit);
	}

	if(n == 0){
		max7219_send(1, 0);
		display_num = 0;
	}


	while (1) {

		if ((SysTick->VAL & 0xFFFFFF) % 1000000 > 999995) {

			display_num--;
			digit = display_num;

			// clear
			max7219_send(1, 0xF);
			max7219_send(2, 0xF);

			if (display_num > 9) {
				for (int i = 1; i <= 2; i++) {

					max7219_send(i, digit % 10);

					digit = digit / 10;
				}
			}
			else {
				max7219_send(1, digit);
			}
		}

		if((SysTick->VAL & 0xFFFFFF) < 5){
			max7219_send(1, 0);
			break;
		}
	}

}

void GPIO_init_AF() {
	//TODO: Initial GPIO pin as alternate function
	// set alternate function selection as AF2 for PA0
	SET_REG(GPIOA->AFR[0], 0xFFFFFFF0, 0x2)

}



void Timer_init() {
	//TODO: Initialize timer

	// enable TIM5
	SET_REG(RCC->APB1ENR1, 0xFFFFFFF7, 0x8)
		// Tevent=(PSC+1)*(ARR+1)*Tint
		// set TIM5 prescalar register
		SET_REG(TIM5->PSC, 0xFFFF0000, 299)	// prescalar=299(+1)
		// set TIM5 auto-reload register
		SET_REG(TIM5->ARR, 0x0, 99)	// auto-reload=99(+1)
		//SET_REG(TIM5->ARR, 0x0, 299)	// auto-reload=299(+1)


		// re-initializes TIM5 and generates an update of the registers
		SET_REG(TIM5->EGR, 0xFFFFFFFE, 0x1)
		// set TIM5 as up-counter
		SET_REG(TIM5->CR1, 0xFFFFFFEF, 0x10)

		// set TIM5 control register, start timer
		//SET_REG(TIM5->CR1, 0xFFFFFFFE, 0x1)
}
void PWM_channel_init() {
	//TODO: Initialize timer PWM channel

	// set CCR1 value = 49
	SET_REG(TIM5->CCR1, 0x0, 49)
		//SET_REG(TIM5->CCR1, 0x0, 149)

		// set CC1S as 00 ( CC1 channel configured as output)
		// set OC1M as 111 ( TIMx_CNT<TIMx_CCR1 is inactive)
		SET_REG(TIM5->CCMR1, 0xFFFFFF8C, 0x70)

		// enable CH1 channel ( OC1 signal is output on the corresponding output pin)
		SET_REG(TIM5->CCER, 0xFFFFFFFE, 0x1)

		// set TIM5 control register, start timer
		SET_REG(TIM5->CR1, 0xFFFFFFFE, 0x1)

}


void SysTick_Handler() {
	//max7219_send(1, 0);

	int read_button;

	// systick counter disable
	SET_REG(SysTick->CTRL, 0xFFFFFFFE, 0x0)

	// for buzzer input wave
	GPIO_init_AF();
	Timer_init();
	PWM_channel_init();

	read_button = (GPIOC->IDR & 0x2000);
	while (read_button != 0) {
		read_button = (GPIOC->IDR & 0x2000);
	}

	// timer 5 counter disable, stop counting
	SET_REG(TIM5->CR1, 0xFFFFFFFE, 0x0)

		keypad_disable = 0;
}



void EXTI_config() {
	// enable SYSCFG
	SET_REG(RCC->APB2ENR, 0xFFFFFFFE, 0x1)

		// configure EXTI2-5 as PC2-5
		SET_REG(SYSCFG->EXTICR[0], 0xFFFF00FF, 0x2200)
		SET_REG(SYSCFG->EXTICR[1], 0xFFFFFF00, 0x22)

		// set line 2-5 as not masked
		SET_REG(EXTI->IMR1, 0xFFFFFF00, 0x3C)

		// falling trigger enabled for line 2-5
		SET_REG(EXTI->FTSR1, 0xFFFFFF00, 0x3C)
}

void NVIC_config() {
	//enable the interrupt exception
	NVIC_EnableIRQ(EXTI2_IRQn);
	NVIC_EnableIRQ(EXTI3_IRQn);
	NVIC_EnableIRQ(EXTI4_IRQn);
	NVIC_EnableIRQ(EXTI9_5_IRQn);
	// enable the interrupt pending of NVIC
	//SET_REG(SCB->ICSR, 0xFFBFFFFF, 0x400000)
}
void EXTI2_IRQHandler() {
	int i, j, num;
	keypad_disable = 1;

	num = keypad_scan();
	SysTick_config(num);

	//clear the interrupt request
	SET_REG(EXTI->PR1, 0xFFFFFFFB, 0x4)


}

void EXTI3_IRQHandler() {
	int i, j, num;
	keypad_disable = 1;

	num = keypad_scan();
	SysTick_config(num);

	//clear the interrupt request
	SET_REG(EXTI->PR1, 0xFFFFFFF7, 0x8)

}

void EXTI4_IRQHandler() {
	int i, j, num;
	keypad_disable = 1;

	num = keypad_scan();
	SysTick_config(num);

	//clear the interrupt request
	SET_REG(EXTI->PR1, 0xFFFFFFEf, 0x10)

}

void EXTI9_5_IRQHandler() {
	int i, j, num;
	keypad_disable = 1;

	num = keypad_scan();
	SysTick_config(num);

	//clear the interrupt request
	SET_REG(EXTI->PR1, 0xFFFFFFDF, 0x20)
}



int main() {
	NVIC_config();
	EXTI_config();
	GPIO_init();
	max7219_init();
	SystemClock_Config();
	keypad_disable = 0;
	//SysTick_config();
	while (1) {
		// clear
		for (int i = 1; i < 8; i++) {
			max7219_send(i, 0xF);
		}

		if (keypad_disable == 0) {
			// make keypad detect the interrupt
			SET_REG(GPIOB->ODR, 0xFFFFFC3F, x_pin[0])
				SET_REG(GPIOB->ODR, 0xFFFFFC3F, x_pin[1])
				SET_REG(GPIOB->ODR, 0xFFFFFC3F, x_pin[2])
				SET_REG(GPIOB->ODR, 0xFFFFFC3F, x_pin[3])

		}


	}


	return 0;
}
