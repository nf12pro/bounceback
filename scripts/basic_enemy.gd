
extends CharacterBody2D

#region Health Variables
var health: int = 1
var spawn_health: int = 1
#endregion

#region Movement
@export var speed: float = 100.0
@export var spawn_direction: int = 1

var direction: int = 1
@onready var floor_detector: RayCast2D = $floor_detector
#endregion

#region Respawning
var spawn_position: Vector2 = Vector2.ZERO

#region Movement
func _ready() -> void:
	direction = spawn_direction
	health = spawn_health
	floor_detector.position.x = abs(floor_detector.position.x) * direction
	
	add_to_group("enemies")
	spawn_position = global_position
	respawn()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += Global.gravity * delta
	
	velocity.x = direction * speed
	move_and_slide()
	
	if is_on_wall() or (is_on_floor() and not floor_detector.is_colliding()):
		flip_direction()

func flip_direction() -> void:
	direction *= -1
	floor_detector.position.x = abs(floor_detector.position.x) * direction
	floor_detector.force_raycast_update()
#endregion

#region Health
func take_damage(enemy_damage: int) -> void:
	health -= enemy_damage
	if health <= 0:
		die()
#endregion

#region Despawn/Respawn
func die() -> void:
	visible = false
	set_physics_process(false)
	call_deferred("_set_collisions_enabled", false)

func respawn() -> void:
	health = spawn_health
	global_position = spawn_position
	direction = spawn_direction
	
	velocity = Vector2.ZERO
	floor_detector.position.x = abs(floor_detector.position.x) * direction
	floor_detector.force_raycast_update()
	
	visible = true
	set_physics_process(true)
	call_deferred("_set_collisions_enabled", true)
	
func _set_collisions_enabled(enabled: bool) -> void:
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = not enabled
		elif child is Area2D:
			child.monitoring = enabled
			child.monitorable = enabled
#endregion
