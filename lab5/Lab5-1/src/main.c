//These functions inside the asm file
#include <math.h>
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
/**
* TODO: Show data on 7-seg via max7219_send
* 	Input:
* 		data: decimal value
* 		num_digs: number of digits will show on 7-seg
* 	Return:
* 		0: success
* 		-1: illegal data range(out of 8 digits range)
*/
int display(int data, int num_digs){
	unsigned char display_num;
	for( unsigned char i=1; i<=7; i++){
		display_num=data%10;
		data=data/10;
		max7219_send(i, display_num);
	}

	if(data>=pow(10, num_digs))
		return -1;
	else
		return 0;
}
int main(){
	int student_id = 716052;
	GPIO_init();
	max7219_init();
	display(student_id, 8);

	return 0;
}
