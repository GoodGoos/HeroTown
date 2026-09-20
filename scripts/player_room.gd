extends Control

@onready var background: TextureRect = $TextureRect

const DAY_TEXTURE = preload("res://assets/image/Background/player_room_v2_day.png")
const NIGHT_TEXTURE = preload("res://assets/image/Background/player_room_v2_night.jpg")

func _ready() -> void:
	# 1. Сразу при запуске сцены устанавливаем правильный фон
	_update_visuals()
	
	# 2. Подписываемся на смену времени
	if GameManager:
		GameManager.time_changed.connect(_on_time_changed)

func _on_time_changed() -> void:
	# 3. УБРАЛИ "if visible:" — нам не важно, видна комната или нет, 
	# она всегда должна знать, какой сейчас фон, чтобы при входе в неё всё было готово.
	_update_visuals()
		
func _update_visuals() -> void:
	if not GameManager.data or not background:
		return
		
	var current_time = GameManager.data.current_time
	var is_night_time = (current_time == GameData.TimeOfDay.EVENING or 
						current_time == GameData.TimeOfDay.NIGHT)
						
	background.texture = NIGHT_TEXTURE if is_night_time else DAY_TEXTURE
