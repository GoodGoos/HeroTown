class_name trigger_definition
extends Resource


# ID события.
@export var id: String = ""

# Название события для игрока.
@export var display_name: String = ""

# Локация, в которой событие доступно.
@export var location_id: String = ""

# Можно ли выполнять событие повторно.
@export var repeatable: bool = false

# Условия доступности события.
@export var conditions: Array[game_condition] = []

# Действия после выбора события.
@export var actions: Array[game_action] = []
