extends Control

@export var quest: Quest

@onready var panel : Panel = $Panel
@onready var vbox : VBoxContainer = $Panel/MarginContainer/VBoxContainer
@onready var label_desc : RichTextLabel = $Panel/MarginContainer/VBoxContainer/LabelDescription
@onready var hbox : HBoxContainer = $Panel/MarginContainer/VBoxContainer/HBoxContainer
@onready var progress_bar : ProgressBar = $Panel/MarginContainer/VBoxContainer/HBoxContainer/ProgressBar
@onready var label_progress : Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/LabelProgress

const EXTRA_PADDING := 16

func _ready():
	# убедимся, что автоперенос включён (если нужен)
	label_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	label_desc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	label_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Автоматическое растяжение по тексту
	await get_tree().process_frame
	var text_height = label_desc.get_content_height()
	custom_minimum_size.y = text_height +40


	if quest:
		update_ui()

func _update_size():
	var label_height = label_desc.get_content_height()
	var hbox_height = hbox.get_combined_minimum_size().y
	panel.custom_minimum_size.y = label_height + hbox_height + EXTRA_PADDING


func update_ui():
	if not quest:
		return

	# --- Обновляем текст и прогресс ---
	label_desc.bbcode_enabled = true
	label_desc.bbcode_text  = quest.description
	label_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	label_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_desc.size_flags_vertical = Control.SIZE_SHRINK_CENTER  # Label сам считает высоту

	progress_bar.min_value = 0
	progress_bar.max_value = quest.target_progress
	progress_bar.value = quest.current_progress
	label_progress.text = str(quest.current_progress) + "/" + str(quest.target_progress)

	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# --- Подгоняем высоту панели под содержимое ---
	# используем call_deferred, чтобы Label успел рассчитать видимые строки
	call_deferred("_update_size")
