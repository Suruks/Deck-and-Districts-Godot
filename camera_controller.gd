extends Camera2D

@export var drag_speed := 1.0
var dragging := false
var last_mouse_pos := Vector2.ZERO

func _ready():
	make_current()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			last_mouse_pos = get_viewport().get_mouse_position()

	elif event is InputEventMouseMotion and dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var delta = mouse_pos - last_mouse_pos
		position -= delta * drag_speed
		last_mouse_pos = mouse_pos
