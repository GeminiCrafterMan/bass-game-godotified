extends CharacterBody2D

var time : int

func _ready():
	$SpawnSound.play()
	if GameState.character_selected == 0:
		$AnimatedSprite2D.play("Bass")
	else:
		$AnimatedSprite2D.play("Copy")
		
func _physics_process(delta):
	time = time + 1
	if $AnimatedSprite2D.animation == "Bass":
		if time > 25:
			$AnimatedSprite2D.play("Bass2")
	if $AnimatedSprite2D.animation == "Copy":
		if time > 25:
			$AnimatedSprite2D.play("Copy2")

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

