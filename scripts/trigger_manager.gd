extends Node


# Проверяет и выполняет триггер.
func try_execute(
	trigger: trigger_definition,
	context: game_context
) -> bool:
	if trigger == null or context == null:
		return false

	if trigger.id.is_empty():
		return false

	var state := _get_or_create_state(trigger.id)

	# Отключённый триггер не выполняется.
	if state.disabled:
		return false

	# Одноразовый триггер после выполнения больше не работает.
	if not trigger.repeatable and state.execution_count > 0:
		return false

	# Все условия должны быть выполнены.
	for condition in trigger.conditions:
		if condition == null:
			continue

		if not condition.is_met(context):
			return false

	# Выполняем действия.
	for action in trigger.actions:
		if action == null:
			continue

		action.execute(context)

	# Запоминаем выполнение.
	state.execution_count += 1
	state.last_execution_day = context.game_data.current_day
	state.last_execution_time = context.game_data.current_time

	return true


# Получает состояние триггера или создаёт его.
func _get_or_create_state(trigger_id: String) -> trigger_state:
	if GameManager.data.trigger_states.has(trigger_id):
		return GameManager.data.trigger_states[trigger_id]

	var state := trigger_state.new()
	GameManager.data.trigger_states[trigger_id] = state

	return state
