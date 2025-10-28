class_name QuestDeck
extends Resource

var quests: Array[Quest] = []

var block_colors = {
	"residential": Color(0.3, 0.837, 1.0),
	"industrial": Color(1.0, 0.3, 0.3),
	"nature": Color(0.3, 1.0, 0.3),
	"culture": Color(1.0, 0.813, 0.3)
}

func init_quests():
	quests.clear()
	
	# 1 — Город в зелени
	var q1 = Quest.new()
	q1.quest_type = "city_in_green"
	q1.description = "+1 прогресс за каждый [color=#4DD5FF]дом[/color], соседствующий с [color=#4DFF4D]парком[/color]. \n −1 прогресс за [color=#4DD5FF]дом[/color] без [color=#4DFF4D]парка[/color] рядом."
	q1.reward_cards = 3
	q1.target_progress = 5
	q1.current_progress = 0
	quests.append(q1)

	# 2 — Баланс индустрии
	var q2 = Quest.new()
	q2.quest_type = "industrial_balance"
	q2.description = "+1 прогресс за каждый [color=#FF4D4D]завод[/color] рядом с [color=#4DD5FF]домом[/color] и [color=#4DFF4D]парком[/color]. \n-1 прогресс за каждый [color=#FF4D4D]завод[/color] только с [color=#4DD5FF]домом[/color]."
	q2.reward_cards = 4
	q2.target_progress = 6
	q2.current_progress = 0
	quests.append(q2)

	# 3 — Комфортные окраины
	var q3 = Quest.new()
	q3.quest_type = "cozy_suburbs"
	q3.description = "Построй 5 [color=#4DD5FF]домов[/color] на краю поля, которые не касаются [color=#FF4D4D]заводов[/color]."
	q3.reward_cards = 4
	q3.target_progress = 5
	q3.current_progress = 0
	quests.append(q3)

	# 4 — Сердце культуры
	var q4 = Quest.new()
	q4.quest_type = "heart_of_culture"
	q4.description = "Построй 4 [color=#FFD04D]культурных[/color] блока, соседствующих со всеми 4-мя видами кварталов."
	q4.reward_cards = 6
	q4.target_progress = 4
	q4.current_progress = 0
	quests.append(q4)

	# 5 — Пояс жизни
	var q5 = Quest.new()
	q5.quest_type = "life_belt"
	q5.description = "Построй 3 линии из 4 клеток, где сочетаются [color=#4DFF4D]природные[/color] и [color=#4DD5FF]жилые[/color] блоки."
	q5.reward_cards = 3
	q5.target_progress = 3
	q5.current_progress = 0
	quests.append(q5)

	# 6 — Душа города
	var q6 = Quest.new()
	q6.quest_type = "soul_of_city"
	q6.description = "Построй цепочку из 8 [color=#FFD04D]культурных[/color] блоков, соединённых по соседству."
	q6.reward_cards = 5
	q6.target_progress = 8
	q6.current_progress = 0
	quests.append(q6)
	
	quests.shuffle()

func draw_quest() -> Quest:
	if quests.is_empty():
		return null
	return quests.pop_front()
