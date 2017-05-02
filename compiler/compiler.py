import sys

file_name = sys.argv[1]
ln = 0
index = 0
program = ''
lables = {}
output = ''

OPS = [
	"load",   #  0
	"store",  #  1
	"add",    #  2
	"sub",    #  3
	"jump",   #  4
	"sleep",  #  5
	"beq",    #  6
	"bne",    #  7
	"",       #  8
	"",       #  9
	"",       # 10
	"",       # 11
	"",       # 12
	"",       # 13
	"twrite", # 14
	"tread",  # 15
	"tpoint", # 16
	"joy1r",  # 17
	"joy1u",  # 18
	"joy1l",  # 19
	"joy1d",  # 20
	"btn1",   # 21
	"joy2r",  # 22
	"joy2u",  # 23
	"joy2l",  # 24
	"joy2d",  # 25
	"btn2"    # 26
]

MM_DIRECT = 0
MM_IMMEDIATE = 1
MM_INDIRECT = 2
MM_INDEXED = 3

def outp(text):
	global output
	output += (text + "\n")

def put_line(line, comment=''):
	global ln
	if comment:
		comment = ' -- ' + comment
	outp(str(ln).rjust(4, ' ') + ' => b\"' + line + '\",' + comment)
	ln += 1

def put_instr(op, grx, mm, addr):
	grx_actual = grx if grx != None else 0
	mm_actual = mm if mm != None else 0
	addr_actual = addr if addr != None else 0
	line = to_bin(OPS.index(op), 5) + to_bin(grx_actual, 4) + to_bin(mm_actual, 2) + to_bin(addr_actual, 12)
	grx_comment = '' if grx == None else ' gr' + str(grx)
	put_line(split_line(line), op + grx_comment)

def put_data(integer):
	line = to_bin(integer, 23)
	put_line(split_line(line), str(integer))

def put_label(label):
	#label_ln = get_label_ln(label)
	#line = to_bin(label_ln, 23)
	#put_line(line, label + ' ' + str(label_ln))
	put_line(label)

def split_line(line):
	return line[0:5] + '_' + line[5:9] + '_' + line[9:11] + '_' + line[11:23]

def to_bin(integer, fill):
	return ('{0:b}'.format(integer)).zfill(fill)

def next_ln():
	return ln + 1

def next_char():
	global index
	if index < len(program):
		character = program[index]
		index += 1
		return character
	else:
		return ''

def next_token():
	token = ''
	while True:
		character = next_char()
		if character == '':
			return token
		elif token != '' and character in [' ', '\t','\n']:
			return token
		elif character not in [' ', '\t', '\n']:
			token += character

def is_op(token):
	return token in OPS

def is_data(token):
	if token[0] in ('-', '+'):
		return token[1:].isdigit()
	return token.isdigit()

def is_label(token):
	return token[-1] == ':'

def store_label(label):
	global ln
	global lables
	lables[label] = ln

def get_label_ln(label):
	return lables[label]

def grx_to_int(grx):
	return int(grx[-1]) if len(grx) == 3 else int(grx[-2:])

def unexpected(token):
	print("ERROR: Unexpected token `" + token + "` on line " + str(ln))
	exit(1)

def branch_instr(op):
	put_instr(op, None, MM_IMMEDIATE, None)
	label = next_token()
	put_label(label)

def tile_instr(op):
	grx = next_token()
	put_instr(op, grx_to_int(grx), None, None)

def math_instr(op):
	grx = next_token()
	integer = next_token()
	put_instr(op, grx_to_int(grx), MM_IMMEDIATE, None)
	put_data(int(integer))

with open(file_name) as f:
	program = ''.join(f.readlines())

# Compile program
while True:
	token = next_token()
	if token == '':
		break
	elif is_label(token):
		store_label(token[0:-1])
	elif is_data(token):
		put_data(int(token))
	elif is_op(token):
		if token == "load":
			grx = next_token()
			put_instr("load", grx_to_int(grx), MM_IMMEDIATE, None)
			integer = next_token()
			put_data(int(integer))

		elif token == "store":
			label = next_token()
			grx = next_token()
			put_instr("store", grx_to_int(grx), MM_IMMEDIATE, None)
			put_label(label)

		elif token == "sleep":
			put_instr("sleep", None, MM_IMMEDIATE, None)
			duration = next_token()
			put_data(int(duration))

		elif token == "add": math_instr("add")
		elif token == "sub": math_instr("sub")

		elif token == "twrite": tile_instr("twrite")
		elif token == "tread" : tile_instr("tread")
		elif token == "tpoint": tile_instr("tpoint")

		elif token == "jump": branch_instr("jump")
		elif token == "beq"  : branch_instr("beq")
		elif token == "bne"  : branch_instr("bne")
		elif token == "joy1r": branch_instr("joy1r")
		elif token == "joy1u": branch_instr("joy1u")
		elif token == "joy1l": branch_instr("joy1l")
		elif token == "joy1d": branch_instr("joy1d")
		elif token == "btn1" : branch_instr("btn1")
		elif token == "joy2r": branch_instr("joy2r")
		elif token == "joy2u": branch_instr("joy2u")
		elif token == "joy2l": branch_instr("joy2l")
		elif token == "joy2d": branch_instr("joy2d")
		elif token == "btn2" : branch_instr("btn2")

	else:
		unexpected(token)

# Labels
for label, line_num in lables.iteritems():
	output = output.replace(label, split_line(to_bin(line_num, 23)))

print(output)


