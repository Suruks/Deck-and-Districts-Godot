class_name QuestDeck
extends Resource

var quests: Array[Quest] = []

var block_colors = {
	"residential": Color(0.3, 0.837, 1.0),
	"industrial": Color(1.0, 0.3, 0.3),
	"nature": Color(0.3, 1.0, 0.3),
	"culture": Color(1.0, 0.813, 0.3)
}

func colorize_text(text: String) -> String:
	var colors = {
		"жил": "#4DD5FF",
		"промышл": "#FF4D4D",
		"культурн": "#FFD04D",
		"природн": "#4DFF4D"
	}
	
	for root in colors.keys():
		var color = colors[root]
		var regex = RegEx.new()
		regex.compile("(%s[а-яА-Яa-zA-Z]*)" % root)
		var matches = regex.search_all(text)
		if matches:
			for i in range(matches.size() - 1, -1, -1):
				var m = matches[i]
				var word = m.get_string(1)
				var colored = "[color=%s]%s[/color]" % [color, word]
				text = text.substr(0, m.get_start(1)) + colored + text.substr(m.get_end(1))
	return text


func init_quests():
	quests.clear()
	
	# 1 — Город в зелени
	var q1 = Quest.new()
	q1.quest_type = "city_in_green"
	q1.description = colorize_text("+1 прогресс за каждый жилой район, соседствующий с природным. \n −1 прогресс за жилой район без природного рядом.")
	q1.reward_cards = 3
	q1.target_progress = 5
	quests.append(q1)

	# 2 — Баланс индустрии
	var q2 = Quest.new()
	q2.quest_type = "industrial_balance"
	q2.description = colorize_text("+1 прогресс за каждый промышленный район рядом с жилым и природным. \n-1 прогресс за каждый промышленный район только рядом с жилым.")
	q2.reward_cards = 4
	q2.target_progress = 6
	quests.append(q2)

	# 3 — Комфортные окраины
	var q3 = Quest.new()
	q3.quest_type = "cozy_suburbs"
	q3.description = colorize_text("Построй 6 жилых района на краю поля, которые не касаются промышленных.")
	q3.reward_cards = 4
	q3.target_progress = 6
	quests.append(q3)

	# 4 — Сердце культуры
	var q4 = Quest.new()
	q4.quest_type = "heart_of_culture"
	q4.description = colorize_text("Построй 4 культурных района, соседствующих со всеми 4-мя видами районов.")
	q4.reward_cards = 6
	q4.target_progress = 4
	quests.append(q4)

	# 5 — Пояс жизни
	var q5 = Quest.new()
	q5.quest_type = "life_belt"
	q5.description = colorize_text("Построй 3 линии из 4 клеток, где сочетаются природные и жилые районы.")
	q5.reward_cards = 3
	q5.target_progress = 3
	quests.append(q5)

	# 6 — Душа города
	var q6 = Quest.new()
	q6.quest_type = "soul_of_city"
	q6.description = colorize_text("Построй 3 цепочки из 4 районов одного типа (тип разных цепочек может отличаться)")
	q6.reward_cards = 4
	q6.target_progress = 3
	quests.append(q6)

	# 7 — Квадрат индустрии
	var q7 = Quest.new()
	q7.quest_type = "industrial_square"
	q7.description = colorize_text("Построй зону 2x4 из промышленных районов.")
	q7.reward_cards = 6
	q7.target_progress = 1
	quests.append(q7)

	# 8 — Экологичная индустрия
	var q8 = Quest.new()
	q8.quest_type = "eco_industry"
	q8.description = colorize_text("Каждый промышленный район должен соседствовать с природным. В игре должно быть минимум 5 промышленных районов.")
	q8.reward_cards = 3
	q8.target_progress = 5
	quests.append(q8)

	# 9 — Эко-жильё
	var q10 = Quest.new()
	q10.quest_type = "eco_homes"
	q10.description = colorize_text("Построй 4 жилых района, соседствующих минимум с 3 природными.")
	q10.reward_cards = 5
	q10.target_progress = 4
	quests.append(q10)

	# 10 — Диагональный город
	var q11 = Quest.new()
	q11.quest_type = "diagonal_city"
	q11.description = colorize_text("Построй 3 диагональные линии из 4 районов одного типа (тип разных линий может отличаться).")
	q11.reward_cards = 6
	q11.target_progress = 3
	quests.append(q11)

	# 11 — Изолированные заводы
	var q12 = Quest.new()
	q12.quest_type = "isolated_factories"
	q12.description = colorize_text("Построй группу из 6 промышленных районов, при этом ни один из них не должен касаться жилого района.")
	q12.reward_cards = 4
	q12.target_progress = 6
	quests.append(q12)

	# 12 — Соседство искусства
	var q13 = Quest.new()
	q13.quest_type = "art_neighborhood"
	q13.description = colorize_text("Построй квадрат 2x2 из жилых районов и квадрат 2x2 из культурных.")
	q13.reward_cards = 5
	q13.target_progress = 2
	quests.append(q13)

	# 13 — Природное равновесие
	var q14 = Quest.new()
	q14.quest_type = "natural_balance"
	q14.description = colorize_text("+1 прогресс за каждый природный район. -1 прогресса за каждый промышленный.")
	q14.reward_cards = 4
	q14.target_progress = 6
	quests.append(q14)

	# 14 — Культурная уединённость
	var q15 = Quest.new()
	q15.quest_type = "culture_isolation"
	q15.description = colorize_text("Построй 7 культурных районов, соседствующих не больше, чем с двумя другими районами.")
	q15.reward_cards = 4
	q15.target_progress = 7
	quests.append(q15)

	# 15 — Индустриальный ряд
	var q16 = Quest.new()
	q16.quest_type = "industrial_row"
	q16.description = colorize_text("Построй 7 промышленных районов в одном ряду.")
	q16.reward_cards = 4
	q16.target_progress = 7
	quests.append(q16)

	# 16 — Городская масса
	var q17 = Quest.new()
	q17.quest_type = "urban_mass"
	q17.description = colorize_text("Построй группу из 12 районов любого типа.")
	q17.reward_cards = 5
	q17.target_progress = 12
	quests.append(q17)

	# 17 — Природные линии
	var q18 = Quest.new()
	q18.quest_type = "natural_lines"
	q18.description = colorize_text("Должно быть 4 ряда с ровно 4 природными районами.")
	q18.reward_cards = 5
	q18.target_progress = 4
	quests.append(q18)

	# 18 — Промышленный контроль
	var q19 = Quest.new()
	q19.quest_type = "industrial_control"
	q19.description = colorize_text("+1 прогресс за каждый промышленный район, окружённый другими районами. -2 прогресса за каждый промышленный район, окружённый менее чем с 4 сторон.")
	q19.reward_cards = 4
	q19.target_progress = 6
	quests.append(q19)

	# 20 — Разнообразный квартал
	var q20 = Quest.new()
	q20.quest_type = "diverse_block"
	q20.description = colorize_text("Построй область 3x3, где каждый район отличается по типу от всех соседей.")
	q20.reward_cards = 3
	q20.target_progress = 1
	quests.append(q20)

	quests.shuffle()

func draw_quest() -> Quest:
	if quests.is_empty():
		return null
	return quests.pop_front()
