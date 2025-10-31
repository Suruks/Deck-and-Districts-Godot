class_name QuestManager
extends Node

signal quest_completed(reward_count: int)

# Эту переменную нужно будет установить вручную в main.gd, 
# т.к. QuestManager создается через new().
@export var active_quests_container: VBoxContainer 

var quest_deck: QuestDeck
var active_quests: Array = []
var quest_ui_scene_ref: PackedScene # Переменная для хранения ссылки на сцену UI

# --- КОНСТРУКТОР ---
# Теперь принимает и QuestDeck, и PackedScene
func _init(_quest_deck: QuestDeck, _quest_ui_scene: PackedScene):
	# Проверяем обязательные аргументы
	if not is_instance_valid(_quest_deck) or _quest_ui_scene == null:
		# Выводим предупреждение, если инициализация невозможна
		printerr("QuestManager: Инициализация не удалась. Отсутствует QuestDeck или QuestUI.tscn.")
		return
		
	quest_deck = _quest_deck
	quest_ui_scene_ref = _quest_ui_scene


# --- ФУНКЦИЯ ЗАВЕРШЕНИЯ КВЕСТА ---
func complete_quest(q: Quest):
	if not active_quests.has(q):
		return # Квест неактивен

	# Проверяем, что UI-контейнер инициализирован
	if not is_instance_valid(active_quests_container):
		active_quests.erase(q)
		return

	var ui_node: Node = null
	var index = -1
	
	# Ищем UI-ноду и ее индекс
	for i in range(active_quests_container.get_child_count()):
		var child = active_quests_container.get_child(i)
		# Мы предполагаем, что узел UI имеет поле 'quest'
		if child.has_method("get_quest") and child.get_quest() == q: 
			ui_node = child
			index = i
			break
		# Альтернативно: if child.quest == q:
	
	# Если UI найден, удаляем старый квест и вставляем новый
	if ui_node and index != -1:
		active_quests.remove_at(active_quests.find(q))
		ui_node.queue_free()

		var new_q = quest_deck.draw_quest()
		
		if new_q:
			active_quests.insert(index, new_q)
			
			var new_ui = quest_ui_scene_ref.instantiate()
			new_ui.quest = new_q

			# Вставляем на место старого UI для сохранения порядка
			active_quests_container.add_child(new_ui)
			active_quests_container.move_child(new_ui, index)
			new_ui.call_deferred("update_ui")
	else:
		# Если UI-ноду не нашли, просто убираем квест из списка
		active_quests.erase(q)
		
	# Добавить карты в колоду
	var reward = q.reward_cards
	call_deferred("emit_signal", "quest_completed", reward)


# --- ФУНКЦИЯ НАСТРОЙКИ КВЕСТОВ ---
func setup_quests(count := 3):
	# Проверяем, что сцена UI и контейнер доступны
	if quest_ui_scene_ref == null or not is_instance_valid(active_quests_container):
		printerr("QuestManager: Невозможно настроить квесты. Сцена UI или контейнер не инициализированы.")
		return

	active_quests.clear()
	# Очищаем все старые UI-элементы
	for child in active_quests_container.get_children():
		child.queue_free()

	for i in range(count):
		var q = quest_deck.draw_quest()
		if q == null:
			break
			
		# Снижение награды на 25% (оставшиеся 75%)
		q.reward_cards *= 0.75 
		active_quests.append(q)

		# !!! ЗДЕСЬ БЫЛА ОШИБКА, ИСПРАВЛЕНО НА quest_ui_scene_ref !!!
		var ui = quest_ui_scene_ref.instantiate()
		ui.quest = q
		active_quests_container.add_child(ui)
		ui.call_deferred("update_ui")


# --- ФУНКЦИЯ РАСЧЕТА СЧЕТА ---
func compute_all_scores(grid: Array, grid_size: int) -> int:
	var total_score := 0
	var quests_to_complete: Array = []
	
	for q in active_quests:
		var score = q.calculate_score(grid, grid_size)
		total_score += score
		print("[QuestManager] %s: %d" % [q.quest_type, score])
		
		if q.is_completed():
			quests_to_complete.append(q)
		
	# Завершаем квесты после вычисления всех очков, чтобы избежать проблем с итератором
	for q in quests_to_complete:
		complete_quest(q)
		
	# Обновляем UI всех оставшихся активных квестов
	if is_instance_valid(active_quests_container):
		for child in active_quests_container.get_children():
			# Проверка наличия метода 'update_ui'
			if child.has_method("update_ui"):
				child.update_ui()
				
	return total_score
