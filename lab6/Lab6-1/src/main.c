#include "cmsis_gcc.h"
#include "core_cm4.h"
#include "core_cmFunc.h"
#include "core_cmInstr.h"
#include "core_cmSimd.h"
#include "stm32l476xx.h"
#include "system_stm32l4xx.h"

#define SET_REG(REG, MASK, VAL) {((REG)=((REG) & (MASK)) | (VAL));};

void GPIO_init();
void Delay1sUnder4MHz();
void Set_HCLK(int freq);
void set_timer7();

int main(){
	// Do initializations.
	int freq[] = {1, 6, 10, 16, 40};
	int i = 0;
	int press, read_button;
	GPIO_init();
	set_timer7();

	for (;;){
		// change LED state
		//turn the LED on
		SET_REG(GPIOA->ODR, 0xFFDF, 0x0)
		Delay1sUnder4MHz();

		// change HCLK if button pressed
		press = 0;
		read_button = (GPIOC->IDR & 0x2000);
		while(read_button == 0){
			press = 1;
			read_button = (GPIOC->IDR & 0x2000);
		}
		if(press == 1){
			Set_HCLK(freq[i]);
			i++;
			i = i % 5;
		}

		//turn the LED off
		SET_REG(GPIOA->ODR, 0xFFDF, 0x20)
		Delay1sUnder4MHz();


		// change HCLK if button pressed
		press = 0;
		read_button = (GPIOC->IDR & 0x2000);
		while(read_button == 0){
			press = 1;
			read_button = (GPIOC->IDR & 0x2000);
		}
		if(press == 1){
			Set_HCLK(freq[i]);
			i++;
			i = i % 5;
		}

	}
}

void set_timer7(){
	// enable timer7
	SET_REG(RCC->APB1ENR1, 0xFFFFFFDF, 0x20)
	// set the prescaler of timer7(999+1)
	SET_REG(TIM7->PSC, 0xFFFF0000, 0x3E7)
	// reload value(3999+1)
	SET_REG(TIM7->ARR, 0xFFFF0000, 0xF9F)
	// event generation register(set UG as 1,  Re-initialize the counter and generates an update of the registers.)
	SET_REG(TIM7->EGR, 0xFFFFFFFE, 0x1)
	// enable timer 7
	SET_REG(TIM7->CR1, 0xFFFFFFFE, 0x1)

}

void Set_HCLK(int freq){
	// 1. change to the temporary clock source if needed
	// 2. set the target clock source
	// 3. change to the target clock source

	//reset
	SET_REG(RCC->CFGR, 0x0, 0x0)

	//disable timer 7
	SET_REG(TIM7->CR1, 0xFFFFFFFE, 0x0)

	//disable PLL by setting PLLON to 0
	SET_REG(RCC->CR, 0xFEFFFFFF, 0x0)

	//wait until PLLRDY is cleared
	while (RCC->CR & 0x02000000);


	//change the desired parameter
	//(PLL clock input / PLLM) * PLLN / PLLR / AHB prescaler
	if(freq == 1){
		//PLLM = 1, PLLN = 16, PLLR = 4
		SET_REG(RCC->PLLCFGR, 0xF9FF808C, 0x2001001)
		//AHB prescaler = 16
		SET_REG(RCC->CFGR, 0xFFFFFF0F, 0xB0)
	}
	else if(freq == 6){
		//PLLM = 1, PLLN = 24, PLLR = 4
		SET_REG(RCC->PLLCFGR, 0xF9FF808C, 0x2001801)
		//AHB prescaler = 4
		SET_REG(RCC->CFGR, 0xFFFFFF0F, 0x90)
	}
	else if(freq == 10){
		//PLLM = 1, PLLN = 40, PLLR = 4
		SET_REG(RCC->PLLCFGR, 0xF9FF808C, 0x2002801)
		//AHB prescaler = 4
		SET_REG(RCC->CFGR, 0xFFFFFF0F, 0x90)
	}
	else if(freq == 16){
		//PLLM = 1, PLLN = 64, PLLR = 4
		SET_REG(RCC->PLLCFGR, 0xF9FF808C, 0x2004001)
		//AHB prescaler = 4
		SET_REG(RCC->CFGR, 0xFFFFFF0F, 0x90)

	}
	else if(freq == 40){
		//PLLM = 1, PLLN = 40, PLLR = 4
		SET_REG(RCC->PLLCFGR, 0xF9FF808C, 0x2002801)
		//AHB prescaler = 1
		SET_REG(RCC->CFGR, 0xFFFFFF0F, 0x0)
	}

	//wait until PLLRDY is not cleared
	while (!RCC->CR & 0x02000000);

	//enable the PLL again by setting PLLON to 1
	SET_REG(RCC->CR, 0xFEFFFFFF, 0x1000000)

	//enable the desires PLL outputs by configuring PLLREN
	SET_REG(RCC->PLLCFGR, 0xFEFFFFFF, 0x1000000)

	//set PLL as system clock
	SET_REG(RCC->CFGR, 0xFFFFFFFC, 0x3)

	// enable timer 7
	SET_REG(TIM7->CR1, 0xFFFFFFFE, 0x1)
}

void Delay1sUnder4MHz(){
	int timercount;
	while(1){
		timercount = TIM7->CNT & 0xFFFF;
		if(timercount >= 3999)
			break;
	}
	return;
}


void GPIO_init(){
	// enable GPIOA, GPIOC
	SET_REG(RCC->AHB2ENR, 0xFFFFFFFA, 0x5)

	// set PA5 as output mode
	SET_REG(GPIOA->MODER, 0xFFFFF3FF, 0x400)
	// set output speed register of PA5
	SET_REG(GPIOA->OSPEEDR, 0xFFFFF3FF, 0xC00)

	// set PC13 as input mode
	SET_REG(GPIOC->MODER, 0xF3FFFFFF, 0x0)
	// Set PC13_PUPDR as pull-up.
	SET_REG(GPIOC->PUPDR, 0xF3FFFFFF, 0x4000000)
}
