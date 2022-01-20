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

void GPIO_init();
void GPIO_init_AF();
void Timer_init();
void PWM_channel_init();
void PWM_change(int mode);
int keypad_scan();

int main(){
	int button;
	int mode;
	mode = 49;

	GPIO_init();
	GPIO_init_AF();
	Timer_init();
	PWM_channel_init();

	//TODO: Scan the keypad and use PWM to send the
	//corresponding frequency square wave to the buzzer.
	while(1){
		button = keypad_scan();
		while(keypad_scan() == button){
		}

		 if(button == 1 && mode > 9){
			mode -= 5;
			PWM_change(mode);
		}
		else if (button == -1 && mode < 89){
			mode += 5;
			PWM_change(mode);
		}
		button = 0;
	}

	return 0;
}

void Timer_init(){
	//TODO: Initialize timer

	// enable timer5
	SET_REG(RCC->APB1ENR1, 0xFFFFFFF7, 0x8)
	// set the prescaler of timer5(120)
	SET_REG(TIM5->PSC, 0xFFFF0000, 0x78)
	// reload value(99+1)
	SET_REG(TIM5->ARR, 0x0, 0x63)
	// event generation register
	SET_REG(TIM5->EGR, 0xFFFFFFFE, 0x1)
	// set timer 5 as up-counter
	SET_REG(TIM5->CR1, 0xFFFFFFEF, 0x10)
	// timer 5 counter enable, start counting
	//SET_REG(TIM5->CR1, 0xFFFFFFFE, 0x1)
}

void PWM_change(int mode){
	// timer 5 counter disable, stop counting
	//SET_REG(TIM5->CR1, 0xFFFFFFFE, 0x0)

	//set CCR1 as mode
	SET_REG(TIM5->CCR1, 0x0, mode)

	// timer 5 counter enable, start counting
	//SET_REG(TIM5->CR1, 0xFFFFFFFE, 0x1)
}

void PWM_channel_init(){
	//TODO: Initialize timer PWM channel

	//set channel 1 of timer 5 as output
	SET_REG(TIM5->CCER, 0xFFFFFFFE, 0x1)

	//set CC1S as 00, OC1M as 111
	SET_REG(TIM5->CCMR1, 0xFFFFFF8C, 0x70)

	//set CCR1 as 49(49+1)
	SET_REG(TIM5->CCR1, 0x0, 0x31)

	// timer 5 counter enable, start counting
	SET_REG(TIM5->CR1, 0xFFFFFFFE, 0x1)
}

int keypad_scan(){
	int read_val;

	for(int i = 0; i < 4; i++){
		SET_REG(GPIOB->ODR, 0xFFFFFC3F, x_pin[i])

		for(int j = 0; j < 4; j++){
			read_val = GPIOC->IDR & y_pin[j];

			if(read_val != 0){
				if(i == 0 && j == 3){
					return -1;
				}
				else if(i == 2 && j == 3){
					return 1;
				}
			}
		}
	}

	return 0;
}

void GPIO_init_AF(){
	//TODO: Initial GPIO pin as alternate function for buzzer. You can choose to use C or assembly to finish this function.
	SET_REG(GPIOA->AFR[0], 0xFFFFFFF0, 0x2)
}

void GPIO_init(){
	// enable GPIOA, B, C
	SET_REG(RCC->AHB2ENR, 0xFFFFFFF8, 0x7)

	// initial the LED
	// set PA0 as alternate function mode
	SET_REG(GPIOA->MODER, 0xFFFFFFFC, 0x2)
	// set output speed register of PA0
	SET_REG(GPIOA->OSPEEDR, 0xFFFFFFFC, 0x3)


	// initial the keypad
	//set pins PB6-9 as output mode
	SET_REG(GPIOB->MODER, 0xFFF00FFF, 0x55000)
	// Set output speed register
	SET_REG(GPIOB->OSPEEDR, 0xFFF00FFF, 0xFF000)

	//set pins PC2-5 as input mode
	SET_REG(GPIOC->MODER, 0xFFFFF00F, 0x0)
	// Keep PUPDR of pins PC2-5 as pull-down
	SET_REG(GPIOC->PUPDR, 0xFFFFF00F, 0xAA0)
	// Set output speed register
	SET_REG(GPIOC->OSPEEDR, 0xFFFFF00F, 0xFF0)
}
