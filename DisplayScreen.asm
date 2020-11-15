.PORT uart0, 0x60
.PORT uart0_status, 0x61
.PORT uart0_mask, 0x62
.PORT int_mask, 0xE1
.PORT int_status, 0xE0
.REG s1, ball
.REG s4, counterx
.REG s5, countery
.REG s0, zero
.REG sF, flag
.CONST finish, 68

.DSEG
space: .DB " --------------------- ",13,10, "                     ",13,10,"                     ",13,10,"                     ",13,10," --------------------- ",2


.CSEG
LOAD s7, 0b00000100
LOAD s6, 0b00000001
LOAD zero, 0
OUT s7, int_mask
EINT
LOAD ball, 52
LOAD counterx, 0
LOAD countery, 0
LOAD s2, space
OUT s6, uart0_mask
loop: JUMP loop


int: FETCH s3, s2
			COMP s3, 2
			JUMP Z, mask
			COMP counter, ball
			CALL Z, drawball 
			OUT s3, uart0
			end: ADD s2, 1
			ADD counter, 1
			OUT zero, int_status
			RETI

mask: OUT zero, uart0_mask
JUMP end

drawball: LOAD s3, 'o'
RET

.CSEG 0x3FF
JUMP int