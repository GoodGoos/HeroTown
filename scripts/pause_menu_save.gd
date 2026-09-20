extends Control

signal back_requested
signal load_completed

enum MenuMode { SAVE, LOAD }
var current_mode: MenuMode = MenuMode.SAVE
var current_page: String = "1" # Страницы: "A", "1", "2"..."9"

# --- ПУТИ К УЗЛАМ (По твоему скриншоту) ---
@onready var title_label: Label = $SaveMenuPanel/Label
@onready var cards_container: Control = $SaveMenuPanel/SaveCard
@onready var pages_container: Control = $SaveMenuPanel/PageBut

# ⚠️ ВНИМАНИЕ: ЗАМЕНИ ПУТИ НА СВОИ! На скриншоте их не видно в дереве
@onready var toggle_mode_btn: Button = $"SaveMenuPanel/SysBut/Save\\Load" 
@onready var exit_btn: Button = $SaveMenuPanel/SysBut/Exit   


func _ready() -> void:
	visible = false
	
	# 1. АВТО-ПОДКЛЮЧЕНИЕ 6 КАРТОЧЕК-КНОПОК (Слотов)
	var card_index = 1
	for card in cards_container.get_children():
		if card is Button: # Теперь мы знаем, что это кнопки
			# Привязываем нажатие сразу к функции обработки слота
			card.pressed.connect(handle_slot_action.bind(card_index))
		card_index += 1
		
	# 2. АВТО-ПОДКЛЮЧЕНИЕ КНОПОК СТРАНИЦ (A, 1, 2... 9)
	var page_index = 0
	for btn in pages_container.get_children():
		if btn is Button:
			# Первая кнопка - это "A" (Автосохранения), остальные 1-9
			var page_id = "A" if page_index == 0 else str(page_index)
			btn.pressed.connect(_on_page_pressed.bind(page_id))
		page_index += 1
		
	# 3. Подключение нижних кнопок (Load/Save и Exit)
	if toggle_mode_btn: toggle_mode_btn.pressed.connect(_on_toggle_mode_pressed)
	if exit_btn: exit_btn.pressed.connect(close_menu)


# --- ОТКРЫТИЕ И ОБНОВЛЕНИЕ UI ---
func open(mode: MenuMode) -> void:
	current_mode = mode
	update_ui()
	visible = true

func update_ui() -> void:
	if current_mode == MenuMode.SAVE:
		title_label.text = "Сохранение"
		if toggle_mode_btn: toggle_mode_btn.text = "Load"
	else:
		title_label.text = "Загрузка"
		if toggle_mode_btn: toggle_mode_btn.text = "Save"
		
	refresh_cards_display()


# --- ЛОГИКА СТРАНИЦ И КЛИКОВ ПО СЛОТАМ ---
func _on_page_pressed(page_id: String) -> void:
	current_page = page_id
	refresh_cards_display()


func handle_slot_action(slot_index: int) -> void:
	var save_id: String = ""
	
	if current_page == "A":
		if current_mode == MenuMode.SAVE:
			print("Внимание: Нельзя сохранять в слоты автосохранения вручную!")
			return # Блокируем сохранение
		save_id = "auto_" + str(slot_index)
	else:
		save_id = "page_" + current_page + "_slot_" + str(slot_index)
		
	if current_mode == MenuMode.SAVE:
		GameManager.save_game(save_id)
		refresh_cards_display() # Обновляем текст на карточке после сохранения
		
	elif current_mode == MenuMode.LOAD:
		if GameManager.load_game(save_id):
			load_completed.emit() # Игра загружена! Закрываем меню и паузу.


# --- ЧТЕНИЕ ФАЙЛОВ И ОТРИСОВКА ---
func refresh_cards_display() -> void:
	var cards = cards_container.get_children()
	for i in range(cards.size()):
		var card = cards[i]
		var text_label = card.get_node_or_null("Label2")
		if not text_label:
			continue
			
		var slot_index = i + 1
		var save_id = "auto_" + str(slot_index) if current_page == "A" else "page_" + current_page + "_slot_" + str(slot_index)
		
		var meta = GameManager.get_save_metadata(save_id)
		if not meta.is_empty():
			var real_date = meta.get("real_date", "??.??.????")
			var real_time = meta.get("real_time", "??:??")
			text_label.text = "Дата: %s Время: %s" % [real_date, real_time]
		else:
			text_label.text = "Пустой слот"


# --- ВСПОМОГАТЕЛЬНОЕ ---
func _on_toggle_mode_pressed() -> void:
	current_mode = MenuMode.LOAD if current_mode == MenuMode.SAVE else MenuMode.SAVE
	update_ui()

func close_menu() -> void:
	visible = false
	back_requested.emit()
