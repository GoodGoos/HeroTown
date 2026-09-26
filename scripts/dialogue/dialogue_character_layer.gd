class_name DialogueCharacterLayer
extends Control


var characters: Dictionary = {}


func set_character_position(
	character_id: String,
	normalized_position: float
) -> void:
	if character_id.is_empty():
		return

	normalized_position = clamp(normalized_position, 0.0, 1.0)

	var character := _get_or_create_character(character_id)

	character.normalized_position = normalized_position

	_update_character_position(character)


func set_facing(
	character_id: String,
	direction: String
) -> void:
	if character_id.is_empty():
		return

	if direction != "left" and direction != "right":
		return

	var character := _get_or_create_character(character_id)

	character.facing = direction


func _get_or_create_character(character_id: String) -> DialogueCharacter:
	if characters.has(character_id):
		return characters[character_id]

	# Создаём визуальный объект только при первом появлении персонажа.
	var character := DialogueCharacter.new()
	character.setup(character_id)

	add_child(character)

	characters[character_id] = character

	return character


func _update_character_position(character: DialogueCharacter) -> void:
	var parent_size := size

	# Переводим нормализованную позицию 0.0–1.0 в координату экрана.
	character.position.x = parent_size.x * character.normalized_position

	# Пока ставим персонажа к нижней части слоя.
	character.position.y = parent_size.y
