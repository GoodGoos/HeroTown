class_name GameData
extends RefCounted

# Флаг: открыта ли карта
var is_map_open: bool = false

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

# Главный словарь флагов (состояние мира, прогресс квестов, важные события)
# Пример: flags["met_airi"] = true, flags["rule_1_active"] = true
var flags: Dictionary = {}

# [Здесь в дальнейшем пропишем словари персонажей, их характеристики и уровень правил]


# --- СЕРИАЛИЗАЦИЯ (Сбор и чтение данных) ---

func to_dict() -> Dictionary:
	var dict: Dictionary = {}
	for prop in get_property_list():
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			dict[prop.name] = get(prop.name)
	return dict

func from_dict(dict: Dictionary) -> void:
	for key in dict.keys():
		if key in self:
			set(key, dict[key])
