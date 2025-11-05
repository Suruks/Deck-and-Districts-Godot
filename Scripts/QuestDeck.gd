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
	q1.short_desc = "Дома рядом с природой"
	q1.difficulty_levels = {
		"3": { 
			"target_progress": 7, 
			"reward_cards": 3,
			"penalty": 1,
			"description": colorize_text("+1 прогресс за каждый жилой район, соседствующий с природным. \n−1 прогресс за жилой район без природного рядом.")
		},
		"4": { 
			"target_progress": 9, 
			"reward_cards": 3,
			"penalty": 1,
			"description": colorize_text("+1 прогресс за каждый жилой район, соседствующий с природным. \n−1 прогресс за жилой район без природного рядом.")
		},
		"5": { 
			"target_progress": 9, 
			"reward_cards": 3,
			"penalty": 2,
			"description": colorize_text("+1 прогресс за каждый жилой район, соседствующий с природным. \n−2 прогресса за жилой район без природного рядом.")
		}
	}
	quests.append(q1)

	# 2 — Баланс индустрии
	var q2 = Quest.new()
	q2.quest_type = "industrial_balance"
	q2.short_desc = "Заводы вместе и рядом с культурой"
	q2.difficulty_levels = {
		"3": { 
			"target_progress": 6, 
			"reward_cards": 4,
			"penalty": 1,
			"description": colorize_text("+1 прогресс за каждый промышленный район, соседствующий с другим промышленным и культурным районом.\n−1 прогресс за промышленный квартал, не соседствующий ни с промышленным, ни с культурным.")
		},
		"4": { 
			"target_progress": 7, 
			"reward_cards": 4,
			"penalty": 1,
			"description": colorize_text("+1 прогресс за каждый промышленный район, соседствующий с другим промышленным и культурным районом.\n−1 прогресс за промышленный квартал, не соседствующий ни с промышленным, ни с культурным.")
		},
		"5": { 
			"target_progress": 8, 
			"reward_cards": 4,
			"penalty": 2,
			"description": colorize_text("+1 прогресс за каждый промышленный район, соседствующий с другим промышленным и культурным районом.\n−2 прогресса за промышленный квартал, не соседствующий ни с промышленным, ни с культурным.")
		}
	}
	quests.append(q2)

	# 4 — Сердце культуры
	var q4 = Quest.new()
	q4.quest_type = "heart_of_culture"
	q4.short_desc = "Культура в центре"
	q4.difficulty_levels = {
		"3": { 
			"target_progress": 5, 
			"reward_cards": 3,
			"required_types": 3,
			"description": colorize_text("Построй 5 культурных районов, соседствующих с 3-мя другими видами районов.")
		},
		"4": { 
			"target_progress": 6, 
			"reward_cards": 3,
			"required_types": 3,
			"description": colorize_text("Построй 6 культурных районов, соседствующих с 3-мя другими видами районов.")
		},
		"5": { 
			"target_progress": 5, 
			"reward_cards": 3,
			"required_types": 4,
			"description": colorize_text("Построй 5 культурных районов, соседствующих со всеми 4-мя видами районов.")
		}
	}
	quests.append(q4)

	# 5 — Пояс жизни
	var q5 = Quest.new()
	q5.quest_type = "life_belt"
	q5.short_desc = "Линии из домов и природы"
	q5.difficulty_levels = {
		"3": { 
			"target_progress": 4, 
			"reward_cards": 3,
			"line_length": 4,
			"description": colorize_text("Построй 4 линии из 4 клеток, где сочетаются природные и жилые районы.")
		},
		"4": { 
			"target_progress": 4, 
			"reward_cards": 3,
			"line_length": 5,
			"description": colorize_text("Построй 4 линии из 5 клеток, где сочетаются природные и жилые районы.")
		},
		"5": { 
			"target_progress": 5, 
			"reward_cards": 3,
			"line_length": 6,
			"description": colorize_text("Построй 5 линий из 6 клеток, где сочетаются природные и жилые районы.")
		}
	}
	quests.append(q5)

	# 8 — Экологичная индустрия
	var q8 = Quest.new()
	q8.quest_type = "eco_industry"
	q8.short_desc = "Промышленные рядом"
	q8.difficulty_levels = {
		"3": { 
			"target_progress": 8, 
			"reward_cards": 3,
			"group_size": 2,
			"description": colorize_text("+1 прогресс за каждый промышленный район по соседству с другим промышленным.\n-1 прогресс за каждый промышленный, не соответствующий условию.")
		},
		"4": { 
			"target_progress": 9, 
			"reward_cards": 3,
			"group_size": 3,
			"description": colorize_text("+1 прогресс за каждый промышленный район в группе из трёх.\n-1 прогресс за каждый промышленный, не соответствующий условию.")
		},
		"5": { 
			"target_progress": 10, 
			"reward_cards": 3,
			"group_size": 4,
			"description": colorize_text("+1 прогресс за каждый промышленный район в группе из четырёх.\n-1 прогресс за каждый промышленный, не соответствующий условию.")
		}
	}
	quests.append(q8)

	# 9 — Эко-жильё (q10 в исходнике)
	var q10 = Quest.new()
	q10.quest_type = "eco_homes"
	q10.short_desc = "Жильё рядом с природой"
	q10.difficulty_levels = {
		"3": { 
			"target_progress": 4, 
			"reward_cards": 4, 
			"min_nature_neighbors": 3,
			"description": colorize_text("Построй 4 жилых района, соседствующих минимум с 3 природными.")
		},
		"4": { 
			"target_progress": 5, 
			"reward_cards": 4, 
			"min_nature_neighbors": 3,
			"description": colorize_text("Построй 5 жилых районов, соседствующих минимум с 3 природными.")
		},
		"5": { 
			"target_progress": 7, 
			"reward_cards": 4, 
			"min_nature_neighbors": 3,
			"description": colorize_text("Построй 7 жилых районов, соседствующих минимум с 3 природными.")
		}
	}
	quests.append(q10)

	# 10 — Диагональный город
	var q11 = Quest.new()
	q11.quest_type = "diagonal_city"
	q11.short_desc = "Диагональные линии"
	q11.difficulty_levels = {
		"3": { 
			"target_progress": 5, 
			"reward_cards": 3,
			"description": colorize_text("Построй 5 диагональных линий из 3 районов одного типа (тип разных линий может отличаться).")
		},
		"4": { 
			"target_progress": 6, 
			"reward_cards": 3,
			"description": colorize_text("Построй 6 диагональных линий из 3 районов одного типа (тип разных линий может отличаться).")
		},
		"5": { 
			"target_progress": 8, 
			"reward_cards": 3,
			"description": colorize_text("Построй 8 диагональных линий из 3 районов одного типа (тип разных линий может отличаться).")
		}
	}
	quests.append(q11)

	# 12 — Соседство искусства
	var q13 = Quest.new()
	q13.quest_type = "art_neighborhood"
	q13.short_desc = "Группы из 3"
	q13.difficulty_levels = {
		"3": { 
			"target_progress": 6, 
			"reward_cards": 3,
			"description": colorize_text("Построй 6 групп из 3 районов одного типа (тип районов между разными группами может отличаться).")
		},
		"4": { 
			"target_progress": 7, 
			"reward_cards": 3,
			"description": colorize_text("Построй 7 групп из 3 районов одного типа (тип районов между разными группами может отличаться).")
		},
		"5": { 
			"target_progress": 10, 
			"reward_cards": 3,
			"description": colorize_text("Построй 10 групп из 3 районов одного типа (тип районов между разными группами может отличаться).")
		}
	}
	quests.append(q13)

	# 13 — Природное равновесие
	var q14 = Quest.new()
	q14.quest_type = "natural_balance"
	q14.short_desc = "+1 за природу, -1 за заводы"
	q14.difficulty_levels = {
		"3": { 
			"target_progress": 6, 
			"reward_cards": 3,
			"penalty": 1,
			"description": colorize_text("+1 прогресс за каждый природный район.\n-1 прогресс за каждый промышленный.")
		},
		"4": { 
			"target_progress": 8, 
			"reward_cards": 3,
			"penalty": 1,
			"description": colorize_text("+1 прогресс за каждый природный район.\n-1 прогресс за каждый промышленный.")
		},
		"5": { 
			"target_progress": 6, 
			"reward_cards": 3,
			"penalty": 1,
			"description": colorize_text("+1 прогресс за каждый природный район.\n-2 прогресса за каждый промышленный.")
		}
	}
	quests.append(q14)

	# 14 — Культурная уединённость
	var q15 = Quest.new()
	q15.quest_type = "culture_isolation"
	q15.short_desc = "Природные на краю"
	q15.difficulty_levels = {
		"3": { 
			"target_progress": 7, 
			"reward_cards": 3,
			"description": colorize_text("Построй 7 природных районов, соседствующих не больше, чем с двумя другими районами.")
		},
		"4": { 
			"target_progress": 8, 
			"reward_cards": 3,
			"description": colorize_text("Построй 8 природных районов, соседствующих не больше, чем с двумя другими районами.")
		},
		"5": { 
			"target_progress": 10, 
			"reward_cards": 3,
			"description": colorize_text("Построй 10 природных районов, соседствующих не больше, чем с двумя другими районами.")
		}
	}
	quests.append(q15)

	# 15 — Индустриальный ряд
	var q16 = Quest.new()
	q16.quest_type = "industrial_row"
	q16.short_desc = "Ряды с заводами"
	q16.difficulty_levels = {
		"3": { 
			"target_progress": 3, 
			"reward_cards": 4,
			"mode": "equals_or_more",
			"description": colorize_text("В городе должно быть 3 ряда с минимум 4 промышленными районами (не обязательно подряд)")
		},
		"4": { 
			"target_progress": 4, 
			"reward_cards": 4,
			"mode": "equals_or_more",
			"description": colorize_text("В городе должно быть 4 ряда с минимум 4 промышленными районами (не обязательно подряд)")
		},
		"5": { 
			"target_progress": 5, 
			"reward_cards": 5,
			"mode": "equals",
			"description": colorize_text("В городе должно быть 4 ряда ровно с 4 промышленными районами (не обязательно подряд)")
		}
	}
	quests.append(q16)

	# 16 — Городская масса
	var q17 = Quest.new()
	q17.quest_type = "urban_mass"
	q17.short_desc = "Группы из 5"
	q17.difficulty_levels = {
		"3": { 
			"target_progress": 2, 
			"reward_cards": 4,
			"group_size": 5,
			"description": colorize_text("Построй 2 группы из 5 районов одного типа (тип районов между разными группами может отличаться).")
		},
		"4": { 
			"target_progress": 2, 
			"reward_cards": 4,
			"group_size": 6,
			"description": colorize_text("Построй 2 группы из 6 районов одного типа (тип районов между разными группами может отличаться).")
		},
		"5": { 
			"target_progress": 3, 
			"reward_cards": 4,
			"group_size": 6,
			"description": colorize_text("Построй 3 группы из 6 районов одного типа (тип районов между разными группами может отличаться).")
		}
	}
	quests.append(q17)

	# 17 — Природные линии
	var q18 = Quest.new()
	q18.quest_type = "natural_lines"
	q18.short_desc = "Ряды из природы"
	q18.difficulty_levels = {
		"3": { 
			"target_progress": 4, 
			"reward_cards": 4,
			"description": colorize_text("В городе должно быть 4 ряда с ровно 3 природными районами (не обязательно подряд).")
		},
		"4": { 
			"target_progress": 5, 
			"reward_cards": 4,
			"description": colorize_text("В городе должно быть 5 рядов с ровно 3 природными районами (не обязательно подряд).")
		},
		"5": { 
			"target_progress": 6, 
			"reward_cards": 4,
			"description": colorize_text("В городе должно быть 6 рядов с ровно 3 природными районами (не обязательно подряд).")
		}
	}
	quests.append(q18)

	# 18 — Промышленный контроль
	var q19 = Quest.new()
	q19.quest_type = "industrial_control"
	q19.short_desc = "Промышленные окружены"
	q19.difficulty_levels = {
		"3": { 
			"target_progress": 6, 
			"reward_cards": 3,
			"description": colorize_text("+1 прогресс за каждый промышленный район, окружённый другими районами. -2 прогресса за каждый промышленный район, окружённый менее чем с 3 сторон.")
		},
		"4": { 
			"target_progress": 7, 
			"reward_cards": 3,
			"description": colorize_text("+1 прогресс за каждый промышленный район, окружённый другими районами. -2 прогресса за каждый промышленный район, окружённый менее чем с 3 сторон.")
		},
		"5": { 
			"target_progress": 9, 
			"reward_cards": 3,
			"description": colorize_text("+1 прогресс за каждый промышленный район, окружённый другими районами. -2 прогресса за каждый промышленный район, окружённый менее чем с 3 сторон.")
		}
	}
	quests.append(q19)

	# 20 — Разнообразный квартал
	var q20 = Quest.new()
	q20.quest_type = "diverse_block"
	q20.short_desc = "Разные типы 3x3"
	q20.difficulty_levels = {
		"3": { 
			"target_progress": 2, 
			"reward_cards": 3,
			"description": colorize_text("Построй 2 области 3x3, где каждый район отличается по типу от всех соседей.")
		},
		"4": { 
			"target_progress": 3, 
			"reward_cards": 4,
			"description": colorize_text("Построй 3 области 3x3, где каждый район отличается по типу от всех соседей.")
		},
		"5": { 
			"target_progress": 4, 
			"reward_cards": 4,
			"description": colorize_text("Построй 4 области 3x3, где каждый район отличается по типу от всех соседей.")
		}
	}
	quests.append(q20)

	# 21 — Районы с разными соседями
	var q21 = Quest.new()
	q21.quest_type = "diverse_neighbors"
	q21.short_desc = "Районы с разными соседями"
	q21.difficulty_levels = {
		"3": { 
			"target_progress": 3, 
			"reward_cards": 3,
			"description": colorize_text("Построй 3 района, у которых 4 соседа разных типов.")
		},
		"4": { 
			"target_progress": 4, 
			"reward_cards": 3,
			"description": colorize_text("Построй 4 района, у которых 4 соседа разных типов.")
		},
		"5": { 
			"target_progress": 5, 
			"reward_cards": 3,
			"description": colorize_text("Построй 5 районов, у которых 4 соседа разных типов.")
		}
	}
	quests.append(q21)

	# 23 — Жильё рядом с природой
	var q23 = Quest.new()
	q23.quest_type = "neighboring_nature"
	q23.short_desc = "Жильё рядом с природой"
	q23.difficulty_levels = {
		"3": { 
			"target_progress": 6, 
			"reward_cards": 4,
			"description": colorize_text("Построй 6 жилых районов, соседствующих с 2+ природными районами.")
		},
		"4": { 
			"target_progress": 7, 
			"reward_cards": 4,
			"description": colorize_text("Построй 7 жилых районов, соседствующих с 2+ природными районами.")
		},
		"5": { 
			"target_progress": 9, 
			"reward_cards": 4,
			"description": colorize_text("Построй 9 жилых районов, соседствующих с 2+ природными районами.")
		}
	}
	quests.append(q23)

	# 24 — Жильё без заводов рядом
	var q24 = Quest.new()
	q24.quest_type = "residential_isolation"
	q24.short_desc = "Жильё без заводов рядом"
	q24.difficulty_levels = {
		"3": { 
			"target_progress": 5, 
			"reward_cards": 4,
			"description": colorize_text("Построй 5 жилых районов, у которых нет промышленных районов по соседству или диагонали")
		},
		"4": { 
			"target_progress": 6, 
			"reward_cards": 4,
			"description": colorize_text("Построй 6 жилых районов, у которых нет промышленных районов по соседству или диагонали")
		},
		"5": { 
			"target_progress": 8, 
			"reward_cards": 4,
			"description": colorize_text("Построй 8 жилых районов, у которых нет промышленных районов по соседству или диагонали")
		}
	}
	quests.append(q24)

	# 25 — Жильё рядом друг с другом
	var q25 = Quest.new()
	q25.quest_type = "edge_residential_pair"
	q25.short_desc = "Жильё рядом друг с другом"
	q25.difficulty_levels = {
		"3": { 
			"target_progress": 10, 
			"reward_cards": 3,
			"description": colorize_text("Построй 10 жилых районов, соседствующих с другим жилым.")
		},
		"4": { 
			"target_progress": 12, 
			"reward_cards": 3,
			"description": colorize_text("Построй 12 жилых районов, соседствующих с другим жилым.")
		},
		"5": { 
			"target_progress": 15, 
			"reward_cards": 3,
			"description": colorize_text("Построй 15 жилых районов, соседствующих с другим жилым.")
		}
	}
	quests.append(q25)

	# 26 — Культура с жильём и заводами
	var q26 = Quest.new()
	q26.quest_type = "nature_mix"
	q26.short_desc = "Культура с жильём и заводами"
	q26.difficulty_levels = {
		"3": { 
			"target_progress": 7, 
			"reward_cards": 4,
			"description": colorize_text("Построй 7 культурных районов, которые одновременно соседствуют с жилым и промышленным.")
		},
		"4": { 
			"target_progress": 8, 
			"reward_cards": 4,
			"description": colorize_text("Построй 8 культурных районов, которые одновременно соседствуют с жилым и промышленным.")
		},
		"5": { 
			"target_progress": 11, 
			"reward_cards": 4,
			"description": colorize_text("Построй 11 культурных районов, которые одновременно соседствуют с жилым и промышленным.")
		}
	}
	quests.append(q26)

	# 27 — Разница жильё/заводы
	var q27 = Quest.new()
	q27.quest_type = "type_difference"
	q27.short_desc = "Разница жильё/заводы"
	q27.difficulty_levels = {
		"3": { 
			"target_progress": 7, 
			"reward_cards": 3,
			"description": colorize_text("Достигните разницы в 7 между количеством промышленных и жилых районов на поле.")
		},
		"4": { 
			"target_progress": 8, 
			"reward_cards": 3,
			"description": colorize_text("Достигните разницы в 8 между количеством промышленных и жилых районов на поле.")
		},
		"5": { 
			"target_progress": 10, 
			"reward_cards": 3,
			"description": colorize_text("Достигните разницы в 10 между количеством промышленных и жилых районов на поле.")
		}
	}
	quests.append(q27)

	# 28 — Культура рядом с природой
	var q28 = Quest.new()
	q28.quest_type = "culture_neighboring_nature"
	q28.short_desc = "Культура рядом с природой"
	q28.difficulty_levels = {
		"3": { 
			"target_progress": 6, 
			"reward_cards": 3,
			"description": colorize_text("Построй 6 культурных районов, соседствующих с 2+ природными районами.")
		},
		"4": { 
			"target_progress": 7, 
			"reward_cards": 3,
			"description": colorize_text("Построй 7 культурных районов, соседствующих с 2+ природными районами.")
		},
		"5": { 
			"target_progress": 9, 
			"reward_cards": 3,
			"description": colorize_text("Построй 9 культурных районов, соседствующих с 2+ природными районами.")
		}
	}
	quests.append(q28)

	# 29 — Культура рядом с жильём
	var q29 = Quest.new()
	q29.quest_type = "culture_neighboring_residential"
	q29.short_desc = "Культура рядом с жильём"
	q29.difficulty_levels = {
		"3": { 
			"target_progress": 6, 
			"reward_cards": 3,
			"description": colorize_text("Построй 6 культурных районов, соседствующих с 2+ жилыми районами.")
		},
		"4": { 
			"target_progress": 7, 
			"reward_cards": 3,
			"description": colorize_text("Построй 7 культурных районов, соседствующих с 2+ жилыми районами.")
		},
		"5": { 
			"target_progress": 9, 
			"reward_cards": 3,
			"description": colorize_text("Построй 9 культурных районов, соседствующих с 2+ жилыми районами.")
		}
	}
	quests.append(q29)

	# 31 — Ряды всех типов
	var q31 = Quest.new()
	q31.quest_type = "mixed_rows"
	q31.short_desc = "Ряды всех типов"
	q31.difficulty_levels = {
		"3": { 
			"target_progress": 6, 
			"reward_cards": 4,
			"description": colorize_text("В городе должно быть 6 рядов, в которых есть как минимум один район каждого из 4-х типов.")
		},
		"4": { 
			"target_progress": 7, 
			"reward_cards": 4,
			"description": colorize_text("В городе должно быть 7 рядов, в которых есть как минимум один район каждого из 4-х типов.")
		},
		"5": { 
			"target_progress": 9, 
			"reward_cards": 4,
			"description": colorize_text("В городе должно быть 10 рядов, в которых есть как минимум один район каждого из 4-х типов.")
		}
	}
	quests.append(q31)

	# 32 — Квадраты уникальных районов
	var q32 = Quest.new()
	q32.quest_type = "unique_squares"
	q32.short_desc = "Квадраты уникальных районов"
	q32.difficulty_levels = {
		"3": { 
			"target_progress": 5, 
			"reward_cards": 3,
			"description": colorize_text("Построй 5 квадратов 2x2, где каждый из 4-х районов уникален.")
		},
		"4": { 
			"target_progress": 6, 
			"reward_cards": 3,
			"description": colorize_text("Построй 6 квадратов 2x2, где каждый из 4-х районов уникален.")
		},
		"5": { 
			"target_progress": 8, 
			"reward_cards": 3,
			"description": colorize_text("Построй 8 квадратов 2x2, где каждый из 4-х районов уникален.")
		}
	}
	quests.append(q32)
	
	quests.shuffle()

func draw_quest(difficulty: String) -> Quest:
	if quests.is_empty():
		print ("Массив квестов пустой!")
		return null
		
	var q = quests.pop_front()

	if q.difficulty_levels.has(difficulty):
		q.current_difficulty = difficulty
	else:
		# Запасной вариант, если передан невалидный уровень
		q.current_difficulty = "3"
		print("Передан невалидный уровень квеста!")
		
	return q
