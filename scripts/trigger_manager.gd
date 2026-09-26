extends Node


var active_trigger: trigger_definition = null
var active_context: game_context = null
var active_action_index: int = 0
var is_executing: bool = false


func try_execute(
	trigger: trigger_definition,
	context: game_context
) -> bool:
	if trigger == null or context == null:
		return false

	if is_executing:
		return false

	if trigger.id.is_empty():
		return false

	var state := _get_or_create_state(trigger.id)

	if state.disabled:
		return false

	if not trigger.repeatable and state.execution_count > 0:
		return false

	# Проверяем условия перед запуском.
	for condition in trigger.conditions:
		if condition == null:
			continue

		if not condition.is_met(context):
			return false

	active_trigger = trigger
	active_context = context
	active_action_index = 0
	is_executing = true

	_execute_next_action()

	return true


func _execute_next_action() -> void:
	if active_trigger == null or active_context == null:
		_finish_trigger(false)
		return

	# Все действия выполнены.
	if active_action_index >= active_trigger.actions.size():
		_finish_trigger(true)
		return

	var action: game_action = active_trigger.actions[active_action_index]
	active_action_index += 1

	if action == null:
		_execute_next_action()
		return

	# Подписываемся ДО выполнения действия.
	action.finished.connect(_on_action_finished, CONNECT_ONE_SHOT)

	var completed_immediately := action.execute(active_context)

	# Обычное действие завершилось сразу.
	if completed_immediately:
		action.finished.disconnect(_on_action_finished)
		_execute_next_action()


func _on_action_finished() -> void:
	_execute_next_action()


func _finish_trigger(success: bool) -> void:
	if success and active_trigger != null and active_context != null:
		var state := _get_or_create_state(active_trigger.id)

		state.execution_count += 1
		state.last_execution_day = active_context.game_data.current_day
		state.last_execution_time = active_context.game_data.current_time

	active_trigger = null
	active_context = null
	active_action_index = 0
	is_executing = false


func _get_or_create_state(trigger_id: String) -> trigger_state:
	if GameManager.data.trigger_states.has(trigger_id):
		return GameManager.data.trigger_states[trigger_id]

	var state := trigger_state.new()
	GameManager.data.trigger_states[trigger_id] = state

	return state
