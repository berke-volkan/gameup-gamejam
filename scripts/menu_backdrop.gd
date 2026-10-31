extends Control

var t := 0.0

func _process(delta: float) -> void:
    t += delta
    queue_redraw()

func _draw() -> void:
    var w := size.x; var h := size.y
    draw_rect(Rect2(0, 0, w, h), Color("#0b3027"))
    for i in 12:
        draw_circle(Vector2(w * .78 + sin(i * 1.8) * 120, h * .2 + i * 42), 130 + i * 10, Color(0.2, .5, .37, .035))
    var sun := Vector2(w * .81 + sin(t * .35) * 6.0, h * .16 + cos(t * .35) * 4.0)
    draw_circle(sun, 88, Color(0.95, .79, .3, .08))
    draw_circle(sun, 72, Color("#f2c94c"))
    for i in 8:
        var ray_angle := i * TAU / 8.0 + t * .08
        draw_line(sun + Vector2.from_angle(ray_angle) * 88, sun + Vector2.from_angle(ray_angle) * 108, Color(1, .88, .45, .55), 3)
    draw_rect(Rect2(w * .51, h * .47, w * .49, h * .53), Color("#d9caa7"))
    draw_colored_polygon(PackedVector2Array([Vector2(w*.49,h*.47),Vector2(w*.75,h*.20),Vector2(w,h*.47)]), Color("#f2ead8"))
    for i in 6:
        draw_rect(Rect2(w*.57 + i*72, h*.32, 56, 110), Color("#79b5b0"))
        draw_line(Vector2(w*.598+i*72,h*.32), Vector2(w*.598+i*72,h*.43), Color("#cce3d5"), 3)
    for i in 5:
        draw_rect(Rect2(w*.6 + i*75, h*.26, 61, 10), Color("#356f86"))
    draw_rect(Rect2(w*.55, h*.69, 490, 18), Color("#8d6649"))
    draw_rect(Rect2(w*.58, h*.71, 16, 85), Color("#704d39")); draw_rect(Rect2(w*.88, h*.71, 16, 85), Color("#704d39"))
    for i in 5:
        var sway := sin(t * 1.1 + i) * 4.0
        draw_circle(Vector2(w*.57+i*84+sway, h*.82), 27, Color("#4c946b")); draw_rect(Rect2(w*.565+i*84,h*.81,10,55),Color("#795a3a"))
    # küçük hareketli enerji parçacıkları: sahnenin canlı olduğunu hissettirir
    for i in 10:
        var p := Vector2(w*.54 + fmod(i*93.0 + t*24.0, w*.43), h*.55 + sin(i*2.1+t)*70.0)
        draw_circle(p, 3.0 + (i%3), Color(1, .85, .35, .5))
