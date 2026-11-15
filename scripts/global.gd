extends Node

#region Variables
var gravity: float = 1000

var amount_of_checkpoints: int = 0
var current_checkpoint_position: Vector2 = Vector2.ZERO
var first_checkpoint_position: Vector2 = Vector2.ZERO
var checkpoints_reset: bool = false

var current_level: int = 1
#endregion
