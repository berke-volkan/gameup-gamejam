extends Control

const BG := Color("#071512")
const PANEL := Color("#102c25")
const PANEL_2 := Color("#194238")
const CREAM := Color("#f4f1df")
const MUTED := Color("#9cb9aa")
const MINT := Color("#9be6b4")
const TURQUOISE := Color("#55d6c2")
const YELLOW := Color("#f4c95d")
const ORANGE := Color("#f39a62")
const RED := Color("#ef7468")

const MAZE := [
	"############",
	"#S..#....E.#",
	"#.#.#.##.#.#",
	"#.#...#..#.#",
	"#.###.#.##.#",
	"#...#....P.#",
	"#.#.####.#.#",
	"#M..#....X.#",
	"############"
]

class MazeView extends Control:
	var game: Control
	func _draw() -> void:
		if game:
			game._draw_maze(self)
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			var cell: Vector2i = game._maze_cell_from_point(event.position, size)
			if cell.x >= 0:
				game._try_move_to(cell)

var phase := "menu"
var root_ui: Control
var maze_view: MazeView
var player := Vector2i(1, 1)
var drone := Vector2i(9, 5)
var temperature := 58.0
var hacked := {"energy": false, "waste": false, "server": false}
var terminal_kind := ""
var mini_step := 0
var waste_item := 0
var server_order: Array[String] = []
var server_target := ["CO₂", "TRUE", "COP31"]
var drone_tick := 0.0
var toast: Label

func _ready() -> void:
	set_process(true)
	_show_menu()

func _process(delta: float) -> void:
	if phase == "maze":
		temperature += delta * 0.7
		drone_tick += delta
		if drone_tick > 1.6:
			drone_tick = 0.0
			_move_drone()
			if drone == player:
				temperature += 7.0
				player = Vector2i(1, 1)
				_toast("Güvenlik dronu seni gördü! İzini kaybettin. +7°C")
			if temperature >= 100.0:
				_show_end(false)
			_update_hud()
			maze_view.queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if phase != "maze": return
	var dir := Vector2i.ZERO
	if event.is_action_pressed("ui_up"): dir = Vector2i.UP
	elif event.is_action_pressed("ui_down"): dir = Vector2i.DOWN
	elif event.is_action_pressed("ui_left"): dir = Vector2i.LEFT
	elif event.is_action_pressed("ui_right"): dir = Vector2i.RIGHT
	if dir != Vector2i.ZERO: _try_move_to(player + dir)

func _clear() -> void:
	for child in get_children(): child.queue_free()
	root_ui = Control.new()
	root_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root_ui)
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_ui.add_child(bg)

func _show_menu() -> void:
	phase = "menu"
	_clear()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 86)
	margin.add_theme_constant_override("margin_right", 86)
	margin.add_theme_constant_override("margin_top", 58)
	margin.add_theme_constant_override("margin_bottom", 46)
	root_ui.add_child(margin)
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 54)
	margin.add_child(cols)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.alignment = BoxContainer.ALIGNMENT_CENTER
	copy.add_theme_constant_override("separation", 14)
	cols.add_child(copy)
	copy.add_child(_label("COP31 ANTALYA  /  ECO-BREACH", 17, YELLOW))
	copy.add_child(_label("YEŞİL SIZINTI", 64, CREAM))
	copy.add_child(_label("Şirketin gerçeğini sızdır. Geleceği kurtar.", 24, MINT))
	var intro := _label("İklim Dedektifi olarak yüksek güvenlikli EcoCorp veri merkezine sız.\nÜç terminali hackle, +1,5°C eşiğini aşmadan gerçek raporu COP31'e ulaştır.", 20, MUTED)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(intro)
	var spacer := Control.new(); spacer.custom_minimum_size.y = 18; copy.add_child(spacer)
	var start := _button("OPERASYONU BAŞLAT  →", YELLOW, BG)
	start.custom_minimum_size = Vector2(350, 70); start.pressed.connect(_start_game); copy.add_child(start)
	var how := _button("NASIL OYNANIR?", Color.TRANSPARENT, CREAM)
	how.custom_minimum_size.y = 58; how.pressed.connect(_show_tutorial); copy.add_child(how)
	var art := _panel(); art.custom_minimum_size = Vector2(430, 500); cols.add_child(art)
	var art_box := VBoxContainer.new(); art_box.alignment = BoxContainer.ALIGNMENT_CENTER; art_box.add_theme_constant_override("separation", 14); art.add_child(art_box)
	art_box.add_child(_label("◈  ECOCORP  ◈", 25, TURQUOISE))
	art_box.add_child(_label("GÜVENLİK KATı\n/  KAT 07", 33, CREAM))
	var preview := TextureRect.new(); preview.texture = load("res://assets/ui/kenney_ui_sample.png"); preview.custom_minimum_size = Vector2(360, 170); preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; preview.modulate = Color(1, 1, 1, .65); art_box.add_child(preview)
	art_box.add_child(_label("3 terminal  •  1 kaçış\nHer hack koridoru yeşile döndürür.", 18, MUTED))
	art_box.add_child(_label("KENNEY UI / CC0", 13, YELLOW))
	toast = _label("", 16, YELLOW); toast.position = Vector2(0, 682); toast.size = Vector2(1280, 24); toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; root_ui.add_child(toast)

