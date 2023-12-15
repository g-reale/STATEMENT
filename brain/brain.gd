extends Control

const neuronScene = preload("res://brain/neuron.tscn")

var lenght = 2
var height = 1
var neuron_amount = lenght * height
const block_size = 20 
const padding = Vector2(10,10)
const sinapses = ["a","b","c","d"]

var inner_focused = false
var inner_focus = Vector2(0,0)
var focused_state
var focused_neuron

var pc = Vector2(0,0)
var pointed_neuron
var pointed_state
var neurons = []
var states = []

var instruction
var port

signal send(text)
signal vote(value)
signal highlight(line)
signal yielded(result)

func _ready():
	#regexes for compilation
	instruction =  RegEx.new()
	port =  RegEx.new()
	instruction.compile("^add|sub|mul|div|aeq|anq|agt|alt|eps$")
	port.compile("^(a|b|c|d)$")

func alloc(brain_lenght,brain_height):
	lenght = brain_lenght
	height = brain_height
	
	#neuron instantiation
	var offset = self.position
	var delta_x = Vector2(2*block_size + padding.x,0)
	var delta_y = Vector2(0,2*block_size + padding.y) 
	
	for line in range(height):
		neurons.append([])	
		states.append([])
		
		for col in range(lenght):
			var neuron = neuronScene.instantiate()
			add_child(neuron)
			neuron.set_block_size(Vector2(block_size,block_size))
			neuron.set("position",offset)
			print(offset)
			neurons[line].append(neuron)
			
			states[line].append({"inner_pc": 0, 
						   		 "text": "eps\neps\neps\neps",
								 "accepted": true,
								 "instructions": {"a":["eps"],"b":["eps"],"c":["eps"],"d":["eps"]},
								 "arguments": {"a":[],"b":[],"c":[],"d":[]},
								 "ports": {"a":0,"b":0,"c":0,"d":0}})
			
			offset = offset + delta_x
		
		offset.x = 0
		offset = offset + delta_y
	
	#focus on the first neuron by default 
	focused_state = states[0][0]
	focused_neuron = neurons[0][0]
	pointed_state = states[0][0]
	pointed_neuron = neurons[0][0]
	
	#set min size 
	var brain_size = Vector2(
		lenght * (2*block_size + padding.x) + padding.x,
		height * (2*block_size + padding.y) + padding.y
	)
	self.set("custom_minimum_size",brain_size)

func upload(state):
	#print(state)
	send.emit(state["text"])

func download(new_text):
	focused_state["text"] = new_text
	
func _review(acceptance):
	
	#emits a signal for the game to keep track of the amount of nodes ready to run
	if focused_state["accepted"] != acceptance:
		vote.emit(1 if acceptance else -1)	
	
	#graphical operations + saving the state 
	focused_neuron.set_disabled(not acceptance)
	focused_neuron.set_focus(acceptance)
	focused_state["accepted"] = acceptance
	
	#on regection return
	if not acceptance:
		return 
	
	#on acceptance compile
	var idx = 0
	
	for line in focused_state["text"].split("\n"):
		var code = _compile(line)
		var sinapse = sinapses[idx]
		focused_state["instructions"][sinapse] = code[0]
		focused_state["arguments"][sinapse] = code[1]
		idx = idx + 1
	
