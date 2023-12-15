extends Control

func _unhandled_input(event):
	if event is InputEventKey:
		get_tree().quit()
