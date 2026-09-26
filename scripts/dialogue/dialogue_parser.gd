class_name DialogueParser
extends RefCounted

func parse(text: String) -> DialogueDefinition:
	var dialogue := DialogueDefinition.new()

	var lines := text.split("\n")

	for line in lines:
		line = line.strip_edges()

		# Пропускаем пустые строки и комментарии.
		if line.is_empty() or line.begins_with("#"):
			continue

		# ID относится ко всему диалогу, а не к отдельному элементу.
		if line.begins_with("id:"):
			dialogue.id = _parse_id(line)
			continue

		# Строки с @ являются командами сценария.
		if line.begins_with("@"):
			var command := _parse_command(line)
			if command != null:
				dialogue.elements.append(command)
			continue

		# Остальные строки считаем репликами.
		var dialogue_line := _parse_line(line)
		if dialogue_line != null:
			dialogue.elements.append(dialogue_line)

	return dialogue


func _parse_command(line: String) -> DialogueCommand:
	# Убираем @ и разделяем команду на имя и аргументы.
	var parts := line.substr(1).split(" ", false)

	if parts.is_empty():
		return null

	var command := DialogueCommand.new()
	command.command = parts[0]
	command.arguments = parts.slice(1)

	return command


func _parse_line(line: String) -> DialogueLine:
	# Двоеточие отделяет говорящего от текста.
	var colon_index := line.find(":")
	if colon_index == -1:
		return null

	var speaker := line.substr(0, colon_index).strip_edges()
	var content := line.substr(colon_index + 1).strip_edges()

	if speaker.is_empty() or content.is_empty():
		return null

	var dialogue_line := DialogueLine.new()

	# Если у персонажа указана презентация, отделяем её от ID.
	var presentation_start := speaker.find("[")
	var presentation_end := speaker.find("]")

	if presentation_start != -1 and presentation_end > presentation_start:
		dialogue_line.character_id = speaker.substr(
			0,
			presentation_start
		).strip_edges()

		dialogue_line.presentation_id = speaker.substr(
			presentation_start + 1,
			presentation_end - presentation_start - 1
		).strip_edges()
	else:
		dialogue_line.character_id = speaker

	# Убираем внешние кавычки текста.
	if content.begins_with("\"") and content.ends_with("\""):
		content = content.substr(1, content.length() - 2)

	dialogue_line.text = content

	return dialogue_line


func _parse_id(line: String) -> String:
	# ID хранится после "id:" и может быть заключён в кавычки.
	var value := line.substr(3).strip_edges()

	if value.begins_with("\"") and value.ends_with("\""):
		value = value.substr(1, value.length() - 2)

	return value
