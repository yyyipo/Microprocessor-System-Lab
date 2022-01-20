#include "stm32l476xx.h"
#define TIME_SEC 7.63
#define SET_REG(REG, MASK, VAL) {((REG)=((REG) & (MASK)) | (VAL));};

extern void GPIO_init();
extern void max7219_init();
extern void max7219_send();
int display();
void max7219_clear();

void Timer_init (){
	// TODO : Initialize timer

	//time event every 0.01 sec, and we can count the time by ourselves
	// enable timer5
	SET_REG(RCC->APB1ENR1, 0xFFFFFFF7, 0x8)
	// set the prescaler of timer5(999+1)
	SET_REG(TIM5->PSC, 0xFFFF0000, 0x3E7)
	// reload value(39+1)
	SET_REG(TIM5->ARR, 0x0, 0x27)
	// event generation register(set UG as 1,  Re-initialize the counter and generates an update of the registers.)
	SET_REG(TIM5->EGR, 0xFFFFFFFE, 0x1)
	// set timer 5 as up-counter
	SET_REG(TIM5->CR1, 0xFFFFFFEF, 0x10)
	// timer 5 counter enable, start counting
	SET_REG(TIM5->CR1, 0xFFFFFFFE, 0x1)
}

/*TIM_TypeDef *timer*/
void Timer_start (){
	// TODO : start timer and show the time on the 7-SEG LED.
}

int main (){
	int timercount, time;

	time = 0;
	GPIO_init();
	max7219_init();
	Timer_init();
	//Timer_start();
	max7219_clear();
	while (time <= TIME_SEC * 100 + 0.5){
		// TODO : Polling the timer count and do lab requirements
		display(time);

		while(1){
			timercount = TIM5->CNT & 0xFFFFFFF;
			if(timercount >= 39){
				time++;
				break;
			}
		}
	}
}


int display(int data){
	int i, display_num;

	if(data < 100){
		for(i = 1; i <= 2; i++){
			display_num = data % 10;
			data = data / 10;

			max7219_send(i, display_num);
		}
		max7219_send(i, 128);	//128 means "0."
	}

	else{
		for(i = 1; i <= 7; i++){
			display_num = data % 10;
			data = data / 10;

			if(i == 3){
				display_num += 128;	//show the point
			}

			max7219_send(i, display_num);

			if(data == 0){
				break;
			}
		}
	}

	return 0;
}

void max7219_clear(){
	int i;
	for(i = 1; i <= 7; i++){
		max7219_send(i, 0xf);
	}
	return;
}
