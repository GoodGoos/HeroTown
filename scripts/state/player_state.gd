class_name PlayerState
extends RefCounted

var stats: Dictionary = {}
var flags: Dictionary = {}
var variables: Dictionary = {}

func to_dict() -> Dictionary:
	return {
		"stats": stats.duplicate(true),
		"flags": flags.duplicate(true),
		"variables": variables.duplicate(true)
	}

func from_dict(data: Dictionary) -> void:
	stats = data.get("stats", {}).duplicate(true)
	flags = data.get("flags", {}).duplicate(true)
	variables = data.get("variables", {}).duplicate(true)
