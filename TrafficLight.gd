extends Node2D

enum LightState { GREEN, YELLOW, RED, RED_YELLOW }

@export var vertical_green_duration: float = 24.0
@export var vertical_yellow_duration: float = 4.0
@export var vertical_red_duration: float = 37.0

@export var horizontal_red_duration: float = 30.0
@export var horizontal_red_yellow_duration: float = 3.0
@export var horizontal_green_duration: float = 27.0
@export var horizontal_yellow_duration: float = 3.0

@export var road_type: String = "vertical"

var vertical_state: int = LightState.GREEN
var horizontal_state: int = LightState.RED

var timer: Timer

@onready var red_rect: ColorRect = $RedRect
@onready var yellow_rect: ColorRect = $YellowRect
@onready var green_rect: ColorRect = $GreenRect

signal vertical_light_changed(state)
signal horizontal_light_changed(state)

func _ready():
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	_enter_vertical_state(LightState.GREEN)
	_update_display()

func _enter_vertical_state(new_state: int) -> void:
	vertical_state = new_state
	emit_signal("vertical_light_changed", vertical_state)

	horizontal_state = _get_horizontal_state_from_vertical()
	emit_signal("horizontal_light_changed", horizontal_state)

	match vertical_state:
		LightState.GREEN:
			timer.wait_time = vertical_green_duration
		LightState.YELLOW:
			timer.wait_time = vertical_yellow_duration
		LightState.RED:
			timer.wait_time = vertical_red_duration

	_update_display()
	timer.start()

func _on_timer_timeout() -> void:
	match vertical_state:
		LightState.GREEN:
			_enter_vertical_state(LightState.YELLOW)
		LightState.YELLOW:
			_enter_vertical_state(LightState.RED)
		LightState.RED:
			_enter_vertical_state(LightState.GREEN)

func _update_display():
	red_rect.visible = false
	yellow_rect.visible = false
	green_rect.visible = false

	var effective_state = vertical_state if road_type == "vertical" else horizontal_state

	match effective_state:
		LightState.GREEN:
			green_rect.visible = true
		LightState.YELLOW:
			yellow_rect.visible = true
		LightState.RED, LightState.RED_YELLOW:
			red_rect.visible = true
			if effective_state == LightState.RED_YELLOW:
				yellow_rect.visible = true

func _get_horizontal_state_from_vertical() -> int:
	match vertical_state:
		LightState.GREEN:
			return LightState.RED
		LightState.YELLOW:
			return LightState.RED
		LightState.RED:
			if timer.get_time_left() <= horizontal_red_yellow_duration + horizontal_green_duration:
				return LightState.RED_YELLOW if timer.get_time_left() > horizontal_green_duration else LightState.GREEN
			return LightState.RED
	return 999