func _show_tutorial() -> void:
	var overlay := ColorRect.new(); overlay.color = Color(0.01, 0.04, 0.03, .92); overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); overlay.mouse_filter = Control.MOUSE_FILTER_STOP; root_ui.add_child(overlay)
	var center := CenterContainer.new(); center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); overlay.add_child(center)
	var box := _panel(); box.custom_minimum_size = Vector2(650, 330); center.add_child(box)
	var col := VBoxContainer.new(); col.add_theme_constant_override("separation", 16); box.add_child(col)
	col.add_child(_label("OPERASYON BRİFİ", 30, YELLOW))
	var body := _label("WASD / ok tuşları veya ekrandaki yön tuşlarıyla ilerle.\nYeşil terminal karelerine gelince HACK düğmesi açılır.\nEnerji, atık ve ana sunucu bulmacalarını çöz.\nDronlara yakalanma; sıcaklık 100'e çıkarsa geri dönüş yok.\nÜç terminal tamamlanınca çıkış kapısı açılır.", 19, CREAM); body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; col.add_child(body)
	var close := _button("ANLAŞILDI  →", MINT, BG); close.custom_minimum_size.y = 60; close.pressed.connect(overlay.queue_free); col.add_child(close)

func _start_game() -> void:
	player = Vector2i(1, 1); drone = Vector2i(9, 5); temperature = 58.0; hacked = {"energy": false, "waste": false, "server": false}; _show_maze()

func _show_maze() -> void:
	phase = "maze"; _clear()
	var main := VBoxContainer.new(); main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); main.offset_left = 34; main.offset_right = -34; main.offset_top = 22; main.offset_bottom = -20; main.add_theme_constant_override("separation", 10); root_ui.add_child(main)
	var header := HBoxContainer.new(); header.custom_minimum_size.y = 54; main.add_child(header)
	header.add_child(_label("YEŞİL SIZINTI  /  KAT 07", 20, CREAM)); var fill := Control.new(); fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL; header.add_child(fill)
	var temp_text := _label("+1,5°C DEVRİLME NOKTASI", 17, ORANGE); temp_text.name = "TempLabel"; header.add_child(temp_text)
	var bar := ProgressBar.new(); bar.name = "TempBar"; bar.max_value = 100; bar.value = temperature; bar.show_percentage = false; bar.custom_minimum_size = Vector2(250, 22); bar.add_theme_stylebox_override("background", _style(PANEL_2, 8)); bar.add_theme_stylebox_override("fill", _style(ORANGE, 8)); header.add_child(bar)
	var content := HBoxContainer.new(); content.size_flags_vertical = Control.SIZE_EXPAND_FILL; content.add_theme_constant_override("separation", 14); main.add_child(content)
	maze_view = MazeView.new(); maze_view.game = self; maze_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL; maze_view.size_flags_vertical = Control.SIZE_EXPAND_FILL; maze_view.custom_minimum_size = Vector2(720, 470); content.add_child(maze_view)
	var side := _panel(); side.custom_minimum_size.x = 330; content.add_child(side); _build_side_panel(side)
	var footer := HBoxContainer.new(); footer.custom_minimum_size.y = 66; footer.add_theme_constant_override("separation", 10); main.add_child(footer)
	for data in [["↑", Vector2i.UP], ["←", Vector2i.LEFT], ["↓", Vector2i.DOWN], ["→", Vector2i.RIGHT]]:
		var b := _button(data[0], PANEL_2, CREAM); b.custom_minimum_size = Vector2(74, 58); b.pressed.connect(func(): _try_move_to(player + data[1])); footer.add_child(b)
	var hint := _label("HACK için terminal karesine bas veya yanına gel.", 16, MUTED); hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; footer.add_child(hint)

