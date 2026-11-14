extends CharacterBody2D

#region Movement 
@export var max_speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

@export var jump_force: float = -400.0
@export var stomp_force: float = -150.0

@export var damage: int = 1

var input_direction: float = 0.0
#endregion

#region Health
@export var health: int = 5

@onready var hitbox = $hitbox
@onready var hurtbox = $hurtbox
#endregion

#region Movement
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
#endregion

#region Taking Damage
func _on_hurtbox_area_entered(area: Area2D) -> void:
	var enemy_damage = area.get_parent().damage
	take_damage(enemy_damage)

func take_damage(enemy_damage):
	health -= enemy_damage
	print(health)
	if Global.amount_of_checkpoints > 0:
		global_position = Global.checkpoint_position
#endregion

func _on_hitbox_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	var stomping = velocity.y > 0 and global_position.y < enemy.global_position.y
	if stomping and enemy.has_method("take_damage"): 
		velocity.y = stomp_force
		enemy.take_damage(damage)
	
