extends ColorRect

@export var fade_duration: float = 0.3
@export var transition_type: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT

var transitioning: bool = false

func _ready() -> void:
	modulate.a = 0.0
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_out(custom_duration: float = -1.0) -> void:
	if transitioning:
		return
	
	transitioning = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	var duration := custom_duration if custom_duration >= 0.0 else fade_duration
	
	var tween := create_tween()
	tween.set_trans(transition_type).set_ease(ease_type)
	tween.tween_property(self, "modulate:a", 1.0, duration)
	
	await tween.finished
	transitioning = false

func fade_in(custom_duration: float = -1.0) -> void:
	if transitioning:
		return
	
	transitioning = true
	visible = true
	
	var duration := custom_duration if custom_duration >= 0.0 else fade_duration
	
	var tween := create_tween()
	tween.set_trans(transition_type).set_ease(ease_type)
	tween.tween_property(self, "modulate:a", 0.0, duration)
	
	await tween.finished
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	transitioning = false
