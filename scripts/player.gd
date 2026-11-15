extends CharacterBody2D

#region Movement
@export var max_speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

@export var jump_force: float = -500.0
@export var jump_cut_multiplier: float = 0.55
@export var stomp_force: float = -1050.0

@export var max_upward_speed: float = -1200.0
@export var max_fall_speed: float = 1000.0

var input_direction: float = 0.0

@onready var coyote_timer: Timer = $coyote_timer
@onready var jump_buffer_timer: Timer = $jump_buffer_timer

var stomped_this_frame: bool = false

@export var fast_fall_initial_boost: float = 220.0
@export var fast_fall_acceleration: float = 750.0
@export var upward_brake_multiplier: float = 0.65
@export var max_fast_fall_speed: float = 1250.0
#endregion

#region Screen Fade
@export var fade_duration: float = 0.3
@export var transition_type: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT

@onready var screen_fade: ColorRect = $camera_2d/canvas_layer/screen_fade

var transitioning: bool = false
#endregion

@export var attack_damage = 1

func _ready() -> void:
	screen_fade.modulate.a = 0.0
	screen_fade.visible = false
	screen_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _physics_process(delta: float) -> void:
	var was_on_floor = is_on_floor()
	var current_max_fall := max_fall_speed
	
	if not is_on_floor():
		var current_gravity: float = Global.gravity
		
		if Input.is_action_pressed("move_down"):
			current_max_fall = max_fast_fall_speed
			
			if velocity.y < 0.0:
				current_gravity += fast_fall_acceleration * upward_brake_multiplier
			else:
				current_gravity += fast_fall_acceleration
		
		velocity.y += current_gravity * delta
	
	if input_direction != 0:
		velocity.x = move_toward(velocity.x, input_direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	velocity.y = clamp(velocity.y, max_upward_speed, current_max_fall)
	
	move_and_slide()
	
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_timer.start()
	
	if not jump_buffer_timer.is_stopped() and (is_on_floor() or not coyote_timer.is_stopped()):
		velocity.y = jump_force
		jump_buffer_timer.stop()
		coyote_timer.stop()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_buffer_timer.start()
	
	if event.is_action_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier
	
	if event.is_action("move_left") or event.is_action("move_right"):
		input_direction = Input.get_axis("move_left", "move_right")
	
	if event.is_action_pressed("move_down") and not is_on_floor():
		if velocity.y < 0.0:
			velocity.y += fast_fall_initial_boost * upward_brake_multiplier
		else:
			velocity.y += fast_fall_initial_boost
	
	if event.is_action_pressed("reset"):
		reset_level()
	
	if event.is_action_pressed("reset_full_level"):
		reset_full_level()
#endregion

#region Taking Damage
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if stomped_this_frame:
		return
	
	var enemy = area.get_parent()
	var stomping = velocity.y > 0 and global_position.y < enemy.global_position.y
	
	if stomping and enemy.has_method("take_damage"):
		return
	
	reset_level()
#endregion

func reset_level() -> void:
	if transitioning:
		return
		
	if Global.amount_of_checkpoints > 0:
		await fade_out()
		global_position = Global.current_checkpoint_position
		velocity = Vector2.ZERO
		get_tree().call_group("enemies", "respawn")
		await fade_in()

func reset_full_level() -> void:
	if transitioning:
		return
		
	if Global.amount_of_checkpoints > 0:
		await fade_out()
		global_position = Global.first_checkpoint_position
		velocity = Vector2.ZERO
		get_tree().call_group("enemies", "respawn")
		await fade_in()

#region Screen Fade Functions
func fade_out(custom_duration: float = -1.0) -> void:
	if transitioning:
		return
	
	transitioning = true
	screen_fade.visible = true
	screen_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var duration := custom_duration if custom_duration >= 0.0 else fade_duration
	
	var tween := create_tween()
	tween.set_trans(transition_type).set_ease(ease_type)
	tween.tween_property(screen_fade, "modulate:a", 1.0, duration)
	
	await tween.finished
	transitioning = false

func fade_in(custom_duration: float = -1.0) -> void:
	if transitioning:
		return
	
	transitioning = true
	screen_fade.visible = true
	
	var duration := custom_duration if custom_duration >= 0.0 else fade_duration
	
	var tween := create_tween()
	tween.set_trans(transition_type).set_ease(ease_type)
	tween.tween_property(screen_fade, "modulate:a", 0.0, duration)
	
	await tween.finished
	screen_fade.visible = false
	screen_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transitioning = false
#endregion

#region Dealing Damage
func _on_hitbox_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	var stomping = velocity.y > 0 and global_position.y < enemy.global_position.y
	
	if stomping and enemy.has_method("take_damage"):
		stomped_this_frame = true
		call_deferred("_reset_stomp_priority")
	
		velocity.y = stomp_force
		enemy.take_damage(attack_damage)

func _reset_stomp_priority() -> void:
	stomped_this_frame = false
#endregion
