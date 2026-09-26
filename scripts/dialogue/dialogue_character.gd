class_name DialogueCharacter
extends Control


var character_id: String = ""
var normalized_position: float = 0.5
var facing: String = "right"

# Размер визуального представления персонажа.
var character_size := Vector2(300.0, 650.0)

# Проверка речи
var is_speaking: bool = false
var speaking_tween: Tween = null

const NORMAL_MODULATE := Color.WHITE
const DIMMED_MODULATE := Color(0.65, 0.65, 0.65, 1.0)

func setup(id: String) -> void:
	character_id = id
	
func _ready() -> void:
	modulate = DIMMED_MODULATE
	
func _draw() -> void:
	draw_rect(
		Rect2(
			-character_size.x / 2.0,
			-character_size.y,
			character_size.x,
			character_size.y
		),
		Color.WHITE
	)

func set_speaking(value: bool) -> void:
	if is_speaking == value:
		return

	is_speaking = value

	if speaking_tween != null and speaking_tween.is_valid():
		speaking_tween.kill()

	var target_modulate := NORMAL_MODULATE

	if not is_speaking:
		target_modulate = DIMMED_MODULATE

	speaking_tween = create_tween()

	speaking_tween.tween_property(
		self,
		"modulate",
		target_modulate,
		0.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
