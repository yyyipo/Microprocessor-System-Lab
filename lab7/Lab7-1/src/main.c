#include "stm32l476xx.h"
#define SET_REG(REG, MASK, VAL) {((REG)=((REG) & (MASK)) | (VAL));};

void GPIO_init ();
void SystemClock_Config ();
void SysTick_config ();
void SysTick_Handler ();

int main (){
	GPIO_init();
	SystemClock_Config();
	SysTick_config();
	while (1);
}

void GPIO_init () {
	// enable GPIOA
	SET_REG(RCC->AHB2ENR, 0xFFFFFFFE, 0x1)
	// set PA5 as output mode
	SET_REG(GPIOA->MODER, 0xFFFFF3FF, 0x400)
	// set output speed register of PA5
	SET_REG(GPIOA->OSPEEDR, 0xFFFFF3FF, 0xC00)

}

void SystemClock_Config () {
	// enable HSI16 clock
	SET_REG(RCC->CR, 0xFFFFFEFF, 0x100)
	//set the prescaler of system clock as 16
	SET_REG(RCC->CFGR, 0xFFFFFF0F, 0x80)
	//system clock switch, select HSI16 as system clock
	SET_REG(RCC->CFGR, 0xFFFFFFFC, 0x1)
}

void SysTick_config () {
	// trigger interrupt when counting down to zero
	SET_REG(SysTick->CTRL , 0xFFFFFFFD, 0x2)
	// set the reload value of SysTick as 250000
	SET_REG(SysTick->LOAD , 0xFF000000, 250000)
	// set the value of SysTick as 0
	//SET_REG(SysTick->VAL , 0xFF000000, 0x0)
	// counter enable
	SET_REG(SysTick->CTRL , 0xFFFFFFFE, 0x1)
}

void SysTick_Handler () {
	if((GPIOA->ODR & 0x20) == 0){
		SET_REG(GPIOA->ODR, 0xFFDF, 0x20)
	}
	else{
		SET_REG(GPIOA->ODR, 0xFFDF, 0x0)
	}
}



