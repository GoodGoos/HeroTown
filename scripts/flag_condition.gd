class_name flag_condition
extends game_condition

@export var flag_name: String = ""
@export var expected_value: bool = true


# Проверяет флаг мира.
func is_met(context: game_context) -> bool:
	if context == null or context.game_data == null:
		return false

	return context.game_data.world.flags.get(
		flag_name,
		false
	) == expected_value
