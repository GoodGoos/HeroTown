class_name character_registry
extends Node

const CHARACTERS_PATH := "res://scripts/resources/characters"

var profiles: Dictionary = {}


func _ready() -> void:
	load_profiles()


# Загружает все CharacterProfile из папки.
func load_profiles() -> void:
	profiles.clear()

	var dir := DirAccess.open(CHARACTERS_PATH)

	if not dir:
		push_error("Не удалось открыть папку персонажей: " + CHARACTERS_PATH)
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

		var path := CHARACTERS_PATH + "/" + file_name
		var profile := load(path) as character_profile

		if profile == null:
			continue

		if profile.id.is_empty():
			push_warning("У профиля нет ID: " + path)
			continue

		profiles[profile.id] = profile

	dir.list_dir_end()


# Возвращает профиль по ID.
func get_profile(character_id: String) -> character_profile:
	return profiles.get(character_id, null)


# Проверяет, существует ли профиль.
func has_profile(character_id: String) -> bool:
	return profiles.has(character_id)
