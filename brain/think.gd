func init():
	instruction =  RegEx.new()
	port =  RegEx.new()
	instruction.compile("^add|sub|mul|div|aeq|anq|agt|alt|eps$")
	port.compile("^(a|b|c|d)$")

func add(op1: int ,op2: int) -> int:
	return op1 + op2

func sub(op1: int ,op2: int) -> int:
	return op1 - op2

func mul(op1: int ,op2: int) -> int:
	return op1 * op2	

func div(op1: int ,op2: int) -> int:
	return op1 / op2 if op2 != 0 else 0

func aeq(op1: int ,op2: int) -> int:
	return 1 if op1 == op2 else 0

func anq(op1: int ,op2: int) -> int:
	return 1 if op1 != op2 else 0

func agt(op1: int ,op2: int) -> int:
	return 1 if op1 > op2 else 0

func alt(op1: int ,op2: int) -> int:
	return 1 if op1 < op2 else 0
		
var instruction
var port


#compiles a SINGLE statement line
func compile(text):
	var instructions = []
	var arguments = []
	
	for lexem in text.split(" "):
		if instruction.search(lexem):
			instructions.append(lexem)
		elif port.search(lexem):
			arguments.append(lexem)
		else:
			arguments.append(lexem.to_int())
	return [instructions,arguments]

#executes a SINGLE statement line
func execute(instructions,arguments,ports):
	const THENARY = 3
	
	#deference the port if the argument is a pointer 
	for i in range(arguments):
		if arguments[i] is String:
			arguments[i] = ports[arguments[i]]
	
	#execute thenary
	if instructions.size() == THENARY:
		var decision = call(instruction[0],arguments[0],arguments[1])
		
		if decision != 0  and  instruction[1] != "eps":
			return call(instruction[1],arguments[2],arguments[3])
			
		elif decision == 0 and instruction[2] != "eps":
			var arg_idx = 2 + (0 if instruction[1] == "eps" else 2)
			return call(instruction[2],arguments[arg_idx],arguments[arg_idx+1])
	
	#execute unary
	else:
		if not instruction[0] == "eps":
			return call(instruction[0],arguments[0],arguments[1])
	
	#on fall-trough return null 
	return null
