extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

signal screen_blacked_out

# Добавили callback: Callable = Callable()
func change_scene(target_path: String, callback: Callable = Callable()) -> void:
	if not animation_player:
		return
	
	# 1. Поднимаем слой поверх ВСЕХ интерфейсов и перехватываем клики
	layer = 100
	if color_rect:
		color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Анимация затемнения
	animation_player.play("fade")
	await screen_blacked_out 
	
	# 3. ТУТ ЭКРАН ЧЕРНЫЙ. Выполняем твой коллбэк (загрузку данных)
	if callback.is_valid():
		callback.call()
	
	# 4. Смена сцены
	if target_path != "":
		get_tree().change_scene_to_file(target_path)
	
	# 5. Анимация открытия
	animation_player.play_backwards("fade")
	await animation_player.animation_finished
	
	# 6. Убираем слой вниз
	layer = 1
	if color_rect:
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_screen_is_black() -> void:
	# Эта функция вызывается ключом из AnimationPlayer в конце затемнения
	screen_blacked_out.emit()
