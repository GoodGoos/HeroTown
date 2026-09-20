extends Node


# Проверяет, существует ли персонаж в текущем состоянии игры.
func has_character(character_id: String) -> bool:
	if not GameManager.data:
		return false

	return GameManager.data.characters.has(character_id)


# Возвращает состояние персонажа по его ID.
func get_character(character_id: String) -> CharacterState:
	if not GameManager.data:
		return null

	return GameManager.data.characters.get(character_id, null)


# Создаёт состояние персонажа на основе его профиля.
# Создаёт персонажа по ID.
func create_character(character_id: String) -> CharacterState:
	if not GameManager.data:
		return null

	if GameManager.data.characters.has(character_id):
		return GameManager.data.characters[character_id]

	var profile := CharacterRegistry.get_profile(character_id)

	if profile == null:
		push_warning("Профиль персонажа не найден: " + character_id)
		return null

	var character_state := CharacterState.new()

	character_state.id = profile.id
	character_state.stats = profile.initial_stats.duplicate(true)

	GameManager.data.characters[profile.id] = character_state

	return character_state
	
# Возвращает персонажа или создаёт его.
func get_or_create(character_id: String) -> CharacterState:
	var character := get_character(character_id)

	if character:
		return character

	return create_character(character_id)


# Удаляет состояние персонажа из текущей игры.
func remove_character(character_id: String) -> void:
	if not GameManager.data:
		return

	GameManager.data.characters.erase(character_id)


# Удаляет всех персонажей из текущей игры.
func clear_characters() -> void:
	if not GameManager.data:
		return

	GameManager.data.characters.clear()
