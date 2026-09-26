class_name dialogue_registry
extends Node

const DIALOGUES_PATH := "res://scripts/resources/dialogues"

var dialogues: Dictionary = {}


func _ready() -> void:
	load_dialogues()


func load_dialogues() -> void:
	dialogues.clear()

	var dir := DirAccess.open(DIALOGUES_PATH)
	if not dir:
		push_error("Не удалось открыть папку диалогов: " + DIALOGUES_PATH)
		return

	dir.list_dir_begin()

	while true:
		var file_name := dir.get_next()

		if file_name == "":
			break

		if dir.current_is_dir():
			continue

		if not file_name.ends_with(".txt"):
			continue

		_load_dialogue(DIALOGUES_PATH + "/" + file_name)

	dir.list_dir_end()


func _load_dialogue(path: String) -> void:
	var text := FileAccess.get_file_as_string(path)

	if text.is_empty():
		push_warning("Пустой файл диалога: " + path)
		return

	var parser := DialogueParser.new()
	var dialogue := parser.parse(text)

	if dialogue.id.is_empty():
		push_warning("У диалога нет ID: " + path)
		return

	if dialogues.has(dialogue.id):
		push_warning("Дублирующийся ID диалога: " + dialogue.id)
		return

	dialogues[dialogue.id] = dialogue


func get_dialogue(dialogue_id: String) -> DialogueDefinition:
	return dialogues.get(dialogue_id, null)


func has_dialogue(dialogue_id: String) -> bool:
	return dialogues.has(dialogue_id)


func get_all_dialogues() -> Array[DialogueDefinition]:
	var result: Array[DialogueDefinition] = []

	for dialogue_id in dialogues:
		result.append(dialogues[dialogue_id])

	return result
