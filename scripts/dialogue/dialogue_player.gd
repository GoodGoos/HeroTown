class_name DialoguePlayer
extends RefCounted

signal line_started(line: DialogueLine)
signal command_requested(command: DialogueCommand)
signal dialogue_finished()


var dialogue: DialogueDefinition = null
var current_index: int = 0
var is_playing: bool = false


func play(definition: DialogueDefinition) -> void:
	if definition == null:
		return

	# Не запускаем новый диалог поверх уже работающего.
	if is_playing:
		return

	dialogue = definition
	current_index = 0
	is_playing = true

	_process_next_element()

func stop() -> void:
	if not is_playing:
		return

	dialogue = null
	current_index = 0
	is_playing = false

func advance() -> void:
	if not is_playing:
		return

	_process_next_element()


func _process_next_element() -> void:
	if dialogue == null:
		return

	# Диалог закончился.
	if current_index >= dialogue.elements.size():
		_finish()
		return

	var element = dialogue.elements[current_index]
	current_index += 1

	if element is DialogueLine:
		line_started.emit(element)
		return

	if element is DialogueCommand:
		command_requested.emit(element)
		_process_next_element()
		return


func _finish() -> void:
	is_playing = false
	dialogue = null
	current_index = 0

	dialogue_finished.emit()
