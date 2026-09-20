extends CanvasLayer

# --- ЗАМЕНИ ПУТИ НА СВОИ УЗЛЫ В ДЕРЕВЕ ---
@onready var main_buttons: Control = $ColorRect/MainManu
@onready var save_load_menu: Control = $ColorRect/SaveMenu

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	save_load_menu.visible = false 
	
	# Подписываемся на сигналы от дочернего меню:
	save_load_menu.back_requested.connect(show_main_buttons)
	save_load_menu.load_completed.connect(_on_load_completed)

func _input(event: InputEvent) -> void:
	if not GameManager.is_in_game:
		return

	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	visible = !visible
	get_tree().paused = visible
	
	if visible:
		# Когда ставим на паузу, всегда показываем главные кнопки и прячем меню сейвов
		show_main_buttons()
	else:
		# Если сняли с паузы кнопкой ESC, жестко прячем меню сейвов
		save_load_menu.visible = false

# Эту функцию будет вызывать меню сохранений, когда мы нажмем в нем "Exit"
func show_main_buttons() -> void:
	main_buttons.visible = true
	save_load_menu.visible = false

# --- КНОПКИ ГЛАВНОГО МЕНЮ ПАУЗЫ ---

func _on_save_pressed() -> void:
	# Прячем кнопки меню паузы
	main_buttons.visible = false
	# Открываем меню в режиме SAVE (0)
	save_load_menu.open(0) 

func _on_load_pressed() -> void:
	main_buttons.visible = false
	# Открываем меню в режиме LOAD (1)
	save_load_menu.open(1)

func _on_options_pressed() -> void:
	print("Настройки...")

func _on_back_to_menu_pressed() -> void:
	
	
	# 1. Запускаем переход в главное меню
	Transition.change_scene("res://scenes/main_menu.tscn")
	
	# 2. ЖДЕМ, пока экран не станет полностью черным
	await Transition.screen_blacked_out
	
	# 3. Экран черный! Теперь безопасно отключаем HUD, игрок этого не увидит
	get_tree().paused = false
	visible = false
	GameManager.is_in_game = false

# Срабатывает, когда save_load_menu сообщает об успешной загрузке

func _on_load_completed() -> void:
	get_tree().paused = false 
	visible = false
