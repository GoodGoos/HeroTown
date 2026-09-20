extends Node

var data: GameData = null

signal game_state_changed(is_active: bool)
signal time_changed


# Состояние карты
func update_ui_state(map_open: bool) -> void:
	if data:
		data.is_map_open = map_open

var is_in_game: bool = false :
	set(value):
		if is_in_game != value:
			is_in_game = value
			game_state_changed.emit(is_in_game)

func _ready() -> void:
	if not data:
		data = GameData.new()


func reset_game() -> void:
	data = GameData.new()
	print("Создана новая сессия игры. Данные сброшены.")

func get_save_path(save_id: String) -> String:
	return "user://save_" + save_id + ".json"

# --- МЕТАДАННЫЕ СОХРАНЕНИЙ (Для UI) ---
# Получение сведений о файле без прямых манипуляций в UI
func get_save_metadata(save_id: String) -> Dictionary:
	var path = get_save_path(save_id)
	if not FileAccess.file_exists(path):
		return {}
		
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
		
	var json = JSON.new()
	if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
		return json.data
	return {}

# --- СОХРАНЕНИЕ / ЗАГРУЗКА ---
func save_game(save_id: String = "default") -> void:
	if not data:
		print("ОШИБКА: Нет данных для сохранения!")
		return
		
	var current_scene = get_tree().current_scene
	if current_scene:
		data.current_scene_path = current_scene.scene_file_path

	var path = get_save_path(save_id)
	var file = FileAccess.open(path, FileAccess.WRITE)

	if file:
		var dict_to_save = data.to_dict()
		var sys_time = Time.get_datetime_dict_from_system()
		dict_to_save["real_date"] = "%02d.%02d.%d" % [sys_time.day, sys_time.month, sys_time.year]
		dict_to_save["real_time"] = "%02d:%02d" % [sys_time.hour, sys_time.minute]
		
		file.store_string(JSON.stringify(dict_to_save, "\t"))
		file.close()
		print("Игра успешно сохранена в слот: ", save_id)

func load_game(save_id: String = "default") -> bool:
	var path = get_save_path(save_id)
	if not FileAccess.file_exists(path): return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	var loaded_data = null
	
	if json.parse(file.get_as_text()) == OK:
		loaded_data = json.data
	file.close()

	if loaded_data:
		# ЗАПУСКАЕМ ТРАНЗИШН ПЕРВЫМ
		# Передаем функцию, которая обновит данные ТОЛЬКО В ТЕМНОТЕ
		Transition.change_scene(loaded_data["current_scene_path"], func():
			data.from_dict(loaded_data) # Обновляем данные
			time_changed.emit()         # Обновляем время
			# Если нужно сбросить карту или интерфейс:
			# MapHug.force_sync() 
			if MapHug:
				MapHug.sync_with_game_data()
		)
		return true
	return false

func _perform_transition(target_path: String) -> void:
	Transition.change_scene(target_path)
	await Transition.screen_blacked_out
	is_in_game = true

# --- УПРАВЛЕНИЕ ВРЕМЕНЕМ ---

# Универсальный пропуск времени (по умолчанию 1 фаза)
# Универсальный пропуск времени с гарантированным затемнением
func advance_time(steps: int = 1) -> void:
	if not data:
		return
		
	for i in range(steps):
		if data.current_time < GameData.TimeOfDay.NIGHT:
			data.current_time += 1 as GameData.TimeOfDay
		else:
			data.current_time = GameData.TimeOfDay.MORNING
			data.current_day += 1
			
	print("Время изменено. Сейчас: ", data.current_time)

	time_changed.emit()

# Вспомогательный метод для получения текущего дня недели (0 = Понедельник, 6 = Воскресенье)
func get_current_weekday() -> GameData.WeekDay:
	if not data:
		return GameData.WeekDay.MONDAY
	return ((data.current_day - 1) % 7) as GameData.WeekDay

func get_time_string() -> String:
	if not data:
		return "Понедельник (Утро)"
	var day_str = GameData.WEEKDAY_NAMES[get_current_weekday()]
	var time_str = GameData.TIME_NAMES[data.current_time]
	return "%s (%s)" % [day_str, time_str]

# --- РАБОТА С ФЛАГАМИ ---
func set_flag(flag_name: String, value: Variant) -> void:
	if data:
		data.world.flags[flag_name] = value

func get_flag(flag_name: String, default_value: Variant = false) -> Variant:
	if data and data.world.flags.has(flag_name):
		return data.world.flags[flag_name]

	return default_value
