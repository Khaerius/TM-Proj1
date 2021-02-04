.PORT int_mask, 0xE1
.PORT int_status, 0xE0
.PORT joyl, 0x21 		; Pmod B (gorny)
.PORT joyl_dir, 0x29 		
.PORT joyl_status, 0xE2
.PORT joyl_mask, 0xE4
.PORT leds, 0x00
.REG sF, t1
.REG sE, t2
.REG sD, t3
.REG sC, t4
.REG s3, count
.REG s4, tmp
.REG sB, joymove


LOAD s2, 0b00001011
OUT s2, joyl_dir

loop:		
		CALL cycle
		JUMP loop
		
do_step:
		CALL sck_1
		CALL sck_0
		RET
		
sck_1:
		IN tmp, joyl
		OR tmp, 8
		OUT tmp, joyl
		CALL sleep_100us
		RET
		
sck_0:
		IN tmp, joyl
		AND tmp, 0b11110111
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
		LOAD tmp, 1
		OUT tmp, joyl
		OUT joymove, leds
		RET

saveFirstPos:
	IN tmp, joyl
	LOAD joymove, 0
	AND tmp, 0b00000100
	SR0 tmp
	ADD joymove, tmp
	RET

saveSecPos:
	IN tmp, joyl
	AND tmp, 0b00000100
	SR0 tmp
	SR0 tmp
	ADD joymove, tmp
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
