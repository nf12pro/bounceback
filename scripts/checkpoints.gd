extends Node2D

#region Variables
var checkpoint_activated: bool = false
#endregion

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if checkpoint_activated == true:
		return
	
	Global.amount_of_checkpoints += 1
	Global.checkpoint_position = global_position
	
	self.modulate = Color.GREEN_YELLOW
	checkpoint_activated = true