func _input(event):
	if self.has_focus() and event is InputEventKey and event.pressed:
		var key = event.keycode
		
		print(inner_focused)
		
		#focus operations
		if((key == KEY_ENTER || key == KEY_UP || key == KEY_DOWN) && inner_focused == false):
			print("focus operations")
			match (key):
				KEY_ENTER:
					inner_focused = true
				KEY_ESCAPE:
					inner_focused = false
				KEY_UP:
					self.release_focus()
					self.find_prev_valid_focus().grab_focus()
				KEY_DOWN:
					self.release_focus()
					self.find_next_valid_focus().grab_focus()
			return
		
		#inner focus operations
		elif((key == KEY_UP || key == KEY_DOWN || key == KEY_LEFT || key == KEY_RIGHT || key == KEY_ESCAPE) && inner_focused == true):
			print("inner focus operations")
			focused_neuron.set_focus(false)
			match(key):
				KEY_UP:
					inner_focus.y = (inner_focus.y - 1) if (inner_focus.y - 1) > -1 else height - 1 
				KEY_DOWN:
					inner_focus.y = (inner_focus.y + 1) if (inner_focus.y + 1) < height else 0 
				KEY_LEFT:
					inner_focus.x = (inner_focus.x - 1) if (inner_focus.x - 1) > -1 else lenght - 1
				KEY_RIGHT:
					inner_focus.x = (inner_focus.x + 1) if (inner_focus.x + 1) < lenght else 0
				KEY_ESCAPE:
					inner_focused = false
					return
					
			focused_state = states[inner_focus.y][inner_focus.x]
			focused_neuron = neurons[inner_focus.y][inner_focus.x]
			focused_neuron.set_focus(true)
			upload(focused_state)

func _on_focus_entered():
	print("focus_entered")
	focused_neuron.set_focus(true)

func _on_focus_exited():
	print("focus_exited")
	focused_neuron.set_focus(false)
	
func memclear():
	for state_line in states:
		for state in state_line:
			state["inner_pc"] = 0
			state["ports"] = {"a":0,"b":0,"c":0,"d":0}

func posedge():
	var sinapse = sinapses[pointed_state["inner_pc"]]
	var result = _execute(pointed_state["instructions"][sinapse],pointed_state["arguments"][sinapse],pointed_state["ports"])
	
	focused_neuron.set_focus(false) # <- could not find a better way to do this
	pointed_state["inner_pc"] = (pointed_state["inner_pc"] + 1) % 4
	upload(pointed_state) 
	highlight.emit(sinapse)
	
	#eps was executed, don't pass scope nor update the ports
	if(result == null):
		return
	
	#calculation executed, pass scope, update ports and show animations
	pointed_neuron.set_focus(false)
	pointed_neuron.pass_scope(sinapse)
	
	var recipient
	#print(pointed_state["ports"], " ", pc)
	
	match sinapse:
		'a':
			pc.y = (pc.y - 1) if (pc.y - 1) > -1 else height - 1
			recipient = 'c'
		'b':
			pc.x = (pc.x + 1) if (pc.x + 1) < lenght else 0
			recipient = 'd'
		'c':
			pc.y = (pc.y + 1) if (pc.y + 1) < height else 0
			recipient = 'a'
		'd':
			pc.x = (pc.x - 1) if (pc.x - 1) > -1 else lenght - 1
			recipient = 'b'
	
	pointed_neuron = neurons[pc.y][pc.x]
	pointed_neuron.set_focus(true)
	pointed_state = states[pc.y][pc.x]
	pointed_state["ports"][recipient] = result
	yielded.emit(result)

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
		
#compiles a SINGLE statement line
func _compile(text):
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
func _execute(instructions,arguments,ports):
	const THENARY = 3
	var deference = func(arg): return ports[arg] if arg is String else arg
		
	#execute thenary
	if instructions.size() == THENARY:
		var decision = call(instructions[0],
							deference.call(arguments[0]),
							deference.call(arguments[1]))
		
		if decision != 0  and  instructions[1] != "eps":
			return call(instructions[1],
						deference.call(arguments[2]),
						deference.call(arguments[3]))
		
		elif decision == 0 and instructions[2] != "eps":
			var arg_idx = 2 + (0 if instructions[1] == "eps" else 2)
			return call(instructions[2],
						deference.call(arguments[arg_idx]),
						deference.call(arguments[arg_idx + 1]))
	
	#execute unary
	else:
		if not instructions[0] == "eps":
			return call(instructions[0],
						deference.call(arguments[0]),
						deference.call(arguments[1]))
	
	#on fall-trough return null 
	return null
