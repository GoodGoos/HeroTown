extends Node


var player: DialoguePlayer


func _ready() -> void:
	var dialogue := DialogueRegistry.get_dialogue("first_meeting_airi")

	if dialogue == null:
		push_error("Диалог first_meeting_airi не найден.")
		return

	print("=== Dialogue Player Test ===")

	player = DialoguePlayer.new()

	player.line_started.connect(_on_line_started)
	player.command_requested.connect(_on_command_requested)
	player.dialogue_finished.connect(_on_dialogue_finished)

	player.play(dialogue)


func _on_line_started(line: DialogueLine) -> void:
	print(
		"LINE STARTED: ",
		line.character_id,
		" [",
		line.presentation_id,
		"] | ",
		line.text
	)


func _on_command_requested(command: DialogueCommand) -> void:
	print(
		"COMMAND: ",
		command.command,
		" | ARGUMENTS: ",
		command.arguments
	)


func _on_dialogue_finished() -> void:
	print("DIALOGUE FINISHED")