func _build_side_panel(parent: Control) -> void:
	var col := VBoxContainer.new(); col.add_theme_constant_override("separation", 11); parent.add_child(col)
	col.add_child(_label("GÖREV KONSOLU", 15, YELLOW)); col.add_child(_label("Gerçeği görünür kıl.", 23, CREAM))
	var status := _label("", 17, MUTED); status.name = "Status"; status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; col.add_child(status)
	col.add_child(_label("TERMİNALLER", 14, YELLOW))
	for key in ["energy", "waste", "server"]:
		var label := _label(_terminal_name(key), 18, MINT if hacked[key] else CREAM); label.name = key; col.add_child(label)
	var spacer := Control.new(); spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL; col.add_child(spacer)
	var hack := _button("HACK BAŞLAT  ⌁", MINT, BG); hack.name = "HackButton"; hack.custom_minimum_size.y = 64; hack.pressed.connect(_hack_nearby); col.add_child(hack)
	var exit := _label("ÇIKIŞ: %s" % ("AÇIK" if _all_hacked() else "KİLİTLİ"), 17, YELLOW); exit.name = "ExitLabel"; col.add_child(exit)
	var home := _button("OPERASYONU BIRAK", Color.TRANSPARENT, MUTED); home.custom_minimum_size.y = 48; home.pressed.connect(_show_menu); col.add_child(home)

func _draw_maze(view: Control) -> void:
	var cell := minf(view.size.x / 12.0, view.size.y / 9.0)
	var origin := Vector2((view.size.x - cell * 12.0) / 2.0, (view.size.y - cell * 9.0) / 2.0)
	for y in range(MAZE.size()):
		for x in range(MAZE[y].length()):
			var ch: String = str(MAZE[y][x]); var rect := Rect2(origin + Vector2(x, y) * cell, Vector2(cell - 2, cell - 2))
			var color := Color("#0b211c") if ch == "#" else Color("#17372e")
			if ch != "#" and _all_hacked(): color = Color("#1e4c3b")
			view.draw_rect(rect, color)
			if ch == "#": view.draw_rect(rect.grow(-4), Color("#21483d"))
			elif ch in ["E", "P", "M"] and not hacked[_kind_for_char(ch)]: view.draw_circle(rect.get_center(), cell * .28, _terminal_color(ch))
			elif ch == "X": view.draw_rect(rect.grow(-8), MINT if _all_hacked() else RED)
			if Vector2i(x, y) == drone: view.draw_circle(rect.get_center(), cell * .23, RED)
			if Vector2i(x, y) == player: view.draw_circle(rect.get_center(), cell * .25, YELLOW)
			if ch in ["E", "P", "M", "X"]: view.draw_string(ThemeDB.fallback_font, rect.position + Vector2(cell*.37, cell*.65), ch, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, BG)

func _maze_cell_from_point(point: Vector2, view_size: Vector2) -> Vector2i:
	var cell := minf(view_size.x / 12.0, view_size.y / 9.0); var origin := Vector2((view_size.x - cell * 12.0) / 2.0, (view_size.y - cell * 9.0) / 2.0); var p := (point - origin) / cell; var c := Vector2i(floor(p.x), floor(p.y))
	return c if c.x >= 0 and c.x < 12 and c.y >= 0 and c.y < 9 else Vector2i(-1, -1)

