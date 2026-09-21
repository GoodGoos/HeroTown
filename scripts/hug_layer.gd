extends CanvasLayer

@onready var time_label: Label = $Control/ColorRect/Label
@onready var event_panel = $Control/EventPanel
@onready var event_list = $Control/EventPanel/EventList

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
	refresh_events()
	await Transition.screen_blacked_out
	GameManager.advance_time()

func refresh_events() -> void:
	# Пока используем текущее состояние игры.
	var context := game_context.new(GameManager.data)

	var available_triggers := TriggerRegistry.get_available_triggers(context)

	# Показываем панель только если есть события.
	event_panel.visible = not available_triggers.is_empty()

	print("Доступных событий: ", available_triggers.size())

	for trigger in available_triggers:
		print("Событие: ", trigger.display_name)

# Сигнал от кнопки карты
func _on_emap_button_pressed() -> void:
	# Если в Автозагрузке имя узла указано как map_hug (или MapHud):
	if MapHug and MapHug.has_method("toggle_map"):
		MapHug.toggle_map()
