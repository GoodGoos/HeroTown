extends CanvasLayer

@onready var time_label: Label = $Control/ColorRect/Label
@onready var event_panel: ColorRect = $Control/EventPanel
@onready var event_list: VBoxContainer = $Control/EventPanel/EventList

@onready var map_hud: CanvasLayer = $"res://scenes/map_hug.tscn"

const EVENT_BUTTON_SCENE = preload("res://scenes/event_button.tscn")


func _ready() -> void:
	GameManager.game_state_changed.connect(_on_game_state_changed)
	GameManager.time_changed.connect(_on_time_changed)

	visible = GameManager.is_in_game
	update_hud()
	refresh_events()


func _on_game_state_changed(is_active: bool) -> void:
	visible = is_active

	if is_active:
		update_hud()
		refresh_events()


func _on_time_changed() -> void:
	update_hud()
	refresh_events()


func update_hud() -> void:
	time_label.text = GameManager.get_time_string()


func refresh_events() -> void:
	if not GameManager.data:
		event_panel.visible = false
		return

	var context := game_context.new(GameManager.data)
	var available_triggers := TriggerRegistry.get_available_triggers(context)

	# Удаляем старые кнопки.
	for child in event_list.get_children():
		child.queue_free()

	event_panel.visible = not available_triggers.is_empty()

	for trigger in available_triggers:
		var event_button = EVENT_BUTTON_SCENE.instantiate()

		event_list.add_child(event_button)

		var button: Button = event_button.get_node("Button")
		button.text = trigger.display_name


func _on_skip_time_button_pressed() -> void:
	
	if not visible:
		return
		
	Transition.change_scene("")
	await Transition.screen_blacked_out
	GameManager.advance_time()


func _on_emap_button_pressed() -> void:
	if MapHug and MapHug.has_method("toggle_map"):
		MapHug.toggle_map()