func _try_move_to(target: Vector2i) -> void:
	if phase != "maze" or target.x < 0 or target.y < 0 or target.y >= MAZE.size() or target.x >= MAZE[target.y].length(): return
	if MAZE[target.y][target.x] == "#": return
	if abs(target.x - player.x) + abs(target.y - player.y) > 1: return
	player = target
	var ch: String = str(MAZE[player.y][player.x])
	if ch == "X":
		if _all_hacked(): _show_end(true)
		else: _toast("Çıkış kilitli. Üç terminali de hackle.")
	if ch in ["E", "P", "M"] and not hacked[_kind_for_char(ch)]: _toast("Terminal bulundu. HACK BAŞLAT düğmesine bas.")
	maze_view.queue_redraw()
	_update_hud()

func _hack_nearby() -> void:
	for pos in [player, player + Vector2i.UP, player + Vector2i.DOWN, player + Vector2i.LEFT, player + Vector2i.RIGHT]:
		if pos.y >= 0 and pos.y < MAZE.size() and pos.x >= 0 and pos.x < MAZE[pos.y].length():
			var ch: String = str(MAZE[pos.y][pos.x])
			if ch in ["E", "P", "M"] and not hacked[_kind_for_char(ch)]:
				terminal_kind = _kind_for_char(ch); _show_terminal(); return
	_toast("Yakında hacklenebilir terminal yok.")

func _show_terminal() -> void:
	phase = "terminal"; _clear(); mini_step = 0; waste_item = 0; server_order.clear()
	var margin := MarginContainer.new(); margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); margin.add_theme_constant_override("margin_left", 110); margin.add_theme_constant_override("margin_right", 110); margin.add_theme_constant_override("margin_top", 58); margin.add_theme_constant_override("margin_bottom", 54); root_ui.add_child(margin)
	var box := _panel(); margin.add_child(box); var col := VBoxContainer.new(); col.add_theme_constant_override("separation", 14); box.add_child(col)
	col.add_child(_label(_terminal_title(), 34, YELLOW)); col.add_child(_label(_terminal_body(), 19, MUTED))
	var play := VBoxContainer.new(); play.name = "MiniGame"; play.add_theme_constant_override("separation", 12); play.size_flags_vertical = Control.SIZE_EXPAND_FILL; col.add_child(play)
	_build_minigame(play)
	var cancel := _button("GERİ DÖN  ←", Color.TRANSPARENT, MUTED); cancel.custom_minimum_size.y = 56; cancel.pressed.connect(_show_maze); col.add_child(cancel)

func _build_minigame(play: VBoxContainer) -> void:
	if terminal_kind == "energy":
		play.add_child(_label("Kömür hattını kapat. Doğru dönüşüm sırası:", 20, CREAM)); play.add_child(_label("GÜNEŞ  →  RÜZGÂR  →  BATARYA", 24, MINT))
		for item in ["GÜNEŞ", "RÜZGÂR", "BATARYA"]:
			var b := _button(item, PANEL_2, CREAM); b.custom_minimum_size.y = 58; b.pressed.connect(func(): _energy_pick(item, play)); play.add_child(b)
	elif terminal_kind == "waste":
		play.add_child(_label("Akıştaki parçayı doğru döngüye yönlendir:", 20, CREAM)); var item_label := _label("", 28, YELLOW); item_label.name = "Item"; play.add_child(item_label); _update_waste_label(item_label)
		for bin in ["GERİ DÖNÜŞÜM", "ONARIM", "KOMPOST"]:
			var b := _button(bin, PANEL_2, CREAM); b.custom_minimum_size.y = 58; b.pressed.connect(func(): _waste_pick(bin, item_label)); play.add_child(b)
	else:
		play.add_child(_label("Sahte raporun kilidi: doğruları sırayla seç.", 20, CREAM)); play.add_child(_label("İpucu: veri → gerçeklik → zirve", 18, MINT))
		for item in ["COP31", "CO₂", "TRUE"]:
			var b := _button(item, PANEL_2, CREAM); b.custom_minimum_size.y = 62; b.pressed.connect(func(): _server_pick(item, play)); play.add_child(b)

