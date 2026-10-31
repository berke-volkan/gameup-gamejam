extends Control

var show_menu_scene := false
var t := 0.0

func _ready() -> void:
    queue_redraw()

func _process(delta: float) -> void:
    t += delta
    queue_redraw()

func _draw() -> void:
    var w := size.x; var h := size.y
    var pad := 22.0
    draw_rect(Rect2(pad, pad, w - pad*2, h - pad*2), Color("#e9e1ca"), true)
    draw_rect(Rect2(pad, pad, w - pad*2, 30), Color("#d7c9a8"), true)
    draw_string(ThemeDB.fallback_font, Vector2(pad + 16, pad + 21), "ECOCORP LAB  /  AKDENİZ İKLİM MERKEZİ", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#466153"))
    draw_rect(Rect2(pad, h*.55, w-pad*2, h*.45-pad), Color("#c6a77b"), true)
    draw_rect(Rect2(pad+25, pad+26, w*.48, h*.48), Color("#85b8b5"), true)
    draw_line(Vector2(pad+25+w*.24,pad+26), Vector2(pad+25+w*.24,h*.55), Color("#dff0dc"), 4)
    draw_line(Vector2(pad+25,pad+26+h*.24), Vector2(pad+25+w*.48,h*.26), Color("#dff0dc"), 4)
    draw_circle(Vector2(w-78, 66), 26, Color("#f2c94c"))
    # ofiste çalışan iki küçük karakter
    var bob := sin(t * 2.0) * 3.0
    draw_circle(Vector2(w*.28, h*.67 + bob), 15, Color("#d97d68")); draw_rect(Rect2(w*.25, h*.69+bob, 30, 42), Color("#356f86"), true)
    draw_circle(Vector2(w*.37, h*.69 - bob), 14, Color("#e0a56c")); draw_rect(Rect2(w*.345, h*.71-bob, 30, 38), Color("#4c946b"), true)
    draw_line(Vector2(w*.285,h*.74+bob), Vector2(w*.265,h*.84+bob), Color("#173d31"), 4); draw_line(Vector2(w*.395,h*.75-bob), Vector2(w*.415,h*.84-bob), Color("#173d31"), 4)
    draw_rect(Rect2(w*.57, h*.64, w*.27, 18), Color("#8d6649"), true)
    draw_rect(Rect2(w*.60, h*.66, 10, 62), Color("#704d39"), true); draw_rect(Rect2(w*.79, h*.66, 10, 62), Color("#704d39"), true)
    draw_circle(Vector2(w*.86, h*.61), 26, Color("#4c946b")); draw_rect(Rect2(w*.855,h*.62,10,76),Color("#795a3a"),true)
    draw_rect(Rect2(w*.43,h*.42,40,10),Color("#556b61"),true); draw_circle(Vector2(w*.45,h*.38),12,Color("#f2c94c"))
    if GameState.upgrades.get("solar", false):
        for i in 5:
            draw_rect(Rect2(w*.55+i*34, h*.37, 28, 16), Color("#356f86"), true)
            draw_line(Vector2(w*.55+i*34+14,h*.37), Vector2(w*.55+i*34+14,h*.53), Color("#dff0dc"), 2)
        # çatıdaki küçük rüzgâr türbini
        draw_line(Vector2(w*.47, h*.23), Vector2(w*.47, h*.4), Color("#466153"), 3)
        draw_circle(Vector2(w*.47, h*.23), 5, Color("#f2c94c"))
        for angle in [0.0, 2.1, 4.2]: draw_line(Vector2(w*.47,h*.23), Vector2(w*.47,h*.23)+Vector2.from_angle(angle+t*.35)*22, Color("#f2ead8"), 4)
    if GameState.upgrades.get("garden", false):
        for i in 5:
            draw_circle(Vector2(pad+45+i*31, h*.79), 12, Color("#4c946b")); draw_line(Vector2(pad+45+i*31,h*.79), Vector2(pad+45+i*31,h*.9), Color("#795a3a"), 4)
        # kompost kutusu ve polinatör çiçekleri
        draw_rect(Rect2(w*.2, h*.72, 28, 34), Color("#8d6649"), true)
        for i in 3: draw_circle(Vector2(w*.2 + i*13, h*.7), 5, Color("#d97d68"))
    if GameState.upgrades.get("glass", false):
        draw_rect(Rect2(w*.72, pad+45, 70, 100), Color("#a6d8df"), true)
        draw_line(Vector2(w*.755,pad+45), Vector2(w*.755,pad+145), Color("#e9e1ca"), 3)
    if GameState.upgrades.get("rainwater", false):
        draw_line(Vector2(w*.91, pad+38), Vector2(w*.91, h*.55), Color("#466153"), 5)
        draw_rect(Rect2(w*.86, h*.5, 72, 62), Color("#5d9ea0"), true)
        draw_arc(Vector2(w*.895, h*.5), 28, PI, TAU, 16, Color("#dff0dc"), 3)
        draw_string(ThemeDB.fallback_font, Vector2(w*.86, h*.61), "gri su", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#173d31"))
    if GameState.upgrades.get("mobility", false):
        draw_circle(Vector2(w*.54, h*.87), 12, Color("#173d31"), false, 4); draw_circle(Vector2(w*.61, h*.87), 12, Color("#173d31"), false, 4)
        draw_line(Vector2(w*.54,h*.87), Vector2(w*.58,h*.8), Color("#173d31"), 4); draw_line(Vector2(w*.58,h*.8), Vector2(w*.61,h*.87), Color("#173d31"), 4)
        draw_rect(Rect2(w*.64, h*.77, 14, 45), Color("#4c946b"), true); draw_circle(Vector2(w*.647,h*.75), 9, Color("#f2c94c"))
    if GameState.upgrades.get("sorting", false):
        for i in 3:
            draw_rect(Rect2(w*.09 + i*22, h*.67, 18, 26), [Color("#82b96a"), Color("#6d92c9"), Color("#f2c94c")][i], true)
    # yükseltme yokken de hedef alanlarını anlaşılır tutan dekoratif iç mekân detayları
    draw_circle(Vector2(w*.13, h*.6), 18, Color("#4c946b")); draw_rect(Rect2(w*.125,h*.61,10,66), Color("#795a3a"), true)
    draw_string(ThemeDB.fallback_font, Vector2(w*.08, h*.91), "ANTALYA / 36°N", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#466153"))
    if show_menu_scene:
        draw_string(ThemeDB.fallback_font, Vector2(30, h-28), "MADE FOR A CLEANER ANTALYA", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#173d31"))
