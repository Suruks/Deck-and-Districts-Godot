extends Node

# В этом классе будет храниться ваша универсальная функция логирования
func log(message):
	var time_dict = Time.get_datetime_dict_from_system()
	var formatted_time = "%02d:%02d:%02d" % [time_dict.hour, time_dict.minute, time_dict.second]
	
	# Мы используем print, но добавляем префикс для удобства фильтрации
	print("[%s] %s" % [formatted_time, message])
	
	# Если вы хотите записывать логи в файл, добавьте здесь логику сохранения
	# Example:
	# FileAccess.open("user://game.log", FileAccess.WRITE_READ).store_line(
	#     "[%s] %s" % [formatted_time, message]
	# )
