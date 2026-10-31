extends Node

signal changed

var year := 1
var cash := 120
var reputation := 50
var impact := 0
var morale := 70
var trust := 45
var honesty := 60
var cards_played := 0
var greenwash_risk := 0
var detective_score := 0
var detective_errors := 0
var pending_effects: Array[Dictionary] = []
var history: Array[Dictionary] = []
var visited_cases: Array[String] = []
var research: Dictionary = {}

func reset() -> void:
	year = 1; cash = 120; reputation = 50; impact = 0; morale = 70; trust = 45; honesty = 60
	cards_played = 0; greenwash_risk = 0; detective_score = 0; detective_errors = 0
	pending_effects.clear(); history.clear(); visited_cases.clear(); research.clear(); changed.emit()

func apply_effect(effect: Dictionary) -> void:
	for key in effect.keys():
		if key in ["cash", "reputation", "impact", "morale", "trust", "honesty", "greenwash_risk"]:
			set(key, clampi(int(get(key)) + int(effect[key]), 0 if key != "cash" else -999, 100000 if key == "cash" else 100))
	changed.emit()
