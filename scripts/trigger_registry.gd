class_name trigger_registry
extends Node

const TRIGGERS_PATH := "res://scripts/resources/triggers"

var triggers: Dictionary = {}


func _ready() -> void:
	load_triggers()


# Загружает все TriggerDefinition из папки.
func load_triggers() -> void:
	triggers.clear()

	var dir := DirAccess.open(TRIGGERS_PATH)

	if not dir:
		push_error("Не удалось открыть папку событий: " + TRIGGERS_PATH)
		return

	dir.list_dir_begin()

	while true:
		var file_name := dir.get_next()

		if file_name == "":
			break

		if dir.current_is_dir():
			continue

		if not file_name.ends_with(".tres"):
			continue

		var path := TRIGGERS_PATH + "/" + file_name
		var trigger := load(path) as trigger_definition

		if trigger == null:
			continue

		if trigger.id.is_empty():
			push_warning("У события нет ID: " + path)
			continue

		triggers[trigger.id] = trigger

	dir.list_dir_end()


# Возвращает событие по ID.
func get_trigger(trigger_id: String) -> trigger_definition:
	return triggers.get(trigger_id, null)


# Проверяет существование события.
func has_trigger(trigger_id: String) -> bool:
	return triggers.has(trigger_id)


# Возвращает все загруженные события.
func get_all_triggers() -> Array[trigger_definition]:
	var result: Array[trigger_definition] = []

	for trigger_id in triggers:
		result.append(triggers[trigger_id])

	return result
