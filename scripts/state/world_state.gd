class_name WorldState
extends RefCounted

var flags: Dictionary = {}
var variables: Dictionary = {}

func to_dict() -> Dictionary:
	return {
		"flags": flags.duplicate(true),
		"variables": variables.duplicate(true)
	}

func from_dict(data: Dictionary) -> void:
	flags = data.get("flags", {}).duplicate(true)
	variables = data.get("variables", {}).duplicate(true)
