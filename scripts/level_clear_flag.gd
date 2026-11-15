extends Node2D

#region Variables
var activated: bool = false
#endregion

func _on_area_2d_body_entered(body: Node2D) -> void:
	if activated or not body.has_method("fade_out"):
		return
	
	activated = true
	self.modulate = Color.GREEN
	
	await body.fade_out()
	
	Global.current_level += 1
	get_tree().change_scene_to_file("res://scenes/level_%d.tscn" % Global.current_level)
