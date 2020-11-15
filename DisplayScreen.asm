.PORT uart0, 0x60
.PORT uart0_status, 0x61
.PORT uart0_mask, 0x62
.PORT int_mask, 0xE1
.PORT int_status, 0xE0
.REG s1, ballx
.REG s2, string
.REG s3, char
.REG s8, bally
.REG s9, leftpad
.REG sA, rightpad
.REG s4, counterx
.REG s5, countery
.REG s0, zero
.REG sF, flag
.CONST finish, 68

.DSEG
ceiling: .DB "-----------------------------------------",13,10
space: .DB "                                         ",13,10
floor: .DB "-----------------------------------------[H",10


.CSEG
LOAD s7, 0b00000100
LOAD s6, 0b00000001
LOAD zero, 0
OUT s7, int_mask
EINT
LOAD ballx, 20
LOAD bally, 12
LOAD leftpad, 12
LOAD rightpad, 12
LOAD counterx, 0
LOAD countery, 0
LOAD string, ceiling
OUT s6, uart0_mask
loop: JUMP loop


int: FETCH char, string
			COMP char, 10
			JUMP Z, nxverse
			COMP counterx, ballx
			CALL Z, drawball
			COMP counterx, 0
			CALL Z, drawlpad
			COMP counterx, 40
			CALL Z, drawrpad 
			OUT char, uart0
			ADD string, 1
			ADD counterx, 1
			end: OUT zero, int_status
			RETI

nxverse: ADD countery, 1
LOAD counterx, 0
COMP countery, 23
JUMP NZ, endif
LOAD string, floor
JUMP end
endif: COMP countery, 24
JUMP NZ, endt
LOAD countery, 0
LOAD string, ceiling
JUMP end
endt: LOAD string, space
JUMP end

drawball: COMP countery, bally
JUMP NZ, skip
LOAD char, 'o'
skip: RET

drawlpad: COMP countery, leftpad
JUMP NZ, skip
LOAD char, '|'
RET

drawrpad: COMP countery, rightpad
JUMP NZ, skip
LOAD char, '|'
RET

.CSEG 0x3FF
JUMP int