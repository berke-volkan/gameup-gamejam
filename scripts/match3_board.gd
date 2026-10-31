extends Control

signal reward(points: int, matches: int)
var grid: Array = []
var selected := Vector2i(-1, -1)
var moves := 18
var running := false
const N := 6
const COLORS := [Color("#f2c94c"), Color("#65b6a1"), Color("#82b96a"), Color("#6d92c9"), Color("#d97d68")]

func _ready() -> void:
    custom_minimum_size = Vector2(380, 380)
    if GameState.mini_grid.size() == N:
        grid = GameState.mini_grid.duplicate(true)
        moves = GameState.mini_moves
        running = moves > 0
    else:
        reset_game()
    mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func reset_game() -> void:
    moves = 18; selected = Vector2i(-1, -1); running = true; grid.clear()
    for y in N:
        var row := []
        for x in N: row.append((x * 2 + y * 3 + 1) % COLORS.size())
        grid.append(row)
    # garantili ilk hamle: iki yatay çiftin ortasında değişim yapılabilir
    grid[0][0] = 0; grid[0][1] = 0; grid[0][2] = 1; grid[1][2] = 0
    GameState.mini_grid = grid.duplicate(true); GameState.mini_moves = moves; GameState.save_progress()
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    if not running: return
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT: _pick(event.position)
    elif event is InputEventScreenTouch and event.pressed: _pick(event.position)

func _pick(pos: Vector2) -> void:
    var cell_size := size.x / N
    var p := Vector2i(floor(pos.x / cell_size), floor(pos.y / cell_size))
    if p.x < 0 or p.y < 0 or p.x >= N or p.y >= N: return
    if selected.x < 0: selected = p
    elif abs(selected.x - p.x) + abs(selected.y - p.y) == 1:
        _swap_and_resolve(selected, p); selected = Vector2i(-1, -1)
    else: selected = p
    queue_redraw()

func _swap_and_resolve(a: Vector2i, b: Vector2i) -> void:
    if moves <= 0: return
    var temp = grid[a.y][a.x]; grid[a.y][a.x] = grid[b.y][b.x]; grid[b.y][b.x] = temp
    var found := _find_matches()
    if found.is_empty():
        temp = grid[a.y][a.x]; grid[a.y][a.x] = grid[b.y][b.x]; grid[b.y][b.x] = temp
        GameState.toast_requested.emit("Bu takas eşleşme yaratmadı.")
        return
    moves -= 1
    GameState.mini_moves = moves
    var total := 0; var chains := 0
    while not found.is_empty():
        chains += 1; total += found.size() * 20
        for p in found: grid[p.y][p.x] = -1
        _collapse(); found = _find_matches()
    reward.emit(total, chains)
    GameState.mini_grid = grid.duplicate(true); GameState.save_progress()
    if moves <= 0: running = false; GameState.toast_requested.emit("Görev tamamlandı — yeniden oynayabilirsin!")
    queue_redraw()

func _find_matches() -> Array:
    var matches := {}
    for y in N:
        var run := 1
        for x in range(1, N + 1):
            if x < N and grid[y][x] == grid[y][x - 1] and grid[y][x] >= 0: run += 1
            else:
                if run >= 3: for k in run: matches[Vector2i(x - 1 - k, y)] = true
                run = 1
    for x in N:
        var run := 1
        for y in range(1, N + 1):
            if y < N and grid[y][x] == grid[y - 1][x] and grid[y][x] >= 0: run += 1
            else:
                if run >= 3: for k in run: matches[Vector2i(x, y - 1 - k)] = true
                run = 1
    return matches.keys()

func _collapse() -> void:
    for x in N:
        var values := []
        for y in N:
            if grid[y][x] >= 0: values.append(grid[y][x])
        while values.size() < N: values.push_front(randi_range(0, COLORS.size() - 1))
        for y in N: grid[y][x] = values[y]

func _draw() -> void:
    var cell_size := size.x / N
    draw_style_box(_panel(Color("#153e33"), 18), Rect2(Vector2.ZERO, size))
    for y in N:
        for x in N:
            var rect := Rect2(x * cell_size + 4, y * cell_size + 4, cell_size - 8, cell_size - 8)
            draw_style_box(_panel(Color("#255343"), 12), rect)
            var value: int = grid[y][x]
            if value >= 0:
                _draw_token(rect.get_center(), cell_size * .27, value)
            if selected == Vector2i(x, y): draw_style_box(_outline(Color("#f2c94c"), 12, 4), rect.grow(-2))

func _panel(color: Color, radius: int) -> StyleBoxFlat:
    var s := StyleBoxFlat.new(); s.bg_color = color; s.corner_radius_top_left = radius; s.corner_radius_top_right = radius; s.corner_radius_bottom_left = radius; s.corner_radius_bottom_right = radius; return s
func _outline(color: Color, radius: int, width: int) -> StyleBoxFlat:
    var s := _panel(Color(0,0,0,0), radius); s.border_color = color; s.set_border_width_all(width); return s

func _draw_token(center: Vector2, radius: float, value: int) -> void:
    var color: Color = COLORS[value]
    if value == 0: # güneş paneli
        var r := Rect2(center - Vector2(radius * .86, radius * .62), Vector2(radius * 1.72, radius * 1.24))
        draw_rect(r, color, true); draw_rect(r, Color("#356f86"), false, 3)
        for i in 1: draw_line(Vector2(r.position.x + r.size.x * i / 2.0, r.position.y), Vector2(r.position.x + r.size.x * i / 2.0, r.end.y), Color("#f2ead8"), 2)
        draw_line(Vector2(r.position.x, center.y), Vector2(r.end.x, center.y), Color("#f2ead8"), 2)
    elif value == 1: # su damlası
        var pts := PackedVector2Array([center + Vector2(0, -radius), center + Vector2(radius*.72, radius*.25), center + Vector2(.5*radius, radius*.7), center + Vector2(-.5*radius, radius*.7), center + Vector2(-radius*.72, radius*.25)])
        draw_colored_polygon(pts, color); draw_polyline(pts, Color("#dff0dc"), 3)
    elif value == 2: # fidan
        draw_line(center + Vector2(0, radius*.65), center + Vector2(0, -radius*.05), Color("#795a3a"), 5)
        draw_circle(center + Vector2(-radius*.32, -radius*.25), radius*.42, color); draw_circle(center + Vector2(radius*.32, -radius*.35), radius*.42, color)
    elif value == 3: # rüzgâr türbini
        draw_line(center + Vector2(0, radius*.05), center + Vector2(0, radius*.85), Color("#f2ead8"), 4)
        draw_circle(center, radius*.14, color)
        for angle in [0.0, 2.1, 4.2]:
            var tip := center + Vector2.from_angle(angle) * radius*.88
            draw_line(center, tip, color, 5)
    else: # geri dönüşüm döngüsü
        draw_arc(center, radius*.72, -2.9, -.9, 12, color, 6); draw_arc(center, radius*.72, -.8, 1.2, 12, color, 6); draw_arc(center, radius*.72, 1.3, 3.4, 12, color, 6)
        draw_circle(center, radius*.16, color)
