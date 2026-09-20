extends Control

# Функция для кнопки "Новая игра"
func _on_button_pressed() -> void:
	GameManager.reset_game()
	Transition.change_scene("res://scenes/player_room.tscn")
	
	# Ждем, пока экран полностью потемнеет
	await Transition.screen_blacked_out
	
	# Включаем игру
	GameManager.is_in_game = true
	
# Функция для кнопки "Выход"
func _on_button_2_pressed() -> void:
	# Закрывает игру
	get_tree().quit()

func _on_save_pressed() -> void:
	GameManager.save_game()

func _on_load_pressed() -> void:
	GameManager.load_game()
	# После загрузки можно опционально закрыть меню паузы, чтобы игрок продолжил играть
