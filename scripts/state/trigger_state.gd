class_name trigger_state
extends RefCounted


# Сколько раз триггер сработал.
var execution_count: int = 0

# Был ли триггер отключён.
var disabled: bool = false

# Время последнего выполнения.
var last_execution_day: int = -1
var last_execution_time: int = -1


func to_dict() -> Dictionary:
	return {
		"execution_count": execution_count,
		"disabled": disabled,
		"last_execution_day": last_execution_day,
		"last_execution_time": last_execution_time
	}


func from_dict(data: Dictionary) -> void:
	execution_count = data.get("execution_count", 0)
	disabled = data.get("disabled", false)
	last_execution_day = data.get("last_execution_day", -1)
	last_execution_time = data.get("last_execution_time", -1)
