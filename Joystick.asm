.PORT int_mask, 0xE1
.PORT int_status, 0xE0
.PORT joy, 0x21 		; Pmod B (gorny)
.PORT joy_dir, 0x29 		
.PORT joy_status, 0xE2
.PORT joy_mask, 0xE4
.PORT leds, 0x00
.REG sF, t1
.REG sE, t2
.REG sD, t3
.REG sC, t4
.REG s0, a
.REG s1, b
.REG s3, count
.REG s4, tmp
.REG sB, joymove


LOAD s2, 0b00001011
OUT s2, joy_dir

loop:		
		CALL cycle
		JUMP loop
		
do_step:
		CALL sck_1
		CALL sck_0
		RET
		
sck_1:
		IN b, joy
		OR b, 8
		OUT b, joy
		CALL sleep_10ms
		RET
		
sck_0:
		IN b, joy
		AND b, 0b11110111
		OUT b, joy
		CALL sleep_10ms
		RET

cycle:
		LOAD b, 0
		OUT b, joy
		CALL sleep_10ms
		LOAD count, 40
	read:
 		CALL do_step
		COMP count, 10
		JUMP Z, saveFirstPos
		COMP count, 9
		JUMP Z, saveSecPos
		SUB count, 1
		JUMP NZ, read
		LOAD b, 1
		OUT b, joy
		OUT joymove, leds
		RET

saveFirstPos:
	IN tmp, joy
	TEST tmp, 4
	LOAD joymove, NZ
	RET

saveSecPos:
	IN tmp, joy
	TEST tmp, 4
	LOAD joymove, NZ
	RET
;EINT
;loop: CALL loop


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
		
sleep_10ms:
 		LOAD t3, 98
wait_3:
 		CALL sleep_100us
		SUB t3, 1
		JUMP NZ, wait_3
		RET
		
sleep_1s:
 		LOAD t4, 98
wait_4:
 		CALL sleep_10ms
		SUB t4, 1
		JUMP NZ, wait_4
		RET
