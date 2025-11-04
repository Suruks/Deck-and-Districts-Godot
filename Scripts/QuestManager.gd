class_name QuestManager
extends Node

signal quest_completed(reward_count: int, quest: Quest)

@export var active_quests_container: VBoxContainer
var quest_deck: QuestDeck
var active_quests: Array = []
var quest_ui_scene_ref: PackedScene

func _init(_quest_deck: QuestDeck, _quest_ui_scene: PackedScene):
	if not is_instance_valid(_quest_deck):
		printerr("QuestManager: QuestDeck невалиден.")
		return
		
	quest_deck = _quest_deck
	quest_ui_scene_ref = _quest_ui_scene # Если quest_ui_scene = null, то setup_quests сработает как "защитник"

# Настройка квестов
func setup_quests(count: int, current_turn: int, difficulty: String):
	if quest_ui_scene_ref == null:
		printerr("QuestManager: Не загружена QuestUI.tscn.")
		return
		
	if not is_instance_valid(active_quests_container):
		printerr("QuestManager: active_quests_container невалиден (узел сцены не найден).")
		return

	active_quests.clear()
	for child in active_quests_container.get_children():
		child.queue_free()

	for i in range(count):
		var q = quest_deck.draw_quest(difficulty)
		if q == null:
			break
			
		q.start_turn = current_turn
		active_quests.append(q)

		var ui = quest_ui_scene_ref.instantiate()
		ui.quest = q  # здесь хранится Resource
		
		active_quests_container.add_child(ui)
		ui.call_deferred("update_ui")

# Расчёт очков и завершение квестов
func compute_all_scores(grid: Array, grid_size: int, current_turn: int, epoch: int) -> int:
	var total_score := 0
	var completed_quests: Array = []

	for q_to_complete in completed_quests:
		complete_quest_by_object(q_to_complete, current_turn, epoch, grid, grid_size)

	# Обновляем UI оставшихся квестов
	if is_instance_valid(active_quests_container):
		for child in active_quests_container.get_children():
			if child.has_method("update_ui"):
				child.update_ui()

	return total_score
	
func complete_quest_by_object(q_to_complete: Quest, current_turn: int, epoch: int, grid: Array, grid_size: int) -> void:
	# 1. Найти индекс квеста, который нужно завершить.
	# Если квест уже был удален из-за каскада, active_quests.find вернет -1.
	var index = active_quests.find(q_to_complete)
	if index == -1:
		return
	
	var current_difficulty = str(epoch)
	var q: Quest = active_quests[index] # Объект q == q_to_complete

	# Удаляем квест из массива по найденному индексу
	active_quests.remove_at(index) 

	# 2. Находим соответствующий UI-узел по ссылке на объект квеста (наиболее надежный способ)
	var ui_node: Node = null 
	if is_instance_valid(active_quests_container): 
		for child in active_quests_container.get_children(): 
			# Используем ссылку на объект квеста для поиска узла UI
			if "quest" in child and child.quest == q: 
				ui_node = child
				break

	if is_instance_valid(ui_node):
		ui_node.queue_free() 

	# 3. Берем новый квест и создаем UI на том же месте
	var new_q = quest_deck.draw_quest(current_difficulty)
	MyLogger.log("Квест получен: " + new_q.short_desc)
	if new_q:
		new_q.start_turn = current_turn
		active_quests.insert(index, new_q) # Вставляем на место удаленного [cite: 4]
	
		var new_ui = quest_ui_scene_ref.instantiate()
		# ... (настройка new_ui) ...
		new_ui.quest = new_q
		active_quests_container.add_child(new_ui)
		# Перемещаем на нужную позицию
		active_quests_container.move_child(new_ui, clamp(index, 0, active_quests_container.get_child_count()-1))
		new_ui.call_deferred("update_ui")
		
		var new_q_score = new_q.calculate_score(grid, grid_size) #СЧИТАЕМ НОВЫЙ КВЕСТ
		if new_q.is_completed():
			complete_quest_by_object(new_q, current_turn, epoch, grid, grid_size)

	var reward_count: int = q.get_reward_cards()
	quest_completed.emit(reward_count, q)
	
func add_quest_slot(current_turn: int, current_difficulty: String):
	var new_q = quest_deck.draw_quest(current_difficulty)
	if new_q == null:
		MyLogger.log("Не удалось добавить слот: в колоде нет квестов.")
		return
		
	MyLogger.log("Количество квестов увеличено!")
	MyLogger.log("Квест получен: " + new_q.short_desc)
	
	new_q.start_turn = current_turn
	active_quests.append(new_q) # Добавляем в конец списка

	var new_ui = quest_ui_scene_ref.instantiate()
	# сохраняем явную привязку
	if new_ui.has_method("set_meta"):
		new_ui.set_meta("quest", new_q)
	new_ui.quest = new_q
	
	if is_instance_valid(active_quests_container):
		active_quests_container.add_child(new_ui)
		new_ui.call_deferred("update_ui")
	else:
		printerr("QuestManager: active_quests_container невалиден, UI для нового квеста не создан.")
