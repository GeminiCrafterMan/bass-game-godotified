extends Node2D

var Action : int
var Subaction : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start(3)
	
func _physics_process(delta):
	$Megaman.position.x += 3
	
	
			
	
	if $Megaman.position.x > 192:
		$MegaLogo.visible = true
	
	if Action == 1:
		if $CopyRobot.position.y >= 108:
			if $CopyRobot.animation != "warp":
				$CopyRobot.play("warp")
			$CopyRobot.position.y = 108
		else:
			$CopyRobot.position.y += 4
	
	if Action == 2:
		$Bass.position.x -= 2
	
	if Action > 9 && Action < 11:
		$CopyRobot.position.x -= 0.2
	
	if Action > 13:
		$Projectile2.position.x += 4
		if $Projectile2.position.x > 192:
			$MegaLogo.visible = false
			
	if Action == 15:
		$Bass.position.x += 0.2
		
	if Action > 15:
		$CopyRobot.position.x -= 3
	
	if Action > 16:
		$Bass.position.x -= 4
		
	if $Timer.is_stopped():
		if Action == 0:
			$Timer.start(1)
		if Action == 1:
			$CopyRobot.play("default")
			$Timer.start(1.4)
		if Action == 2:
			$Bass.play("default")
			$Timer.start(0.75)
		if Action == 3:
			$Bass.play("shoot")
			$Timer.start(0.75)
		if Action == 4:
			$CopyRobot.play("what")
		if Action > 3 && Action < 10:
			$BusterSound.play()
			$Timer.start(0.25)
		if Action == 9:
			$Hurt.play()
			$CopyRobot.play("hurt")
		if Action == 11:
			$CopyRobot.scale.x = 1
			$CopyRobot.play("angry")
			$Bass.play("default")
			$Timer.start(0.25)
		if Action == 12:
			$CopyRobot.scale.x = 1
			$CopyRobot.play("shoot")
			$Timer.start(0.45)
		if Action == 13:
			$Projectile2.visible = true
			$ChargeShot.play()
			$Timer.start(0.55)
		if Action == 14:
			$Hurt.play()
			$Bass.play("hurt")
			$Timer.start(0.75)
		if Action == 15:
			$Bass.play("default")
			$CopyRobot.scale.x = -1
			$CopyRobot.play("run")
			$Timer.start(0.25)
		if Action == 16:
			$Bass.play("dash")
			$Dash.play()
			
		
		Action += 1
		
		
