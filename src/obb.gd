class_name OBBScene
extends CollisionDetection

@onready var quad_a: OBBQuad = $QuadA
@onready var quad_b: OBBQuad = $QuadB

# draw settings
const AXIS_ORIGIN_OFFSET: Vector2 = Vector2(240, 120)
const AXIS_SPACING: float = 85.0
const AXIS_WIDTH: float = 200.0
const PROJ_THICKNESS: float = 5.0
const TICK_SIZE: float = 4.0

func project_corners(corners: Array, axis: Vector2) -> Vector2:
	var min_p := INF
	var max_p := -INF
	
	for c in corners:
		var p : float = c.dot(axis)
		min_p = min(min_p, p)
		max_p = max(max_p, p)
		
	return Vector2(min_p, max_p)
	
func obb_overlap(a: OBBQuad, b: OBBQuad) -> bool:
	var corners_a := a.get_corner_positions()
	var corners_b := b.get_corner_positions()
	var axes_a := a.get_axes()
	var axes_b := b.get_axes()
	
	for axis in [axes_a[0], axes_b[0], axes_a[1], axes_b[1]]:
		var proj_a := project_corners(corners_a, axis)
		var proj_b := project_corners(corners_b, axis)
		if proj_a.y < proj_b.x or proj_b.y < proj_a.x:
			return false
			
	return true

func _handle_input(delta: float) -> void:
	# Quad A
	if Input.is_key_pressed(KEY_LEFT): quad_a.position.x -= speed * delta
	if Input.is_key_pressed(KEY_RIGHT): quad_a.position.x += speed * delta
	if Input.is_key_pressed(KEY_UP): quad_a.position.y -= speed * delta
	if Input.is_key_pressed(KEY_DOWN): quad_a.position.y += speed * delta
	if Input.is_key_pressed(KEY_R): quad_a.rotation -= rot_speed * delta
	if Input.is_key_pressed(KEY_F): quad_a.rotation += rot_speed * delta
	
	# Quad B
	if Input.is_key_pressed(KEY_A): quad_b.position.x -= speed * delta
	if Input.is_key_pressed(KEY_D): quad_b.position.x += speed * delta
	if Input.is_key_pressed(KEY_W): quad_b.position.y -= speed * delta
	if Input.is_key_pressed(KEY_S): quad_b.position.y += speed * delta
	if Input.is_key_pressed(KEY_Q): quad_b.rotation -= rot_speed * delta
	if Input.is_key_pressed(KEY_E): quad_b.rotation += rot_speed * delta

func _update_collision_state() -> void:
	if obb_overlap(quad_a, quad_b):
		quad_a.overlap = true
		quad_b.overlap = true
	else:
		quad_a.overlap = false
		quad_b.overlap = false

func _queue_redraws() -> void:
	quad_a.queue_redraw()
	quad_b.queue_redraw()

func _update_label() -> void:
	label.text = "F1 AABB   [F2 OBB]   F3 SAT\n   BoxA : move ARROWS, rotate R/T\n   BoxB : move WASD, rotate Q/E\nColliding: %s" % quad_a.overlap

func _draw() -> void:
	var axes_a = quad_a.get_axes()
	var axes_b = quad_b.get_axes()
	var corners_a = quad_a.get_corner_positions()
	var corners_b = quad_b.get_corner_positions()
	var axis_list = [
		{"name": "A.x", "axis": axes_a[0]},
		{"name": "A.y", "axis": axes_a[1]},
		{"name": "B.x", "axis": axes_b[0]},
		{"name": "B.y", "axis": axes_b[1]}
	]
	var axis_color = Color.WHITE_SMOKE
	var overlap_color = Color.RED
	var col_a = quad_a.shape_color
	var col_b = quad_b.shape_color
	var vp = get_viewport_rect().size

	for i in range(axis_list.size()):
		var axis_info = axis_list[i]
		var axis_dir = axis_info["axis"].normalized()
		var row_origin = Vector2(vp.x - AXIS_ORIGIN_OFFSET.x, AXIS_ORIGIN_OFFSET.y + AXIS_SPACING * i)
		var axis_start = row_origin
		var axis_end = row_origin + Vector2(AXIS_WIDTH, 0)
		var proj_a = project_corners(corners_a, axis_dir)
		var proj_b = project_corners(corners_b, axis_dir)
		var total_min = min(proj_a.x, proj_b.x)
		var total_max = max(proj_a.y, proj_b.y)
		var r = max(total_max - total_min, 1.0)
		var s = AXIS_WIDTH / r

		draw_line(axis_start, axis_end, axis_color, 2.0)
		draw_string(ThemeDB.fallback_font, axis_start + Vector2(-70, -12), axis_info["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, axis_color)

		var a_start = axis_start + Vector2((proj_a.x - total_min) * s, -PROJ_THICKNESS * 0.8)
		var a_end   = axis_start + Vector2((proj_a.y - total_min) * s, -PROJ_THICKNESS * 0.8)
		var b_start = axis_start + Vector2((proj_b.x - total_min) * s,  PROJ_THICKNESS * 0.8)
		var b_end   = axis_start + Vector2((proj_b.y - total_min) * s,  PROJ_THICKNESS * 0.8)

		draw_line(a_start, a_end, col_a, PROJ_THICKNESS)
		_draw_horizontal_ticks(a_start, col_a)
		_draw_horizontal_ticks(a_end,   col_a)
		draw_line(b_start, b_end, col_b, PROJ_THICKNESS)
		_draw_horizontal_ticks(b_start, col_b)
		_draw_horizontal_ticks(b_end,   col_b)

		if proj_a.y > proj_b.x and proj_b.y > proj_a.x:
			var overlap_start = axis_start + Vector2((max(proj_a.x, proj_b.x) - total_min) * s, 0)
			var overlap_end   = axis_start + Vector2((min(proj_a.y, proj_b.y) - total_min) * s, 0)
			draw_line(overlap_start, overlap_end, overlap_color, PROJ_THICKNESS * 0.75)

func _draw_horizontal_ticks(pos: Vector2, color: Color) -> void:
	draw_line(pos + Vector2(0, -TICK_SIZE), pos + Vector2(0, TICK_SIZE), color, 1.5)
	draw_line(pos + Vector2(-TICK_SIZE * 0.35, -TICK_SIZE * 0.35), pos + Vector2(TICK_SIZE * 0.35, TICK_SIZE * 0.35), color, 1.5)
