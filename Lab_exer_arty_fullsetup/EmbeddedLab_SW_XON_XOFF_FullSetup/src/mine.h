#ifndef MINE_H_
#define MINE_H_

#define N 16
#define XON 0x14
#define XOFF 0x15
#define DEL 0x10
#define THR_OFF N-3
#define THR_ON N-6

void receive_user(void), receive_channel(void), transmit_user(void), transmit_channel(void);

unsigned char buffer_tb[N], buffer_rb[N];

int i_w_tb, i_r_tb, i_w_rb, i_r_rb;
int count_tb, count_pr_tb, count_rb;
int busy_flag;

#endif
