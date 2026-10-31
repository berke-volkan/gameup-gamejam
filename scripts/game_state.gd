extends Node

signal state_changed
signal toast_requested(message: String)

var carbon_credits := 150
var company_level := 1
var employees := 1
var passive_income := 4
var score := 0
var energy_produced := 8
var energy_used := 42
var water_saved := 6
var emissions_avoided := 12
var waste_diverted := 4
var mini_grid: Array = []
var mini_moves := 18
var upgrades: Dictionary = {}
var hired: Dictionary = {}
var income_timer := 0.0

const UPGRADES := {
    "solar": {"name": "Güneş çatısı", "cost": 80, "income": 5, "level": 0, "description": "+5 CC • +28 enerji üretimi", "energy": 28, "water": 0, "emissions": 18, "waste": 0},
    "garden": {"name": "Dikey bahçe + kompost", "cost": 120, "income": 3, "level": 1, "description": "+12 su • +8 atık dönüşümü", "energy": 0, "water": 12, "emissions": 4, "waste": 8},
    "glass": {"name": "Akıllı yalıtım camı", "cost": 160, "income": 4, "level": 1, "description": "−12 enerji tüketimi • +10 emisyon", "energy": 0, "water": 0, "emissions": 10, "waste": 0},
    "rainwater": {"name": "Yağmur suyu deposu", "cost": 100, "income": 2, "level": 0, "description": "+22 su tasarrufu • gri su döngüsü", "energy": 0, "water": 22, "emissions": 3, "waste": 0},
    "mobility": {"name": "Bisiklet + EV şarjı", "cost": 130, "income": 3, "level": 0, "description": "+16 önlenen emisyon", "energy": 0, "water": 0, "emissions": 16, "waste": 0},
    "sorting": {"name": "Ayrıştırma istasyonu", "cost": 100, "income": 2, "level": 0, "description": "+24 atık dönüşümü", "energy": 0, "water": 0, "emissions": 5, "waste": 24}
}
const CANDIDATES := [
    {"id": "engineer", "name": "Deniz Aydın", "role": "Yenilenebilir Enerji Mühendisi", "cost": 90, "effect": "+4 CC / dk", "income": 4},
    {"id": "zero_waste", "name": "Ece Kaya", "role": "Sıfır Atık Uzmanı", "cost": 110, "effect": "Eko eşleşmelerinde +%25 CC", "income": 0},
    {"id": "auditor", "name": "Mert Yılmaz", "role": "Karbon Ayak İzi Denetçisi", "cost": 140, "effect": "+1 şirket seviyesi", "income": 1}
]

func _process(delta: float) -> void:
    income_timer += delta
    if income_timer >= 15.0:
        income_timer = 0.0
        carbon_credits += passive_income
        toast_requested.emit("Pasif gelir: +%d CC" % passive_income)
        state_changed.emit()

func buy_upgrade(id: String) -> bool:
    if upgrades.get(id, false):
        toast_requested.emit("Bu yükseltme zaten kurulu.")
        return false
    var item: Dictionary = UPGRADES[id]
    if carbon_credits < item.cost:
        toast_requested.emit("Yetersiz CC — birkaç eko görevi daha tamamla.")
        return false
    carbon_credits -= item.cost
    upgrades[id] = true
    passive_income += item.income
    company_level += item.level
    energy_produced += int(item.get("energy", 0))
    energy_used -= int(item.get("energy_use_reduction", 0))
    water_saved += int(item.get("water", 0))
    emissions_avoided += int(item.get("emissions", 0))
    waste_diverted += int(item.get("waste", 0))
    if id == "glass": energy_used -= 12
    state_changed.emit()
    toast_requested.emit("%s kuruldu!" % item.name)
    return true

func hire(candidate: Dictionary) -> bool:
    var id: String = candidate.id
    if hired.get(id, false):
        toast_requested.emit("Bu aday zaten EcoCorp ekibinde.")
        return false
    if carbon_credits < candidate.cost:
        toast_requested.emit("Yetersiz CC — aday için %d CC gerekiyor." % candidate.cost)
        return false
    carbon_credits -= candidate.cost
    hired[id] = true
    employees += 1
    passive_income += candidate.income
    if id == "auditor": company_level += 1
    state_changed.emit()
    toast_requested.emit("%s ekibe katıldı!" % candidate.name)
    return true

func add_match_reward(points: int, matches: int) -> void:
    var reward := matches * 3 + points / 10
    if hired.get("zero_waste", false): reward = int(ceil(reward * 1.25))
    score += points
    carbon_credits += reward
    emissions_avoided += matches * 2
    water_saved += matches
    state_changed.emit()
    toast_requested.emit("Eko zinciri! +%d CC" % reward)

func save_progress() -> void:
    var data = {"cc": carbon_credits, "level": company_level, "employees": employees, "income": passive_income, "upgrades": upgrades, "hired": hired, "score": score, "mini_grid": mini_grid, "mini_moves": mini_moves, "energy_produced": energy_produced, "energy_used": energy_used, "water_saved": water_saved, "emissions_avoided": emissions_avoided, "waste_diverted": waste_diverted}
    var file := FileAccess.open("user://ecocorp_save.json", FileAccess.WRITE)
    if file: file.store_string(JSON.stringify(data))

func load_progress() -> void:
    if not FileAccess.file_exists("user://ecocorp_save.json"): return
    var file := FileAccess.open("user://ecocorp_save.json", FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary:
        carbon_credits = int(parsed.get("cc", carbon_credits)); company_level = int(parsed.get("level", company_level)); employees = int(parsed.get("employees", employees)); passive_income = int(parsed.get("income", passive_income)); upgrades = parsed.get("upgrades", {}); hired = parsed.get("hired", {}); score = int(parsed.get("score", score)); mini_grid = parsed.get("mini_grid", []); mini_moves = int(parsed.get("mini_moves", mini_moves)); energy_produced = int(parsed.get("energy_produced", energy_produced)); energy_used = int(parsed.get("energy_used", energy_used)); water_saved = int(parsed.get("water_saved", water_saved)); emissions_avoided = int(parsed.get("emissions_avoided", emissions_avoided)); waste_diverted = int(parsed.get("waste_diverted", waste_diverted))
