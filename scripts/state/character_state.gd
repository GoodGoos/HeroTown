class_name CharacterState
extends RefCounted

var id: String = ""

var stats: Dictionary = {
	"stress": 0.0,
	"arousal": 0.0,
	"burst": 0.0
}

var mood: String = ""
var current_location: String = ""
var flags: Dictionary = {}
var relationships: Dictionary = {}

func to_dict() -> Dictionary:
	return {
		"id": id,
		"stats": stats.duplicate(true),
		"mood": mood,
		"current_location": current_location,
		"flags": flags.duplicate(true),
		"relationships": relationships.duplicate(true)
	}

func from_dict(data: Dictionary) -> void:
	id = data.get("id", "")
	stats = data.get("stats", {}).duplicate(true)
	mood = data.get("mood", "")
	current_location = data.get("current_location", "")
	flags = data.get("flags", {}).duplicate(true)
	relationships = data.get("relationships", {}).duplicate(true)
