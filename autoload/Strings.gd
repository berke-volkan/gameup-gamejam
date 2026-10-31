extends Node

var text: Dictionary = {}

func _ready() -> void:
	var file := FileAccess.open("res://data/strings.json", FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			text = parsed
		else:
			push_warning("Strings JSON sözlük olarak çözümlenemedi: res://data/strings.json")
	else:
		push_warning("Strings dosyası bulunamadı: res://data/strings.json")

func t(key: String, fallback: String = "") -> String:
	if not text.has(key):
		push_warning("Eksik string anahtarı: %s" % key)
		return fallback
	return str(text[key])
