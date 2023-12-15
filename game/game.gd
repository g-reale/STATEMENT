extends Control

@onready var editor = get_node("interface/controls/editor")
@onready var brain = get_node("interface/controls/brain")
@onready var btn = get_node("interface/controls/border/btn")
@onready var clock = get_node("timer")
@onready var obj = get_node("interface/controls/objective")
@onready var disp = get_node("interface/controls/display")
@onready var animations = get_node("animations")

@export var brain_lenght = 1
@export var brain_height = 1

var answer = [1,1,1,1,1,1,1,] # for debugging 
var answer_index = 0
var next

var running = false
var votes

func set_objective(text,answers,next_scene):
	obj.text = text
	answer = answers
	next = next_scene

func _ready():
	animations.play("show_objective")
	brain.alloc(brain_lenght,brain_height)
	votes = brain.neuron_amount
	disp.set("text","0 : 0")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _toggle_simulation():
	
	running = not running
	
	#disconnect the upload of programs
	if running == true:
		clock.start()
		btn.set("text","stop")
		editor.disconnect("send",brain.download)
		return
	
	#connect the upload of programs
	brain.memclear()
	editor.connect("send",brain.download)
	btn.set("text","run")
	clock.stop()
	
func _on_clock():
	brain.posedge()

func _election(value):
	votes = votes + value
	
	#not ready to run
	if votes != brain.neuron_amount:
		btn.set("disabled",true)
		return
		
	#ready to run
	btn.set("disabled",false)


func _on_brain_yielded(result):
	print(result, " ", answer[answer_index])
	
	if(!running):
		return
	
	disp.set("text",str(result) + " : " + str(answer[answer_index]))
	
	if(result != answer[answer_index]):
		_toggle_simulation()
		return
	
	answer_index = answer_index + 1
	if(answer_index == answer.size()):
		get_tree().change_scene_to_packed(next)
