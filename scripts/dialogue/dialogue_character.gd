class_name DialogueCharacter
extends Control


var character_id: String = ""
var normalized_position: float = 0.5
var facing: String = "right"


func setup(id: String) -> void:
	character_id = id


func _draw() -> void:
	draw_rect(
		Rect2(-50, -150, 100, 150),
		Color.WHITE
	)
