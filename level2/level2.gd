extends Control

@onready var game = get_node("game")
var level3 = preload("res://level3/level3.tscn")

func _ready():
	game.set_objective("produza potências de 2  começando por 1 (x9)", [1,2,4,8,16,32,64,128,256], level3)

