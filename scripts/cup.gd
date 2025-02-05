extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func die()-> void:
	animation_player.play("vanish_anim")


func _on_animation_finished(anim_name: StringName) -> void:
	queue_free()
	SignalManager.ON_CUP_DESTROYED.emit()
