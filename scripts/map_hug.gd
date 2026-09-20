extends CanvasLayer

var _is_animating: bool = false

# --- ПУТИ К УЗЛАМ ---
@onready var background: TextureRect = $LocationsContainer/Background
@onready var locations_container: Control = $LocationsContainer
@onready var city_ambience: AudioStreamPlayer = $CityAmbienceSound

# --- КНОПКИ ЛОКАЦИЙ ---
@onready var house_btn: Button = $LocationsContainer/Background/HouseButton
@onready var city_fountain_btn: Button = $LocationsContainer/Background/CityFountain

# Ресурсы фонов
const MAP_DAY_TEXTURE = preload("res://assets/image/Background/map_city_day.png")
const MAP_NIGHT_TEXTURE = preload("res://assets/image/Background/map_city_night.png")

func _ready() -> void:
	visible = false
	locations_container.modulate.a = 0.0
	_setup_location_buttons()
	
	Transition.screen_blacked_out.connect(_on_transition_blacked_out)
	# Подписываемся на время
	if GameManager:
		GameManager.time_changed.connect(_on_time_changed)
		# Подписываемся на глобальный сигнал, если GameManager доступен
		
		# ПРОВЕРКА ПРИ ЗАГРУЗКЕ
		# Ждем один кадр, чтобы игра успела загрузить данные в GameManager
		await get_tree().process_frame 
		if GameManager.data.is_map_open:
			open_map()

func sync_with_game_data() -> void:
	if not GameManager.data: return
	
	var is_open = GameManager.data.is_map_open
	visible = is_open
	locations_container.modulate.a = 1.0 if is_open else 0.0
	
	if is_open and city_ambience:
		if not city_ambience.playing: city_ambience.play()
	elif city_ambience:
		city_ambience.stop()

func _on_transition_blacked_out() -> void:
	# Принудительная синхронизация состояния прямо в темноте
	# Это гарантирует, что на новой сцене карта будет ровно такой, какая она в данных
	var is_open = GameManager.data.is_map_open
	visible = is_open
	locations_container.modulate.a = 1.0 if is_open else 0.0
	
	# Звук тоже синхронизируем
	if is_open and city_ambience:
		if not city_ambience.playing: city_ambience.play()
	elif city_ambience:
		city_ambience.stop()

# Вызывается автоматически каждый раз, когда меняется время в GameManager
func _on_time_changed() -> void:
	# Обновляем фон и кнопки только если карта в данный момент открыта
	if visible:
		_update_visuals()
		_update_location_availability()

func _on_game_loaded() -> void:
	if not GameManager.data: return
	
	# ПРИМЕНЯЕМ СОСТОЯНИЕ БЕЗ АНИМАЦИЙ
	var should_be_open = GameManager.data.is_map_open
	
	if should_be_open:
		visible = true
		locations_container.modulate.a = 1.0 # Полная прозрачность
		if city_ambience: city_ambience.play()
	else:
		visible = false
		locations_container.modulate.a = 0.0 # Полная скрытость
		if city_ambience: city_ambience.stop()
		
	_is_animating = false # Сбрасываем флаг анимации на всякий случай

# ---------- Кнопки перехода по локациям ----------
func _setup_location_buttons() -> void:
	var location_map = {
		house_btn: "res://scenes/player_room.tscn",
		city_fountain_btn:  "res://scenes/city_fountain.tscn",
	}
	
	for btn in location_map.keys():
		if btn:
			var target_path = location_map[btn]
			btn.pressed.connect(_on_location_selected.bind(target_path))

func _update_location_availability() -> void:
	if not GameManager.data:
		return
		
	var current_time = GameManager.data.current_time
	
	var nursery_btn = locations_container.get_node_or_null("NurseryButton")
	if nursery_btn:
		nursery_btn.disabled = (current_time == GameData.TimeOfDay.NIGHT)
		
	var night_club_btn = locations_container.get_node_or_null("NightClubButton")
	if night_club_btn:
		night_club_btn.disabled = (current_time == GameData.TimeOfDay.MORNING or current_time == GameData.TimeOfDay.DAY)

# --- УНИВЕРСАЛЬНЫЙ МЕТОД ПЕРЕКЛЮЧЕНИЯ (Для кнопки на HUD) ---
func toggle_map() -> void:
	if _is_animating:
		return
		
	if visible:
		close_map()
	else:
		open_map()


# --- УПРАВЛЕНИЕ ВИДИМОСТЬЮ ---
func open_map() -> void:
	GameManager.update_ui_state(true)
	if _is_animating or visible:
		return
		
	_is_animating = true
	_update_visuals()
	_update_location_availability()
	
	visible = true
	if city_ambience:
		city_ambience.play()
		
	var tween = create_tween()
	tween.tween_property(locations_container, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	await tween.finished
	_is_animating = false


func close_map() -> void:
	GameManager.update_ui_state(false)
	if _is_animating or not visible:
		return
		
	_is_animating = true
	
	var tween = create_tween()
	tween.tween_property(locations_container, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_SINE)
	await tween.finished
	
	visible = false
	if city_ambience:
		city_ambience.stop()
		
	_is_animating = false


# --- ПЕРЕХОД И СМЕНА ВРЕМЕНИ ---
func _on_location_selected(target_scene_path: String) -> void:
	if _is_animating: return
	
	# Проверка, что мы не пытаемся загрузить ту же самую сцену
	var current_file = get_tree().current_scene.scene_file_path.get_file()
	if current_file == target_scene_path.get_file():
		close_map()
		return

	# МЫ ЗАКРЫВАЕМ КАРТУ ЗДЕСЬ (обновляем данные)
	GameManager.update_ui_state(false)
	
	# ЗАПУСКАЕМ ПЕРЕХОД
	Transition.change_scene(target_scene_path)

func _update_visuals() -> void:
	if not GameManager.data or not background:
		return
		
	var current_time = GameManager.data.current_time
	var is_night_time = (current_time == GameData.TimeOfDay.EVENING or 
						current_time == GameData.TimeOfDay.NIGHT)
						
	background.texture = MAP_NIGHT_TEXTURE if is_night_time else MAP_DAY_TEXTURE
