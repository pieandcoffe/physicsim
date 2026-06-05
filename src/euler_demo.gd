extends Node2D

@export var stiffness: float = 1.0
@export var dt: float = 0.5
@export var steps: int = 300

@onready var exact_curve: Line2D = $ExactCurve
@onready var numerical_curve: Line2D = $NumericalCurve
@onready var ball: Node2D = $Ball
@onready var info_label: Label = $InfoLabel

const SCALE_X := 50.0
const SCALE_Y := 150.0

func _ready() -> void:
	exact_curve.default_color		= Color.CORNFLOWER_BLUE
	exact_curve.width				= 2.0
	numerical_curve.default_color	= Color.ORANGE_RED
	numerical_curve.width			= 2.0
	plot()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			dt = clamp(dt + 0.005, 0.01, 4.0 / stiffness)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			dt = clamp(dt - 0.005, 0.01, 4.0 / stiffness)
		
		plot()

func plot() -> void:
	exact_curve.clear_points()
	numerical_curve.clear_points()
	
	var origin = get_viewport_rect().size / 2.0
	origin.y += 50.0
	origin.x = origin.x / 3
	
	for i in range(steps + 1):
		var t = i * dt
		var f = exp(-stiffness * t)
		exact_curve.add_point(origin + Vector2(i * SCALE_X, -f * SCALE_Y))
	
	var f_n: float = 1.0
	for i in range(steps + 1):
		var clamped_f = clamp(f_n, -3.0, 3.0)
		numerical_curve.add_point(origin + Vector2(i * SCALE_X, -clamped_f * SCALE_Y))
		f_n = (1.0 - stiffness * dt) * f_n
	
	update_label()

func update_label() -> void:
	var factor = 1.0 - stiffness * dt
	var case_str: String
	
	if dt < 1.0 / stiffness:
		case_str = "dt < 1/k	→	Case 1: converges, faster than exact"
	elif is_equal_approx(dt, 1.0 / stiffness):
		case_str = "dt = 1/k	→	Case 2: drops to 0 after 1 step"
	elif dt < 2.0 / stiffness:
		case_str = "1/k < dt < 2/k	→	Case 3: oscillates → 0"
	elif is_equal_approx(dt, 2.0 / stiffness):
		case_str = "dt = 2/k	→	Case 4: jumps ±1 forever"
	else:
		case_str = "dt > 2/k	→	Case 5: EXPLOSION → ±∞"
		
	info_label.text = (
		"k = %.2f\n" +
		"∆t = %.3f\n" +
		"(1 - k·∆t) = %.3f\n" +
		"1/k = %.3f   2/k = %.3f\n\n" +
		"%s"
		) % [stiffness, dt, factor, 1.0/stiffness, 2.0/stiffness, case_str]
	
