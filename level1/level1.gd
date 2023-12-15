extends Control

@onready var game = get_node("game")
var level2 = preload("res://level2/level2.tscn")

func _ready():
	game.set_objective("produza uma saída constante igual a 1 (x9)", [1,1,1,1,1,1,1,1,1], level2)

