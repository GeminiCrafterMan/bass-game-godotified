extends CharacterBody2D

@onready var anim = $AnimationPlayer

func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.y = -200
		anim.play("Jump")
	else:
		velocity += get_gravity() * delta
	if velocity.y > 0:
		anim.play("Fall")
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("mount_sakugarne"):
		body.mount_sakugarne()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets = 0
	queue_free()
