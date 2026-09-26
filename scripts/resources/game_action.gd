class_name game_action
extends Resource


signal finished


# Выполняет действие.
# Возвращает true, если действие завершено сразу.
func execute(context: game_context) -> bool:
	finished.emit()
	return true
