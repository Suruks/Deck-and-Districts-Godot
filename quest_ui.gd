extends VBoxContainer

@export var quest: Quest

@onready var panel : Panel = $Panel
@onready var vbox : VBoxContainer = $Panel/MarginContainer/VBoxContainer
@onready var label_desc : RichTextLabel = $Panel/MarginContainer/VBoxContainer/LabelDescription
@onready var hbox : HBoxContainer = $Panel/MarginContainer/VBoxContainer/HBoxContainer
@onready var progress_bar : ProgressBar = $Panel/MarginContainer/VBoxContainer/HBoxContainer/ProgressBar
@onready var label_progress : Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/LabelProgress
@onready var reward_icon := $Panel/MarginContainer/VBoxContainer/HBoxContainer/RewardSprite
@onready var reward_label := $Panel/MarginContainer/VBoxContainer/HBoxContainer/RewardSprite/RewardLabel

const EXTRA_PADDING := 15

func _ready():
	# убедимся, что автоперенос включён (если нужен)
	label_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	label_desc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reward_icon.custom_minimum_size = Vector2(48, 48)
	
	if quest:
		update_ui()

func _update_size():
	# Убедимся, что текст уже разложен по строкам
	await get_tree().process_frame
	# Получаем реальную высоту текста
	var text_height = label_desc.get_content_height()
	# Присваиваем высоту самому RichTextLabel
	label_desc.custom_minimum_size.y = text_height
	# Теперь получаем общую высоту VBox
	var total_height = vbox.get_combined_minimum_size().y + EXTRA_PADDING
	# Применяем к панели
	panel.custom_minimum_size.y = total_height

	# Обновляем layout
	vbox.queue_sort()
	panel.queue_redraw()

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
	
	reward_label.text = str(quest.reward_cards)

	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# --- Подгоняем высоту панели под содержимое ---
	# используем call_deferred, чтобы Label успел рассчитать видимые строки
	call_deferred("_update_size")
