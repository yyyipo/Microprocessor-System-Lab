#include "stm32l476xx.h"

//TODO: define your gpio pin
#define X0 0b1000000	//PB6
#define X1 0b10000000	//PB7
#define X2 0b100000000	//PB8
#define X3 0b1000000000	//PB9
#define Y0 0b100		//PC2
#define Y1 0b1000		//PC3
#define Y2 0b10000		//PC4
#define Y3 0b100000		//PC5

#define SET_REG(REG, MASK, VAL) {((REG)=((REG) & (~(MASK))) | (VAL));};

//These functions inside the asm file
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);

void keypad_init1();
void keypad_init2();
char keypad_scan();
int display(char data, char num_digs);

unsigned int x_pin[4] = {X0, X1, X2, X3};
unsigned int y_pin[4] = {Y0, Y1, Y2, Y3};

char table[4][4] = {1, 2, 3, 10,
					4, 5, 6, 11,
					7, 8, 9, 12,
					15, 0, 14, 13};
char press[4][4] = {0, 0, 0, 0,
					0, 0, 0, 0,
					0, 0, 0, 0,
					0, 0, 0, 0};




int main(){
	char pressed_num;

	GPIO_init();
	max7219_init();
	//keypad_init1();

	while(1){
		pressed_num = keypad_scan();
		display(pressed_num, 2);
	}

	return 0;
}


/* TODO: scan keypad value
return: >=0: key-value pressed¡A-1: keypad is free
*/
 char keypad_scan(){

	int key_val, key_flag, read_val;
	char sum;

	key_flag = -1;
	sum = 0;
	for(int i = 0; i < 4; i++){
		for(int j = 0; j < 4; j++){
			press[i][j] = 0;
		}
	}

	keypad_init1();
	for(int i = 0; i < 4; i++){
		SET_REG(GPIOB->ODR, 0x3C0, x_pin[i])

		for(int j = 0; j < 4; j++){
			read_val = GPIOC->IDR & y_pin[j];

			if(read_val != 0){
				key_flag = 1;
				press[j][i] = 1;
			}
		}
	}

	keypad_init2();
	for(int i = 0; i < 4; i++){
		SET_REG(GPIOC->ODR, 0x3C, y_pin[i])

		for(int j = 0; j < 4; j++){
			read_val = GPIOB->IDR & x_pin[j];

			if(read_val != 0){
				key_flag = 1;
				press[i][j] = 1;
			}
		}
	}


	for(int i = 0; i < 4; i++){
		for(int j = 0; j < 4; j++){
			if(press[i][j] == 1)
				sum += table[i][j];
		}
	}

	if(key_flag == -1)
		sum = -1;

	return sum;
}


int display(char data, char num_digs){
	if(data == 255){
		max7219_send(1, 0xf);
		max7219_send(2, 0xf);
	}

	else if(data <= 9){
			max7219_send(1, data);
			max7219_send(2, 0xf);
	}
	else{
		max7219_send(1, data % 10);
		max7219_send(2, data / 10);
	}
	return 0;
}


/* TODO: initial keypad gpio pin, X as output and Y as input */
void keypad_init1(){
	// enable GPIOB
	SET_REG(RCC->AHB2ENR, RCC_AHB2ENR_GPIOBEN, RCC_AHB2ENR_GPIOBEN)
	//set pins PB6-9 as output mode
	SET_REG(GPIOB->MODER, 0x000FF000, 0x55000)
	// Set output speed register
	SET_REG(GPIOB->OSPEEDR, 0x000FF000, 0xFF000)

	// enable GPIOC
	SET_REG(RCC->AHB2ENR, RCC_AHB2ENR_GPIOCEN, RCC_AHB2ENR_GPIOCEN)
	//set pins PC2-5 as input mode
	SET_REG(GPIOC->MODER, 0x00000FF0, 0x0)
	// Keep PUPDR of pins PC2-5 as pull-down
	SET_REG(GPIOC->PUPDR, 0x00000FF0, 0xAA0)
	// Set output speed register
	SET_REG(GPIOC->OSPEEDR, 0x00000FF0, 0xFF0)
}

void keypad_init2(){
	// enable GPIOB
	SET_REG(RCC->AHB2ENR, RCC_AHB2ENR_GPIOBEN, RCC_AHB2ENR_GPIOBEN)
	//set pins PB6-9 as input mode
	SET_REG(GPIOB->MODER, 0x000FF000, 0x0)
	// Keep PUPDR of pins PB6-9 as pull-down
	SET_REG(GPIOB->PUPDR, 0x000FF000, 0xAA000)
	// Set output speed register
	SET_REG(GPIOB->OSPEEDR, 0x000FF000, 0xFF000)

	// enable GPIOC
	SET_REG(RCC->AHB2ENR, RCC_AHB2ENR_GPIOCEN, RCC_AHB2ENR_GPIOCEN)
	//set pins PC2-5 as output mode
	SET_REG(GPIOC->MODER, 0x00000FF0, 0x550)
	// Set output speed register
	SET_REG(GPIOC->OSPEEDR, 0x00000FF0, 0xFF0)
}

