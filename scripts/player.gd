extends CharacterBody2D

#region Variables
@export var max_speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0
@export var jump_force: float = -400.0

var input_direction: float = 0.0
#endregion


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += Global.gravity * delta

	if input_direction != 0:
		velocity.x = move_toward(velocity.x, input_direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	if event.is_action("move_left") or event.is_action("move_right"):
		input_direction = Input.get_axis("move_left", "move_right")
