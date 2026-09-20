class_name FlagCondition extends GameCondition

@export var flag_name: String = ""
@export var expected_value: bool = true

func is_met(_character_id: String) -> bool:
	# Проверяем наш GameManager
	return GameManager.get_flag(flag_name) == expected_value
