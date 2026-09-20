class_name game_context
extends RefCounted


# Текущее состояние игры.
var game_data: GameData

# Персонаж, связанный с операцией.
var character: CharacterState = null

# Текущая локация.
var location: String = ""

# Объект, который вызвал операцию.
var trigger = null

# Дополнительные данные события.
var event_data: Dictionary = {}


func _init(
	data: GameData,
	character_state: CharacterState = null,
	current_location: String = "",
	source_trigger = null,
	data_from_event: Dictionary = {}
):
	game_data = data
	character = character_state
	location = current_location
	trigger = source_trigger
	event_data = data_from_event