func _energy_pick(item: String, play: VBoxContainer) -> void:
	var expected: String = str(["GÜNEŞ", "RÜZGÂR", "BATARYA"][mini_step])
	if item != expected: _toast("Kömür rölesi geri tepiyor. Sıralamayı takip et."); return
	mini_step += 1
	if mini_step >= 3: _complete_terminal("Enerji hattı yenilendi. Duman dağılıyor.")
	else: _toast("Bağlantı %d/3 tamam." % mini_step)

func _update_waste_label(label: Label) -> void:
	label.text = ["PLASTİK KASA", "KIRIK SENSOR", "YEMEK ARTIKLARI", "ALÜMİNYUM LEVHA", "ESKİ FAN"][waste_item]

func _waste_pick(bin: String, label: Label) -> void:
	var correct: Array = [["PLASTİK KASA", "GERİ DÖNÜŞÜM"], ["KIRIK SENSOR", "ONARIM"], ["YEMEK ARTIKLARI", "KOMPOST"], ["ALÜMİNYUM LEVHA", "GERİ DÖNÜŞÜM"], ["ESKİ FAN", "ONARIM"]][waste_item]
	if bin != correct[1]: _toast("Akış tıkandı. Bu parça için başka bir döngü dene."); return
	waste_item += 1
	if waste_item >= 5: _complete_terminal("Atık hattı kapandı. Döngüsel üretim devrede.")
	else: _update_waste_label(label)

func _server_pick(item: String, play: VBoxContainer) -> void:
	var expected: String = str(server_target[server_order.size()])
	if item != expected: _toast("Şifre yanlış. Kanıt sırasını koru."); server_order.clear(); return
	server_order.append(item)
	if server_order.size() >= 3: _complete_terminal("Gerçek emisyon verisi COP31'e sızdırıldı.")
	else: _toast("Kanıt %d/3 doğrulandı." % server_order.size())

func _complete_terminal(message: String) -> void:
	hacked[terminal_kind] = true; temperature = maxf(0.0, temperature - 14.0); _toast(message); await get_tree().create_timer(0.45).timeout; _show_maze()

func _move_drone() -> void:
	var options: Array[Vector2i] = []
	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var p: Vector2i = drone + dir
		if p.y >= 0 and p.y < MAZE.size() and p.x >= 0 and p.x < MAZE[p.y].length() and MAZE[p.y][p.x] != "#": options.append(p)
	if not options.is_empty(): drone = options[randi() % options.size()]

func _update_hud() -> void:
	if phase != "maze" or not is_instance_valid(root_ui): return
	var bar := root_ui.find_child("TempBar", true, false) as ProgressBar; if bar: bar.value = temperature
	var status := root_ui.find_child("Status", true, false) as Label; if status: status.text = "İlerleme: %d / 3 terminal\nSıcaklık: %.0f%%\nDron: kırmızı gözlemci" % [int(hacked.values().count(true)), temperature]
	var hack := root_ui.find_child("HackButton", true, false) as Button; if hack: hack.disabled = _nearby_terminal() == ""
	var exit := root_ui.find_child("ExitLabel", true, false) as Label; if exit: exit.text = "ÇIKIŞ: %s" % ("AÇIK" if _all_hacked() else "KİLİTLİ")
	for key in hacked.keys():
		var label := root_ui.find_child(key, true, false) as Label; if label: label.text = ("✓ " if hacked[key] else "○ ") + _terminal_name(key); label.add_theme_color_override("font_color", MINT if hacked[key] else CREAM)

func _nearby_terminal() -> String:
	for pos in [player, player + Vector2i.UP, player + Vector2i.DOWN, player + Vector2i.LEFT, player + Vector2i.RIGHT]:
		if pos.y >= 0 and pos.y < MAZE.size() and pos.x >= 0 and pos.x < MAZE[pos.y].length():
			var ch: String = str(MAZE[pos.y][pos.x]); var kind := _kind_for_char(ch)
			if kind != "" and not hacked[kind]: return kind
	return ""

