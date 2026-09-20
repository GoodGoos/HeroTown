class_name time_condition
extends game_condition


@export var required_time: GameData.TimeOfDay = GameData.TimeOfDay.MORNING


# Проверяет текущее время игры.
func is_met(context: game_context) -> bool:
	if context == null or context.game_data == null:
		return false

	return context.game_data.current_time == required_time
