extends Control

@export var _disabled = false

@onready var animations = get_node("transitionPlayer")
@onready var btl = get_node("blocks/top/btl")
@onready var btr = get_node("blocks/top/btr")
@onready var bbl = get_node("blocks/botton/bbl")
@onready var bbr = get_node("blocks/botton/bbr")

signal passed

func _ready():
	set_focus(false)
	set_block_size()

func set_disabled(choice):
	_disabled = choice
	if(_disabled):
		btl.set("color",Color.RED)
		btr.set("color",Color.RED)
		bbl.set("color",Color.RED)
		bbr.set("color",Color.RED)
		
func set_focus(focused):
	
	if(_disabled):
		return
	
	if(focused):
		btl.set("color",Color.DIM_GRAY)
		btr.set("color",Color.DIM_GRAY)
		bbl.set("color",Color.DIM_GRAY)
		bbr.set("color",Color.DIM_GRAY)
	else:
		btl.set("color",Color.WHITE)
		btr.set("color",Color.WHITE)
		bbl.set("color",Color.WHITE)
		bbr.set("color",Color.WHITE)

func set_block_size(new_size=20):
	btl.set("custom_minimum_size",new_size)
	btr.set("custom_minimum_size",new_size)
	bbl.set("custom_minimum_size",new_size)
	bbr.set("custom_minimum_size",new_size)

func pass_scope(sinapse):
	match sinapse:
		'a':
			animations.play("passUp")
		'b':
			animations.play("passRight")
		'c':
			animations.play("passDown")
		'd':
			animations.play("passLeft")

func _on_animation_finished(_anim_name):
	passed.emit()
