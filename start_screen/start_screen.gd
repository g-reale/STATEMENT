extends Control

var next = preload("res://level1/level1.tscn")

func _unhandled_input(event):
	if event is InputEventKey:
		get_tree().change_scene_to_packed(next)
