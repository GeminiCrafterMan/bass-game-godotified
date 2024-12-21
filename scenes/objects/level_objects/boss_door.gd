class_name BossDoor
extends StaticBody2D

static var static_audio_player : AudioStreamPlayer2D

@export var state : int

func _physics_process(_delta):
	pass


func _on_close_trigger_body_exited(body: Node2D) -> void:
	pass
