class_name StatSaver
extends RefCounted

const SAVE_PATH = "user://raw_quest_data.json"

# Сохраняет одну запись о завершенном квесте.
# Данные сохраняются в виде массива JSON-объектов.
func append_quest_data(quest_type: String, duration: int):
	# 1. Загружаем текущие данные (если файл существует)
	var all_data: Array = []
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if FileAccess.get_open_error() == OK:
			var json_string = file.get_as_text()
			var parsed_data = JSON.parse_string(json_string)
			if parsed_data is Array:
				all_data = parsed_data
			file.close()
		else:
			printerr("StatSaver: Ошибка при чтении файла статистики: ", FileAccess.get_open_error())
			return
	
	# 2. Создаем новую запись
	var new_entry = {
		"quest_type": quest_type,
		"duration": duration,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# 3. Добавляем ее в массив
	all_data.append(new_entry)
	
	# 4. Перезаписываем весь файл с новыми данными
	var file_write = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if FileAccess.get_open_error() == OK:
		var json_string = JSON.stringify(all_data, "\t")
		file_write.store_string(json_string)
		file_write.close()
		#print("StatSaver: Сохранена запись о квесте '", quest_type, "' (", duration, " ходов).")
	else:
		printerr("StatSaver: Ошибка при записи файла статистики: ", FileAccess.get_open_error())
