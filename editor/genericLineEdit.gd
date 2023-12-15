extends LineEdit

signal unfocused
signal changed(who,text)
var me 

func _ready():
	me = get_parent().name

func _on_text_changed(new_text):
	changed.emit(me,new_text)

func _gui_input(event):
	if self.has_focus() and event is InputEventKey and event.pressed:
		var key = event.keycode
		match key:
			KEY_DOWN:
				self.find_next_valid_focus().grab_focus()
			KEY_UP:
				self.find_prev_valid_focus().grab_focus()
			KEY_ESCAPE:
				unfocused.emit()
