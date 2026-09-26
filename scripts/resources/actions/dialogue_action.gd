class_name dialogue_action
extends game_action


@export var dialogue_id: String = ""


func execute(context: game_context) -> bool:
	if context == null or context.dialogue_ui == null:
		push_warning("DialogueUI не передан в game_context.")
		finished.emit()
		return true

	if dialogue_id.is_empty():
		push_warning("У dialogue_action не указан dialogue_id.")
		finished.emit()
		return true

	var dialogue := DialogueRegistry.get_dialogue(dialogue_id)

	if dialogue == null:
		push_warning("Диалог не найден: " + dialogue_id)
		finished.emit()
		return true

	# Ждём завершения именно этого диалога.
	if not context.dialogue_ui.dialogue_finished.is_connected(
		_on_dialogue_finished
	):
		context.dialogue_ui.dialogue_finished.connect(
			_on_dialogue_finished,
			CONNECT_ONE_SHOT
		)

	context.dialogue_ui.start_dialogue(dialogue)

	return false


func _on_dialogue_finished() -> void:
	finished.emit()
