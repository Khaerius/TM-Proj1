.PORT int_mask, 0xE1
.PORT int_status, 0xE0
.PORT joy, 0x21 		; Pmod B
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


LOAD s2, 0b00000100
;LOAD s2, 255
IN s2, joy_dir

loop:		
		LOAD b, 0
		OUT b, joy
		CALL sleep_1s
		CALL do_step
		CALL do_step
		CALL do_step
		CALL do_step
		CALL do_step
		CALL do_step
		CALL do_step
		CALL do_step
		CALL do_step
		JUMP loop
		
do_step:
		CALL en
		CALL sck_1
		CALL dis
		CALL sck_0
		IN a, joy
		OUT a, leds
		RET
		
en:
		;ADD b, 4
		OUT b, joy
		CALL sleep_10ms
		RET
		
dis:
		;SUB b, 4
		OUT b, joy
		CALL sleep_10ms
		RET
		
sck_1:
		ADD b, 8
		OUT b, joy
		CALL sleep_10ms
		RET
		
sck_0:
		SUB b, 8
		OUT b, joy
		CALL sleep_10ms
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
		