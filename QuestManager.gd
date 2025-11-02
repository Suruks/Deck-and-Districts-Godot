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
func setup_quests(count := 5):
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
		
		active_quests.append(q)

		var ui = quest_ui_scene_ref.instantiate()
		ui.quest = q  # здесь хранится Resource
		active_quests_container.add_child(ui)
		ui.call_deferred("update_ui")

# Расчёт очков и завершение квестов
func compute_all_scores(grid: Array, grid_size: int) -> int:
	var total_score := 0
	var completed_indices: Array = []

	# Собираем индексы выполненных квестов (фиксируем индексы на момент проверки)
	for i in range(active_quests.size()):
		var q: Quest = active_quests[i]
		var score = q.calculate_score(grid, grid_size)
		total_score += score
		if q.is_completed():
			completed_indices.append(i)

	# Завершаем квесты в порядке убывания индекса — это предотвращает сдвиги индексов
	completed_indices.sort()
	completed_indices.reverse() # теперь в порядке убывания
	for idx in completed_indices:
		complete_quest_by_index(idx)

	# Обновляем UI оставшихся квестов
	if is_instance_valid(active_quests_container):
		for child in active_quests_container.get_children():
			if child.has_method("update_ui"):
				child.update_ui()

	return total_score
	
func complete_quest_by_index(index: int) -> void:
	if index < 0 or index >= active_quests.size():
		return

	var q: Quest = active_quests[index]

	# Удаляем квест из массива
	active_quests.remove_at(index)

	# Находим соответствующий UI-узел привязанный к этому квесту (без предположений о порядке)
	var ui_node: Node = null
	if is_instance_valid(active_quests_container):
		for child in active_quests_container.get_children():
			# предполагаем, что UI-узел хранит ссылку на свой квест в поле 'quest'
			if child.has_meta("quest") and child.get_meta("quest") == q:
				ui_node = child
				break
			# или альтернативно: если в ui есть свойство quest (как вы раньше делали)
			if "quest" in child and child.quest == q:
				ui_node = child
				break

	# Если не нашли по привязке — как запасной вариант берём узел по индексу (на случай, если ui и active_quests синхронизованы)
	if ui_node == null and is_instance_valid(active_quests_container) and active_quests_container.get_child_count() > index:
		var candidate = active_quests_container.get_child(index)
		# проверка: если у узла вообще нет привязки, всё равно удаляем
		ui_node = candidate

	if is_instance_valid(ui_node):
		ui_node.queue_free()

	# Берём новый квест и создаём UI на том же месте (если есть)
	var new_q = quest_deck.draw_quest()
	if new_q:
		active_quests.insert(index, new_q)

		var new_ui = quest_ui_scene_ref.instantiate()
		# сохраняем явную привязку, чтобы можно было надёжно искать UI по квесту
		if new_ui.has_method("set_meta"):
			new_ui.set_meta("quest", new_q)
		new_ui.quest = new_q
		active_quests_container.add_child(new_ui)
		# Перемещаем на нужную позицию
		active_quests_container.move_child(new_ui, clamp(index, 0, active_quests_container.get_child_count()-1))
		new_ui.call_deferred("update_ui")

	var reward_count: int = q.reward_cards

	call_deferred("emit_signal", "quest_completed", reward_count, q.description)

# Завершение одного квеста
func complete_quest(q: Quest) -> void:
	var idx = active_quests.find(q)
	if idx == -1:
		return
	complete_quest_by_index(idx)
