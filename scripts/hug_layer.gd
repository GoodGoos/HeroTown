extends CanvasLayer

@onready var time_label: Label = $Control/ColorRect/Label
@onready var map_hud: CanvasLayer = $"res://scenes/map_hug.tscn" # Путь к узлу MapHud

func _ready() -> void:
	GameManager.game_state_changed.connect(_on_game_state_changed)
	GameManager.time_changed.connect(update_hud)
	visible = GameManager.is_in_game
	update_hud()

func _on_game_state_changed(is_active: bool) -> void:
	visible = is_active
	if is_active:
		update_hud()

func update_hud() -> void:
	time_label.text = GameManager.get_time_string()

func _on_skip_time_button_pressed() -> void:
	
	if not visible:
		return
		
	Transition.change_scene("")
	await Transition.screen_blacked_out
	GameManager.advance_time()


# Сигнал от кнопки карты
func _on_emap_button_pressed() -> void:
	# Если в Автозагрузке имя узла указано как map_hug (или MapHud):
	if MapHug and MapHug.has_method("toggle_map"):
		MapHug.toggle_map()
