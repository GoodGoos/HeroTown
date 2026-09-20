class_name GameCondition extends Resource

# Этот метод будут переопределять все твои будущие условия
func is_met(character_id: String) -> bool:
	return false # По умолчанию всегда false