func _all_hacked() -> bool: return hacked.values().all(func(v): return v)
func _kind_for_char(ch: String) -> String: return {"E":"energy", "P":"waste", "M":"server"}.get(ch, "")
func _terminal_name(key: String) -> String: return {"energy":"ENERJİ DÖNÜŞÜMÜ", "waste":"SIFIR ATIK BANDI", "server":"ANA SUNUCU / İFŞA"}.get(key, key)
func _terminal_title() -> String: return {"energy":"ENERJİ TERMİNALİ", "waste":"ÜRETİM BANDI", "server":"ANA SUNUCU"}.get(terminal_kind, "TERMINAL")
func _terminal_body() -> String: return {"energy":"Gizli kömür hattını kes ve temiz şebekeyi yeniden sırala.", "waste":"Al-kullan-at hattını geri dönüşüm ve onarıma yönlendir.", "server":"Sahte Sıfır Karbon Ayak İzi raporunu kanıt zinciriyle kır."}.get(terminal_kind, "")
func _terminal_color(ch: String) -> Color: return {"E":YELLOW, "P":TURQUOISE, "M":MINT}.get(ch, MINT)

func _show_end(won: bool) -> void:
	phase = "end"; _clear(); var center := CenterContainer.new(); center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); root_ui.add_child(center); var box := _panel(); box.custom_minimum_size = Vector2(670, 400); center.add_child(box); var col := VBoxContainer.new(); col.add_theme_constant_override("separation", 16); box.add_child(col)
	col.add_child(_label("GERÇEKLİK RAPORU", 16, YELLOW)); col.add_child(_label("İFŞA BAŞARILI" if won else "DEVRİLME NOKTASI AŞILDI", 42, MINT if won else RED)); var body := _label("COP31 komitesi veriyi aldı. Gri koridorlar yeşile döndü; dönüşüm artık mümkün." if won else "Dronlar seni durdurdu ve şirketin gizli üretimi kritik eşiği geçti. Bir sonraki sızıntıda daha hızlı ol.", 20, CREAM); body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; col.add_child(body); col.add_child(_label("Hacklenen terminal: %d/3    Son sıcaklık: %.0f%%" % [int(hacked.values().count(true)), temperature], 20, YELLOW)); var again := _button("YENİ OPERASYON  →", MINT, BG); again.custom_minimum_size.y = 66; again.pressed.connect(_start_game); col.add_child(again)

func _panel() -> PanelContainer: var p := PanelContainer.new(); p.add_theme_stylebox_override("panel", _style(PANEL, 18)); p.add_theme_constant_override("margin_left", 26); p.add_theme_constant_override("margin_right", 26); p.add_theme_constant_override("margin_top", 22); p.add_theme_constant_override("margin_bottom", 22); return p
func _button(text: String, color: Color, ink: Color) -> Button: var b := Button.new(); b.text = text; b.add_theme_font_size_override("font_size", 18); b.add_theme_color_override("font_color", ink); b.add_theme_stylebox_override("normal", _style(color, 12)); b.add_theme_stylebox_override("hover", _style(MINT, 12)); b.add_theme_stylebox_override("pressed", _style(TURQUOISE, 12)); return b
func _label(text: String, size: int, color: Color) -> Label: var l := Label.new(); l.text = text; l.add_theme_font_size_override("font_size", size); l.add_theme_color_override("font_color", color); return l
func _style(color: Color, radius: int) -> StyleBoxFlat: var s := StyleBoxFlat.new(); s.bg_color = color; s.corner_radius_top_left = radius; s.corner_radius_top_right = radius; s.corner_radius_bottom_left = radius; s.corner_radius_bottom_right = radius; s.content_margin_left = 16; s.content_margin_right = 16; s.content_margin_top = 8; s.content_margin_bottom = 8; return s
func _toast(message: String) -> void: if toast: toast.text = message
