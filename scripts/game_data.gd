class_name GameData
extends RefCounted

# Флаг: открыта ли карта
var is_map_open: bool = false

# Состояние текущего диалога.
var active_dialogue_id: String = ""
var active_dialogue_index: int = 0

# Состояние персонажей текущего диалога.
var active_dialogue_characters: Dictionary = {}

enum TimeOfDay { MORNING, DAY, EVENING, NIGHT }

# Названия фаз времени (константа, не сохраняется)
const TIME_NAMES = {
	TimeOfDay.MORNING: "Утро",
	TimeOfDay.DAY: "День",
	TimeOfDay.EVENING: "Вечер",
	TimeOfDay.NIGHT: "Ночь"
}

# Дни недели (полезно для расписания NPC в будущем)
enum WeekDay { MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY }
const WEEKDAY_NAMES = {
	WeekDay.MONDAY: "Понедельник",
	WeekDay.TUESDAY: "Вторник",
	WeekDay.WEDNESDAY: "Среда",
	WeekDay.THURSDAY: "Четверг",
	WeekDay.FRIDAY: "Пятница",
	WeekDay.SATURDAY: "Суббота",
	WeekDay.SUNDAY: "Воскресенье"
}

# --- СОСТОЯНИЕ ИГРЫ ---
var current_time: TimeOfDay = TimeOfDay.MORNING
var current_day: int = 1

# Путь к текущей сцене
var current_scene_path: String = "res://scenes/player_room.tscn"

# Главные словари (состояние мира, прогресс отношений, важные события)
var world: WorldState = WorldState.new()
var player: PlayerState = PlayerState.new()
var characters: Dictionary = {}
var trigger_states: Dictionary = {}


# --- СЕРИАЛИЗАЦИЯ (Сбор и чтение данных) ---

func to_dict() -> Dictionary:
	var result: Dictionary = {
		"is_map_open": is_map_open,
		"current_time": current_time,
		"current_day": current_day,
		"current_scene_path": current_scene_path,
		"active_dialogue_id": active_dialogue_id,
		"active_dialogue_index": active_dialogue_index,
		"active_dialogue_characters": active_dialogue_characters,
		"world": world.to_dict(),
		"player": player.to_dict(),
		"characters": {},
		"trigger_states": {}
	}

	for character_id in characters:
		var character_state: CharacterState = characters[character_id]
		result["characters"][character_id] = character_state.to_dict()

	for trigger_id in trigger_states:
		var state: trigger_state = trigger_states[trigger_id]
		result["trigger_states"][trigger_id] = state.to_dict()
	return result


func from_dict(dict: Dictionary) -> void:
	is_map_open = dict.get("is_map_open", false)
	current_time = dict.get("current_time", TimeOfDay.MORNING)
	current_day = dict.get("current_day", 1)
	current_scene_path = dict.get(
		"current_scene_path",
		"res://scenes/player_room.tscn"
	)
	
	active_dialogue_id = dict.get("active_dialogue_id", "")
	active_dialogue_index = dict.get("active_dialogue_index", 0)
	active_dialogue_characters = dict.get(
	"active_dialogue_characters",
	{}
	)

	world = WorldState.new()
	world.from_dict(dict.get("world", {}))

	player = PlayerState.new()
	player.from_dict(dict.get("player", {}))

	characters.clear()

	var characters_data: Dictionary = dict.get("characters", {})

	for character_id in characters_data:
		var character_state := CharacterState.new()
		character_state.from_dict(characters_data[character_id])
		characters[character_id] = character_state
	
	trigger_states.clear()

	var trigger_states_data: Dictionary = dict.get("trigger_states", {})

	for trigger_id in trigger_states_data:
		var state := trigger_state.new()
		state.from_dict(trigger_states_data[trigger_id])
		trigger_states[trigger_id] = state
	
