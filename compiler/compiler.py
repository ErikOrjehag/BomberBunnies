import sys

file_name = sys.argv[1]
ln = 0
index = 0
program = ''
lables = {}

OPS = [
	"load",  # 0
	"store", # 1
	"add",   # 2
	"sub",   # 3
	"jump",  # 4
	"sleep", # 5
	"beq",   # 6
	"bne"    # 7
]

MM_DIRECT = 0
MM_IMMEDIATE = 1
MM_DIRECT = 2
MM_INDEXED = 3

def put_line(line, comment=''):
	global ln
	if comment:
		comment = ' -- ' + comment
	print(str(ln).rjust(4, ' ') + ' => \"' + line + '\",' + comment)
	ln += 1

def put_instr(op, grx, m, addr):
	gr_actual = grx if grx != -1 else 0
	line = to_bin(OPS.index(op), 5) + '_' + to_bin(gr_actual, 3) + '_' + to_bin(m, 2) + '_' + to_bin(addr, 12)
	gr_comment = '' if grx == -1 else ' gr' + str(grx)
	put_line(line, op + gr_comment)

def put_data(integer):
	line = to_bin(integer, 22)
	put_line(split_line(line), str(integer))

def put_label(label):
	label_ln = get_label_ln(label)
	line = to_bin(label_ln, 22)
	put_line(split_line(line), label + ' ' + str(label_ln))

def split_line(line):
	return line[0:5] + '_' + line[5:8] + '_' + line[8:10] + '_' + line[10:22]

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

def is_label(token):
	return token[-1] == ':'

def store_label(label):
	global ln
	global lables
	lables[label] = ln

def get_label_ln(label):
	return lables[label]

def grx_to_int(grx):
	return int(grx[-1])

with open(file_name) as f:
	program = ''.join(f.readlines())

while True:
	token = next_token()
	if token == '':
		exit()
	elif is_label(token):
		store_label(token[0:-1])
	else:
		if token == "sleep":
			put_instr("sleep", -1, MM_IMMEDIATE, next_ln())
			duration = next_token()
			put_data(int(duration))

		elif token == "add":
			grx = next_token()
			integer = next_token()
			put_instr("add", grx_to_int(grx), MM_DIRECT, next_ln())
			put_data(int(integer))

		elif token == "jump":
			put_instr("jump", -1, MM_IMMEDIATE, next_ln())
			label = next_token()
			put_label(label)


