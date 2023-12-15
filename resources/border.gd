extends PanelContainer

var border_styles = [preload("res://resources/empty.tres"),preload("res://resources/border.tres")]

func _ready():
	set_border(false)

func set_border(style):
	self.set("theme_override_styles/panel",border_styles[int(style)])

func border_on():
	self.set("theme_override_styles/panel",border_styles[1])

func border_off():
	self.set("theme_override_styles/panel",border_styles[0])
