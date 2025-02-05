extends Area2D

@onready var water_splash_audio: AudioStreamPlayer2D = $WaterSplashAudio



func _on_body_entered(body: Node2D) -> void:
	water_splash_audio.play()
