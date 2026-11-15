extends Node2D

#region Variables
var activated: bool = false
#endregion

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if activated:
		return
	
	Global.current_level += 1
	get_tree().change_scene_to_file()
