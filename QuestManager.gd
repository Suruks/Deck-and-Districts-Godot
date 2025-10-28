class_name QuestManager
extends Node

signal quest_completed(reward_count: int)

@export var quest_ui_scene: PackedScene
@export var active_quests_container: VBoxContainer

var quest_deck: QuestDeck
var active_quests: Array = []

func _init(_quest_deck: QuestDeck):
	quest_deck = _quest_deck

func complete_quest(q: Quest):
	if not active_quests.has(q):
		return # квест неактивен

	# --- Найти UI-ноду, связанную с этим квестом ---
	var ui_node: Node = null
	for child in active_quests_container.get_children():
		if child.quest == q:
			ui_node = child
			break

	if ui_node:
		var index = active_quests.find(q)
		active_quests.remove_at(index)
		ui_node.queue_free()

		# --- Берём новый квест из колоды ---
		var new_q = quest_deck.draw_quest()
		if new_q:
			active_quests.insert(index, new_q)

			var new_ui = quest_ui_scene.instantiate()
			new_ui.quest = new_q

			# Вставляем именно на место старого UI
			# Если нужно сохранять порядок, используем add_child с индексом
			active_quests_container.add_child(new_ui)
			new_ui.move_child(new_ui, index)
			new_ui.call_deferred("update_ui")
	else:
		# если UI-ноду не нашли, просто убираем квест из списка
		active_quests.erase(q)
		
	#добавить карты в колоду
	var reward = q.reward_cards
	emit_signal("quest_completed", reward)


func setup_quests(count := 3):
	active_quests.clear()
	for child in active_quests_container.get_children():
		child.queue_free()

	for i in range(count):
		var q = quest_deck.draw_quest()
		if q == null:
			break
		active_quests.append(q)

		var ui = quest_ui_scene.instantiate()
		ui.quest = q
		active_quests_container.add_child(ui)
		ui.call_deferred("update_ui")

func compute_all_scores(grid: Array, grid_size: int) -> int:
	var total_score := 0
	for q in active_quests:
		var score = q.calculate_score(grid, grid_size)
		total_score += score
		print("[QuestManager] %s: %d" % [q.quest_type, score])
		
		if q.is_completed():
			complete_quest(q)
		
		for child in active_quests_container.get_children():
			if "update_ui" in child:
				child.update_ui()
	return total_score
