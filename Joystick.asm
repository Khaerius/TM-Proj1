.PORT int_mask, 0xE1
.PORT int_status, 0xE0
.PORT joy, 0x21
.PORT joy_status, 0xE2
.PORT joy_mask, 0xE4

LOAD s1, 0b01000000
LOAD s2, 0b00011000
LOAD s0, 0
OUT s1, int_mask
OUT s2, joy_mask
EINT