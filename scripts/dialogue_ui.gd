extends Control


signal dialogue_finished()


@onready var speaker_name: Label = $DialoguePanel/SpeakerName
@onready var dialogue_text: Label = $DialoguePanel/DialogueText
@onready var continue_button: Button = $ContinueButton

@onready var character_layer: DialogueCharacterLayer = $Characters

var player: DialoguePlayer = null


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	GameManager.game_loaded.connect(_on_game_loaded)

	# Временный запуск для проверки DialogueUI.
	var dialogue := DialogueRegistry.get_dialogue("first_meeting_airi")

	if dialogue != null:
		start_dialogue(dialogue)


func start_dialogue(
	definition: DialogueDefinition,
	start_index: int = 0,
	restore_character_state: bool = false
) -> void:
	
	if definition == null:
		return

	# Не создаём второй Player, если диалог уже идёт.
	if player != null and player.is_playing:
		return

	player = DialoguePlayer.new()
	
	GameManager.data.active_dialogue_id = definition.id
	GameManager.data.active_dialogue_index = start_index

	if not restore_character_state:
		GameManager.data.active_dialogue_characters = {}

	player.line_started.connect(_on_line_started)
	player.command_requested.connect(_on_command_requested)
	player.dialogue_finished.connect(_on_dialogue_finished)
	
	
	visible = true
	player.play(definition, start_index)
	if restore_character_state:
		restore_dialogue_character_state()


func _on_line_started(line: DialogueLine) -> void:
	# Пока выводим ID персонажа. Позже получим display_name через CharacterRegistry.
	speaker_name.text = line.character_id
	dialogue_text.text = line.text
	GameManager.data.active_dialogue_index = player.current_index


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

	_sync_dialogue_character_state()


func _on_dialogue_finished() -> void:
	player = null
	visible = false

	GameManager.data.active_dialogue_id = ""
	GameManager.data.active_dialogue_index = 0
	GameManager.data.active_dialogue_characters = {}

	dialogue_finished.emit()

func _on_game_loaded() -> void:
	if not GameManager.data.active_dialogue_id.is_empty():
		_restore_dialogue()

func _restore_dialogue() -> void:
	var dialogue_id := GameManager.data.active_dialogue_id
	var dialogue_index := GameManager.data.active_dialogue_index

	var dialogue := DialogueRegistry.get_dialogue(dialogue_id)

	if dialogue == null:
		push_warning("Не удалось восстановить диалог: " + dialogue_id)

		GameManager.data.active_dialogue_id = ""
		GameManager.data.active_dialogue_index = 0

		return

	start_dialogue(dialogue, dialogue_index, true)

func _sync_dialogue_character_state() -> void:
	if not GameManager.data:
		return

	GameManager.data.active_dialogue_characters = (
		character_layer.get_character_states()
	)

func restore_dialogue_character_state() -> void:
	if not GameManager.data:
		return

	character_layer.restore_character_states(
		GameManager.data.active_dialogue_characters
	)
