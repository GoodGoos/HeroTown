class_name advance_time_action
extends game_action


@export var steps: int = 1


func execute(context: game_context) -> bool:
	if context == null or context.game_data == null:
		finished.emit()
		return true

	GameManager.advance_time(steps)

	finished.emit()
	return true
