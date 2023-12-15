extends Control

@onready var game = get_node("game")
var end = preload("res://end_screen/end_screen.tscn")

func _ready():
	game.set_objective("produza a sequência [1,1,-1,-1,1,1,-1,-1,1]", [1,1,-1,-1,1,1,-1,-1,1], end)

