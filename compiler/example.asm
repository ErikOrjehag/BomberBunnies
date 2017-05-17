SETGRASS:
	load	gr1	GRASS
	jump	BEGIN

SETWALL:
	load	gr1 WALL

BEGIN:
	load	gr0	0

LOOP:
	tpoint	gr0
	twrite	gr1
	add     gr0 1
	btn1	SETGRASS
	btn2	SETWALL
	jump	LOOP


GRASS:
	0

WALL:
	1