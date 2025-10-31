extends Node
class_name InputClass

var is_active = false

signal rotation_requested(clockwise: bool)
signal placement_attempted()

# --- Ввод ---
func _input(event):
	if not is_active:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			rotation_requested.emit(false)
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			rotation_requested.emit(true)
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			placement_attempted.emit()
