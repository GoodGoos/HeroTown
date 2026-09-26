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
	var parent_width := size.x
	var half_width := character.character_size.x / 2.0

	# Не даём персонажу выйти за левую и правую границы слоя.
	var min_x := half_width
	var max_x := parent_width - half_width

	character.position.x = lerp(
		min_x,
		max_x,
		character.normalized_position
	)

	# Нижняя точка персонажа совпадает с нижней границей слоя.
	character.position.y = size.y

func set_speaking_character(character_id: String) -> void:
	for id in characters:
		var character: DialogueCharacter = characters[id]

		character.set_speaking(
			id == character_id
		)

func get_character_states() -> Dictionary:
	var result: Dictionary = {}

	for id in characters:
		var character: DialogueCharacter = characters[id]

		result[id] = {
			"normalized_position": character.normalized_position,
			"facing": character.facing
		}

	return result


func restore_character_states(states: Dictionary) -> void:
	for character_id in states:
		var state: Dictionary = states[character_id]

		var character := _get_or_create_character(character_id)

		character.normalized_position = float(
			state.get("normalized_position", 0.5)
		)

		character.facing = state.get("facing", "right")

		_update_character_position(character)
