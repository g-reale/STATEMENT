extends Control

var border
var inner_focused = false
var interface = {}
var election = 4

var instruction
var separator
var epsilon 
var argument
var endl
enum {INS_1,ARG_1,ARG_2,INS_2,ARG_3,ARG_4,INS_3,ARG_5,ARG_6,DONE,REGECT}

signal send(text)
signal acceptance(was_accepted) 

func _ready():
	interface = {
		"a": {"label": get_node("border/controls/a/aLabel"), "line": get_node("border/controls/a/aLineEdit"), "voted": 1},
		"b": {"label": get_node("border/controls/b/bLabel"), "line": get_node("border/controls/b/bLineEdit"), "voted": 1},
		"c": {"label": get_node("border/controls/c/cLabel"), "line": get_node("border/controls/c/cLineEdit"), "voted": 1},
		"d": {"label": get_node("border/controls/d/dLabel"), "line": get_node("border/controls/d/dLineEdit"), "voted": 1},
	}
	
	
	instruction = RegEx.new()
	separator = RegEx.new()
	epsilon = RegEx.new()
	argument = RegEx.new()
	endl = RegEx.new()
	
	instruction.compile("^add|sub|mul|div|aeq|anq|agt|alt$")
	epsilon.compile("^eps$")
	argument.compile("^(\\d+|a|b|c|d)$")

	border = get_node("border")
	self.set("custom_minimum_size",get_node("border").get("size"))
	self.grab_focus()
	
func _on_focus_entered():
	border.set_border(true)

func _on_focus_exited():
	if(inner_focused):
		return
	border.set_border(false)

func _on_inner_focus_exited():
	inner_focused = false
	self.grab_focus()

func _gui_input(event):
	if self.has_focus() and event is InputEventKey and event.pressed:
		var key = event.keycode
		
		#focus operations
		if((key == KEY_ENTER || key == KEY_UP || key == KEY_DOWN) && inner_focused == false):
			match (key):
				KEY_ENTER:
					inner_focused = true
					interface["a"]["line"].grab_focus()
				KEY_UP:
					self.release_focus()
					self.find_prev_valid_focus().grab_focus()
				KEY_DOWN:
					self.release_focus()
					self.find_next_valid_focus().grab_focus()
			return

func download(text):
	var lines = text.split("\n")
	
	interface["a"]["line"].text = lines[0]
	_on_text_changed("a",lines[0])
	
	interface["b"]["line"].text = lines[1]
	_on_text_changed("b",lines[1])
	
	interface["c"]["line"].text = lines[2]
	_on_text_changed("c",lines[2])
	
	interface["d"]["line"].text = lines[3]
	_on_text_changed("d",lines[3])
	

func upload():
	var lines = "\n".join([interface["a"]["line"].text,interface["b"]["line"].text,interface["c"]["line"].text,interface["d"]["line"].text])
	return lines

var last_line = null
func debugger_highlight(line):
	if last_line != null:
		last_line.set("theme_override_colors/font_color",Color.WHITE)
	
	interface[line]["label"].set("theme_override_colors/font_color",Color.DIM_GRAY)
	last_line = interface[line]["label"] 
	
func _on_text_changed(who,text):
	var vote
	send.emit(upload())
	
	if(_sintax_check(text)):
		interface[who]["label"].set("theme_override_colors/font_color",Color.WHITE)
		vote = 1
	else:
		interface[who]["label"].set("theme_override_colors/font_color",Color.RED)
		vote = -1

	if(vote != interface[who]["voted"]):
		election = election + vote
		interface[who]["voted"] = vote
	
	if(election == 4):
		acceptance.emit(true)
	else:
		acceptance.emit(false)
	
	
func _sintax_check(text):
	var state = 0
	for word in text.split(" ",false):
		match state:
			INS_1:
				if instruction.search(word):
					state += 1
				elif epsilon.search(word):
					state = DONE
				else:
					state = REGECT
			ARG_1:
				if argument.search(word):
					state += 1
				else:
					state = REGECT
			ARG_2:
				if argument.search(word):
					state += 1
				else:
					state = REGECT
			INS_2:
				if instruction.search(word):
					state += 1
				elif epsilon.search(word):
					state = INS_3
				else:
					state = REGECT
			ARG_3:
				if argument.search(word):
					state += 1
				else:
					state = REGECT
			ARG_4:
				if argument.search(word):
					state += 1
				else:
					state = REGECT
			INS_3:
				if instruction.search(word):
					state += 1
				elif epsilon.search(word):
					state = DONE
				else:
					state = REGECT
			ARG_5:
				if argument.search(word):
					state += 1
				else:
					state = REGECT
			ARG_6:
				if argument.search(word):
					state += 1
				else:
					state = REGECT
			DONE:
				state += 1
			REGECT:
				return false
		
	if(state == INS_2 || state == DONE):
		return true

	return false






