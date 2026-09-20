class_name character_profile extends Resource

# Уникальный ID (например, "airi"). Используем его для сохранения в JSON
@export var id: String = ""

# Имя для интерфейса
@export var display_name: String = ""

# Базовые характеристики (ключ - имя шкалы, значение - начальное значение)
# Здесь задаем только "имена" шкал, которые этот персонаж использует
@export var initial_stats: Dictionary = {
	"stress": 0.0,
	"arousal": 0.0,
	"burst": 0.0
}

# Ссылка на таблицу переходов настроений (пока оставляем место, добавим позже)
@export var mood_profile: Resource = null 

# Позволяет ли игра "генерировать" этого персонажа или он уникальный
@export var is_unique: bool = true
