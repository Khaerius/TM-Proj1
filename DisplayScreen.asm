.PORT uart0, 0x60
.PORT uart0_status, 0x61
.PORT uart0_mask, 0x62
.PORT int_mask, 0xE1
.PORT int_status, 0xE0
 .PORT joy, 0x11
 .PORT joy_mask, 0x12
.PORT joyl, 0x21 		; Pmod B (gorny)
.PORT joyl_dir, 0x29
.PORT joyl_status, 0xE3
.PORT joyl_mask, 0xE5
.REG s0, joymove
.REG s1, ballx
.REG s2, string
.REG s3, char
.REG s4, counterx
.REG s5, countery
.REG s6, tmp
.REG s7, count
.REG s8, bally
.REG s9, leftpad
.REG sA, rightpad
.REG sB, t1
.REG sC, t2
.REG sD, isLeftPad
.REG sF, flagdir
.CONST finish, 68
.CONST zero, 0

.DSEG
ceiling: .DB "-----------------------------------------",10,13,99
space: .DB "                                         ",10,13,99
floor: .DB "-----------------------------------------",27,"[H",10,13,99


.CSEG
LOAD tmp, 0b01000101 
OUT tmp, int_mask
LOAD tmp, 0b00111100
OUT tmp, joy_mask
LOAD tmp, 0b00011000
OUT tmp, joyl_mask
LOAD tmp, 0b10110000
OUT tmp, joyl_dir
EINT
LOAD ballx, 20
LOAD bally, 12
LOAD leftpad, 12
LOAD rightpad, 12
LOAD counterx, zero
LOAD countery, zero
LOAD flagdir, zero
LOAD string, ceiling
LOAD tmp, 1
LOAD isLeftPad, 1
OUT tmp, uart0_mask
loop: 
TEST isLeftPad, 1
CALL NZ, moveLeftPad
JUMP loop


int: 
IN tmp, int_status
		TEST tmp, 1
		JUMP NZ, movePad
print: FETCH char, string
			COMP char, 99
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
			end: LOAD tmp, zero
			OUT tmp, int_status
			RETI

checkBoundR:
	COMP rightpad, 255
	JUMP NZ, checkLowR
	LOAD rightpad, 23
	RET
	checkLowR:
		COMP rightpad, 23
		JUMP NZ, endCheck
		LOAD rightpad, 0
	endCheck:
		RET

checkBoundL:
	COMP leftpad, 255
	JUMP NZ, checkLowL
	LOAD leftpad, 23
	RET
	checkLowL:
		COMP leftpad, 23
		JUMP NZ, endCheck
		LOAD leftpad, 0
		RET

movePad:
		IN tmp, joy
  		TEST tmp, 4
 		JUMP Z, isDown
		SUB rightpad, 1
 		isDown: 
			TEST tmp, 16
			JUMP Z, endMovePad
			ADD rightpad, 1

		endMovePad:
			CALL checkBoundR
			IN tmp, int_mask
			AND tmp, 0b11111110	; turn off joystick interrupts
			OUT tmp, int_mask
		JUMP end

moveLeftPad:
	CALL cycle
	TEST joymove, 2
	JUMP Z, isLeftDown
	SUB leftpad, 1
	JUMP endMoveLeftPad
	isLeftDown:
		TEST joymove, 1
		JUMP NZ, endMoveLeftPad
		ADD leftpad, 1
		endMoveLeftPad:
		CALL checkBoundL
		LOAD isLeftPad, 0
		RET

nxverse: ADD countery, 1
LOAD counterx, 0
COMP countery, 23
JUMP NZ, endif
LOAD string, floor
JUMP end
endif: COMP countery, 24
JUMP NZ, endt
CALL prepareNextIteration
endt: LOAD string, space
JUMP end

prepareNextIteration:
		LOAD countery, 0
		LOAD string, ceiling
		CALL checkpos
		CALL moveball
		IN tmp, int_mask
		OR tmp, 1	; turn on joystick interrupts
		OUT tmp, int_mask
		LOAD isLeftPad, 1
		RET

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

checkpos: COMP bally, 0
JUMP Z, checkcontu
COMP bally, 22
JUMP Z, checkcontd
COMP ballx, 1
JUMP Z, checkcontl
COMP ballx, 39
JUMP Z, checkcontr
RET

checkcontl: COMP bally, leftpad
JUMP NZ, addpoint
COMP flagdir, 2
JUMP NZ, elsel
LOAD flagdir, 1
RET
elsel: LOAD flagdir, 0
RET

checkcontr: COMP bally, rightpad
JUMP NZ, addpoint
COMP flagdir, 1
JUMP NZ, elser
LOAD flagdir, 2
RET
elser: LOAD flagdir, 3
RET

addpoint: COMP ballx, 1
JUMP NZ, elsea
LOAD ballx, 20
LOAD bally, 12
RET
elsea: LOAD ballx, 20
LOAD bally, 12
RET

checkcontu: COMP flagdir, 0
JUMP NZ, elseu
LOAD flagdir, 1
RET
elseu: LOAD flagdir, 2
RET

checkcontd: COMP flagdir, 1
JUMP NZ, elsed
LOAD flagdir, 0
RET
elsed: LOAD flagdir, 3
RET

moveball: COMP flagdir, 0
JUMP NZ, else
ADD ballx, 1
SUB bally, 1
else: COMP flagdir, 1
JUMP NZ, else2
ADD ballx, 1
ADD bally, 1
else2: COMP flagdir, 2
JUMP NZ, else3
SUB ballx, 1
ADD bally, 1
else3: COMP flagdir, 3
JUMP NZ, skip
SUB ballx, 1
SUB bally, 1
RET

do_step:
		CALL sck_1
		CALL sck_0
		RET
		
sck_1:
		IN tmp, joyl
		OR tmp, 0b10000000
		OUT tmp, joyl
		CALL sleep_100us
		RET
		
sck_0:
		IN tmp, joyl
		AND tmp, 0b01111111
		OUT tmp, joyl
		CALL sleep_100us
		RET

cycle:
		LOAD tmp, 0
		OUT tmp, joyl
		CALL sleep_100us
		LOAD count, 40
	read:
 		CALL do_step
		COMP count, 11
		CALL Z, saveFirstPos
		COMP count, 10
		CALL Z, saveSecPos
		SUB count, 1
		JUMP NZ, read
		LOAD tmp, 1 << 4
		OUT tmp, joyl
		;OUT joymove, leds
		RET

saveFirstPos:
	IN tmp, joyl
	LOAD joymove, 0
	AND tmp, 0b01000000
	SR0 tmp
	SR0 tmp
	SR0 tmp
	SR0 tmp
	SR0 tmp
	ADD joymove, tmp
	RET

saveSecPos:
	IN tmp, joyl
	AND tmp, 0b01000000
	SR0 tmp
	SR0 tmp
	SR0 tmp
	SR0 tmp
	SR0 tmp
	SR0 tmp
	ADD joymove, tmp
	RET

sleep_1us:
 		LOAD t1, 24
wait_1:
 		SUB t1, 1
		JUMP NZ, wait_1
		RET
		
sleep_100us:
 		LOAD t2, 98
wait_2:
 		CALL sleep_1us
		SUB t2, 1
		JUMP NZ, wait_2
		RET

.CSEG 0x3FF
JUMP int
