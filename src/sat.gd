class_name SATScene
extends CollisionDetection

@onready var polygon_a: SATPolygon = $PolygonA
@onready var polygon_b: SATPolygon = $PolygonB
@onready var polygon_c: SATPolygon = $PolygonC

func sat_overlap(a: SATPolygon, b: SATPolygon) -> bool:
	var axes = a.get_axes() + b.get_axes()
	var corners_a = a.get_corner_positions()
	var corners_b = b.get_corner_positions()
	
	for axis in axes:
		var min_a = INF; var max_a = -INF
		var min_b = INF; var max_b = -INF
		
		for c in corners_a:
			var p = c.dot(axis)
			min_a = min(min_a, p); max_a = max(max_a, p)
		for c in corners_b:
			var p = c.dot(axis)
			min_b = min(min_b, p); max_b = max(max_b, p)
		
		if max_a < min_b or max_b < min_a:
			return false
	
	return true

func _handle_input(delta: float) -> void:
	# Polygon A
	if Input.is_key_pressed(KEY_LEFT): polygon_a.position.x -= speed * delta
	if Input.is_key_pressed(KEY_RIGHT): polygon_a.position.x += speed * delta
	if Input.is_key_pressed(KEY_UP): polygon_a.position.y -= speed * delta
	if Input.is_key_pressed(KEY_DOWN): polygon_a.position.y += speed * delta
	if Input.is_key_pressed(KEY_R): polygon_a.rotation -= rot_speed * delta
	if Input.is_key_pressed(KEY_F): polygon_a.rotation += rot_speed * delta
	
	# Polygon B
	if Input.is_key_pressed(KEY_A): polygon_b.position.x -= speed * delta
	if Input.is_key_pressed(KEY_D): polygon_b.position.x += speed * delta
	if Input.is_key_pressed(KEY_W): polygon_b.position.y -= speed * delta
	if Input.is_key_pressed(KEY_S): polygon_b.position.y += speed * delta
	if Input.is_key_pressed(KEY_Q): polygon_b.rotation -= rot_speed * delta
	if Input.is_key_pressed(KEY_E): polygon_b.rotation += rot_speed * delta

func _update_collision_state() -> void:
	polygon_a.overlap = false
	polygon_b.overlap = false
	polygon_c.overlap = false
	
	if sat_overlap(polygon_a, polygon_b):
		polygon_a.overlap = true
		polygon_b.overlap = true
	if sat_overlap(polygon_b, polygon_c):
		polygon_b.overlap = true
		polygon_c.overlap = true
	if sat_overlap(polygon_c, polygon_a):
		polygon_c.overlap = true
		polygon_a.overlap = true

func _queue_redraws() -> void:
	polygon_a.queue_redraw()
	polygon_b.queue_redraw()
	polygon_c.queue_redraw()

func _update_label() -> void:
	label.text = "F1 AABB   F2 OBB   [F3 SAT]\n   Polygon A : move ARROWS, rotate R/T\n   Polygon B : move WASD, rotate Q/E\nColliding: %s" % (polygon_a.overlap or polygon_b.overlap)

func _draw() -> void:
	if (sat_overlap(polygon_a, polygon_b)):
		_draw_sat(polygon_a, polygon_b, polygon_a.shape_color, polygon_b.shape_color)
	if (sat_overlap(polygon_b, polygon_c)):
		_draw_sat(polygon_b, polygon_c, polygon_b.shape_color, polygon_c.shape_color)
	if (sat_overlap(polygon_c, polygon_a)):
		_draw_sat(polygon_c, polygon_a, polygon_c.shape_color, polygon_a.shape_color)

func _draw_sat(a: SATPolygon, b: SATPolygon, col_a: Color, col_b: Color) -> void:
	var axes = a.get_axes()
	if axes.is_empty():
		return
	
	var axis = axes[0]
	var perp = axis.orthogonal()
	
	var corners_a = a.get_corner_positions()
	var corners_b = b.get_corner_positions()
	
	# Project onto axis
	var min_a = INF; var max_a = -INF
	var min_b = INF; var max_b = -INF
	for c in corners_a:
		var p = c.dot(axis)
		min_a = min(min_a, p); max_a = max(max_a, p)
	for c in corners_b:
		var p = c.dot(axis)
		min_b = min(min_b, p); max_b = max(max_b, p)
	
	var axis_origin = (a.global_position + b.global_position) * 0.5
	var offset = perp * 120.0
	
	var vp = get_viewport_rect().size
	var half_len = vp.length() * 0.6
	
	var line_start = axis_origin + axis * -half_len + offset
	var line_end   = axis_origin + axis *  half_len + offset
	draw_line(line_start, line_end, Color.WHITE, 1.0)
	
	# Draw projection intervals on the axis line
	var pa_min = axis_origin + axis * min_a + offset
	var pa_max = axis_origin + axis * max_a + offset
	var pb_min = axis_origin + axis * min_b + offset
	var pb_max = axis_origin + axis * max_b + offset
	draw_line(pa_min, pa_max, col_a, 4.0)
	draw_line(pb_min, pb_max, col_b, 4.0)
	
	# Draw dashed lines from each corner to the axis
	for c in corners_a:
		var p = c.dot(axis)
		var foot = axis_origin + axis * p + offset
		draw_dashed_line(c, foot, col_a, 1.0)
	for c in corners_b:
		var p = c.dot(axis)
		var foot = axis_origin + axis * p + offset
		draw_dashed_line(c, foot, col_b, 1.0)
	
	# Draw overlap segment in red
	var overlap_min = max(min_a, min_b)
	var overlap_max = min(max_a, max_b)
	if overlap_min < overlap_max:
		var ov_start = axis_origin + axis * overlap_min + offset
		var ov_end   = axis_origin + axis * overlap_max + offset
		draw_line(ov_start, ov_end, Color.RED, 5.0)
