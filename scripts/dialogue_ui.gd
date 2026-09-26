extends Control


@onready var speaker_name: Label = $DialoguePanel/SpeakerName
@onready var dialogue_text: Label = $DialoguePanel/DialogueText
@onready var continue_button: Button = $ContinueButton

@onready var character_layer: DialogueCharacterLayer = $Characters

var player: DialoguePlayer = null


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)

	# Временный запуск для проверки DialogueUI.
	var dialogue := DialogueRegistry.get_dialogue("first_meeting_airi")

	if dialogue != null:
		start_dialogue(dialogue)


func start_dialogue(definition: DialogueDefinition) -> void:
	if definition == null:
		return

	# Не создаём второй Player, если диалог уже идёт.
	if player != null and player.is_playing:
		return

	player = DialoguePlayer.new()

	player.line_started.connect(_on_line_started)
	player.command_requested.connect(_on_command_requested)
	player.dialogue_finished.connect(_on_dialogue_finished)

	visible = true
	player.play(definition)


func _on_line_started(line: DialogueLine) -> void:
	# Пока выводим ID персонажа. Позже получим display_name через CharacterRegistry.
	speaker_name.text = line.character_id
	dialogue_text.text = line.text


func _on_continue_pressed() -> void:
	if player == null:
		return

	player.advance()


func _on_command_requested(command: DialogueCommand) -> void:
	match command.command:
		"position":
			if command.arguments.size() < 2:
				return

			var character_id: String = command.arguments[0]
			var position: float = float(command.arguments[1])

			character_layer.set_character_position(
				character_id,
				position
			)

		"facing":
			if command.arguments.size() < 2:
				return

			var character_id: String = command.arguments[0]
			var direction: String = command.arguments[1]

			character_layer.set_facing(
				character_id,
				direction
			)


func _on_dialogue_finished() -> void:
	player = null
	visible = false
