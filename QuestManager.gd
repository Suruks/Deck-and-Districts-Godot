class_name QuestManager
extends Node

signal quest_completed(reward_count: int)

@export var active_quests_container: VBoxContainer
var quest_deck: QuestDeck
var active_quests: Array = []
var quest_ui_scene_ref: PackedScene

func _init(_quest_deck: QuestDeck, _quest_ui_scene: PackedScene):
	if not is_instance_valid(_quest_deck) or _quest_ui_scene == null:
		printerr("QuestManager: инициализация не удалась.")
		return
	quest_deck = _quest_deck
	quest_ui_scene_ref = _quest_ui_scene

# Настройка квестов
func setup_quests(count := 3):
	if quest_ui_scene_ref == null or not is_instance_valid(active_quests_container):
		printerr("QuestManager: невозможно настроить квесты.")
		return

	active_quests.clear()
	for child in active_quests_container.get_children():
		child.queue_free()

	for i in range(count):
		var q = quest_deck.draw_quest()
		if q == null:
			break
		q.reward_cards *= 0.75
		active_quests.append(q)

		var ui = quest_ui_scene_ref.instantiate()
		ui.quest = q  # здесь хранится Resource
		active_quests_container.add_child(ui)
		ui.call_deferred("update_ui")

# Расчёт очков и завершение квестов
func compute_all_scores(grid: Array, grid_size: int) -> int:
	var total_score := 0
	var quests_to_complete: Array = []

	for q in active_quests:
		var score = q.calculate_score(grid, grid_size)
		total_score += score
		if q.is_completed():
			quests_to_complete.append(q)

	# Завершаем квесты
	for q in quests_to_complete:
		complete_quest(q)

	# Обновляем UI оставшихся квестов
	if is_instance_valid(active_quests_container):
		for child in active_quests_container.get_children():
			if child.has_method("update_ui"):
				child.update_ui()

	return total_score

# Завершение одного квеста
func complete_quest(q: Quest):
	var index = active_quests.find(q)
	if index == -1:
		return # квест не активен

	# Удаляем квест из массива
	active_quests.remove_at(index)

	# Удаляем UI-ноду по индексу
	var ui_node: Node = null
	if is_instance_valid(active_quests_container) and active_quests_container.get_child_count() > index:
		ui_node = active_quests_container.get_child(index)
		if is_instance_valid(ui_node):
			ui_node.queue_free()

	# Берём новый квест и создаём UI на том же месте
	var new_q = quest_deck.draw_quest()
	if new_q:
		active_quests.insert(index, new_q)

		var new_ui = quest_ui_scene_ref.instantiate()
		new_ui.quest = new_q
		active_quests_container.add_child(new_ui)
		active_quests_container.move_child(new_ui, index)
		new_ui.call_deferred("update_ui")

	# Добавляем карты за квест
	call_deferred("emit_signal", "quest_completed", q.reward_cards)
