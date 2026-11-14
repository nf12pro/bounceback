extends CharacterBody2D

#region Basic Variables
var health: int = 1
#endregion

#region Movement
@export var speed: float = 100.0
@export var start_direction: int = 1

var direction: int = 1
@onready var floor_detector: RayCast2D = $floor_detector
#endregion

#region Damage and Health
@export var damage: int = 1
#endregion

#region Movement
func _ready() -> void:
	direction = start_direction
	floor_detector.position.x = abs(floor_detector.position.x) * direction

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
func take_damage(enemy_damage):
	health -= enemy_damage
	if health <= 0:
		queue_free()
#endregion
