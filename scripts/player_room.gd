extends Control

@onready var background: TextureRect = $TextureRect
var data: GameData

const DAY_TEXTURE = preload("res://assets/image/Background/player_room_v2_day.png")
const NIGHT_TEXTURE = preload("res://assets/image/Background/player_room_v2_night.jpg")

func _ready() -> void:
	# 1. Сразу при запуске сцены устанавливаем правильный фон
	_update_visuals()
	if not data:
		data = GameData.new()
	
	# 2. Подписываемся на смену времени
	if GameManager:
		GameManager.time_changed.connect(_on_time_changed)
		
	var evening := TriggerRegistry.get_trigger("evening")

	if evening:
		print("Событие найдено: ", evening.display_name)
		print("ID: ", evening.id)
		print("Условий: ", evening.conditions.size())

		var context := game_context.new(data)
		var condition := evening.conditions[0]
		
		print("GameManager.data.current_time: ", GameManager.data.current_time)
		print("PlayerRoom data.current_time: ", data.current_time)
		print("Одинаковый объект data: ", GameManager.data == data)

		print("Текущее время: ", data.current_time)
		print("Условие выполнено: ", condition.is_met(context))
	else:
		print("Событие evening НЕ найдено")


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
