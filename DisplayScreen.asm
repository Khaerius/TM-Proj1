.PORT uart0, 0x60
.PORT uart0_status, 0x61
.PORT uart0_mask, 0x62
.PORT int_mask, 0xE1
.PORT int_status, 0xE0
.REG s1, ballx
.REG s2, string
.REG s3, char
.REG s4, counterx
.REG s5, countery
.REG s6, tmp
.REG s8, bally
.REG s9, leftpad
.REG sA, rightpad
.REG sB, scorep1
.REG sC, scorep2
.REG sF, flagdir
.CONST finish, 68
.CONST zero, 0

.DSEG
ceiling: .DB "-----------------------------------------",13,10
space: .DB "                                         ",13,10
floor: .DB "-----------------------------------------[H",10


.CSEG
LOAD s7, 0b00000100
LOAD tmp, 0b00000001
OUT s7, int_mask
EINT
LOAD ballx, 20
LOAD bally, 12
LOAD leftpad, 12
LOAD rightpad, 12
LOAD counterx, zero
LOAD countery, zero
LOAD flagdir, zero
LOAD scorep1, zero
LOAD scorep2, zero
LOAD string, ceiling
OUT tmp, uart0_mask
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
			LOAD tmp, zero
			end: OUT tmp, int_status
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
CALL checkpos
CALL moveball
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

checkpos: COMP bally, 1
JUMP Z, checkcontu
COMP bally, 23
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
ADD scorep2, 1
LOAD ballx, 20
LOAD bally, 12
RET
elsea: ADD scorep1, 1
LOAD ballx, 20
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

.CSEG 0x3FF
JUMP int