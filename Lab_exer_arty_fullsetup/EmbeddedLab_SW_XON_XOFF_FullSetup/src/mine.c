/*
 * mine.c
 *
 *  Created on: Jun 2, 2019
 *      Author: lefteris
 */

#include "UART.h"
#include "mine.h"

unsigned char *r = (unsigned char*) UART1_RTS_ADDR;
unsigned char *c = (unsigned char*) UART1_CTS_ADDR;

int flag=0;
int xoff_flag=0;

void transmit_user(void){
	if(count_tb != N-1){
		buffer_tb[i_w_tb] = (unsigned char)(RxBuffer_1[0]);
		i_w_tb++;
		if(i_w_tb == N) i_w_tb = 0;
		count_pr_tb = count_tb;
		count_tb++;
		if(count_tb == N-1){
			*r = 0x01;
		}
	}
}

void transmit_channel(void){
	unsigned char del = DEL;
	unsigned char xoff = XOFF;
	unsigned char xon = XON;

	if(count_rb>=THR_OFF && !xoff_flag){
		XUartLite_Send(&UART_Inst_Ptr_2, &xoff, 1);
		xoff_flag = 1;
		return;
	}
	else{
		if(count_rb<=THR_ON && xoff_flag){
			XUartLite_Send(&UART_Inst_Ptr_2, &xon, 1);
			xoff_flag = 0;
			return;
		}
	}
	if(buffer_tb[i_r_tb] == XON || buffer_tb[i_r_tb] == XOFF || buffer_tb[i_r_tb] == DEL){
		XUartLite_Send(&UART_Inst_Ptr_2, &del, 1);
		buffer_tb[i_r_tb] ^= 0x20;
	}
	XUartLite_Send(&UART_Inst_Ptr_2, buffer_tb + sizeof(unsigned char)*i_r_tb, 1);
	i_r_tb++;
	if(i_r_tb == N) i_r_tb = 0;
	count_pr_tb = count_tb;
	count_tb--;
}

void receive_user(void){
	XUartLite_Send(&UART_Inst_Ptr_1, buffer_rb + sizeof(unsigned char)*i_r_rb, 1);
	i_r_rb++;
	if(i_r_rb == N) i_r_rb = 0;
	count_rb--;
}

void receive_channel(void){
	if(RxBuffer_2[0] == DEL) flag = 1;
	else{
		if(flag){
			RxBuffer_2[0] ^= 0x20;
			flag = 0;
		}
		else{
			if(RxBuffer_2[0] == XOFF){
				busy_flag=1;
				return;
			}
			else{
				if(RxBuffer_2[0] == XON){
					busy_flag=0;
					return;
				}
			}
		}
		buffer_rb[i_w_rb] = RxBuffer_2[0];
		i_w_rb++;
		if(i_w_rb == N) i_w_rb = 0;
		count_rb++;
	}
}
