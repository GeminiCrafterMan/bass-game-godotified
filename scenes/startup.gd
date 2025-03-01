extends Node2D

var Action : int
var Subaction : int
var projectile
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await Fade.fade_in().finished
	$Timer.start(2)
	
func _physics_process(delta):
	if !$Timer.is_stopped():
		$Megaman.position.x += 3
	
	$Text.text = "x%02d" % Action
	
			
	if Action < 10:
		if $Megaman.position.x > $LogoM.position.x and $LogoM.visible == false:
			$LogoM.visible = true
		if $Megaman.position.x > $LogoE.position.x and $LogoE.visible == false:
			$LogoE.visible = true
		if $Megaman.position.x > $LogoG.position.x and $LogoG.visible == false:
			$LogoG.visible = true
		if $Megaman.position.x > $LogoA.position.x and $LogoA.visible == false:
			$LogoA.visible = true
	
	if Action == 1:
		if $CopyRobot.position.y >= 108:
			if $CopyRobot.animation != "warp":
				$CopyRobot.play("warp")
			$CopyRobot.position.y = 108
		else:
			$CopyRobot.position.y += 4
	
	if Action == 2:
		$Bass.position.x -= 2
	
	if Action > 11 && Action < 14:
		$CopyRobot.position.x -= 0.2
	
	if Action > 17:
		$Projectile2.position.x += 4
		
		if $LogoM != null:
			if $Projectile2.position.x > $LogoM.position.x:
				projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
				get_parent().add_child(projectile)
				projectile.position = $LogoM.position
				$LogoM.queue_free()
		if $LogoE != null:
			if $Projectile2.position.x > $LogoE.position.x:
				projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
				get_parent().add_child(projectile)
				projectile.position = $LogoE.position
				$LogoE.queue_free()
		if $LogoG != null:
			if $Projectile2.position.x > $LogoG.position.x:
				projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
				get_parent().add_child(projectile)
				projectile.position = $LogoG.position
				$LogoG.queue_free()
		if $LogoA != null:
			if $Projectile2.position.x > $LogoA.position.x:
				projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
				get_parent().add_child(projectile)
				projectile.position = $LogoA.position
				$LogoA.queue_free()
				
	if Action == 19:
		$Bass.position.x += 0.2
		
	if Action > 19:
		$CopyRobot.position.x -= 3
	
	if Action > 20:
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
			projectile = preload("res://scenes/objects/players/weapons/bass/buster.tscn").instantiate()
			get_parent().add_child(projectile)
			projectile.position = $Bass.position
			projectile.velocity.x = -250
			$Timer.start(0.15)
		
		if Action == 4:
			projectile.velocity.y = -4
		if Action == 5:
			projectile.velocity.y = 7
		if Action == 6:
			projectile.velocity.y = -2
		if Action == 7:
			projectile.velocity.y = 4
		if Action == 8:
			projectile.velocity.y = 2
		if Action == 9:
			projectile.velocity.y = 0
			
			
		if Action == 10:
			$Timer.start(0.25)
			
		
		if Action == 11:
			$Hurt.play()
			$CopyRobot.scale.x = 1
			$CopyRobot.play("hurt")
		
		if Action == 12:
			$Timer.start(0.75)
		
		
		if Action == 15:
			$CopyRobot.play("angry")
			$Bass.play("default")
			$Timer.start(0.25)
		if Action == 16:
			$CopyRobot.scale.x = 1
			$CopyRobot.play("shoot")
			$Timer.start(0.45)
		if Action == 17:
			$Projectile2.visible = true
			$ChargeShot.play()
			$Timer.start(0.55)
		if Action == 18:
			$Hurt.play()
			$Bass.play("hurt")
			$Timer.start(0.75)
		if Action == 19:
			$Bass.play("default")
			$CopyRobot.scale.x = -1
			$CopyRobot.play("run")
			$Timer.start(0.25)
		if Action == 20:
			$Bass.play("dash")
			$Dash.play()
			$Timer.start(2500)
			
		
		Action += 1
		
		


func _on_m_body_body_entered(weapon):
	$LogoM.play("damaged")
	weapon.destroy()
	$LogoM/MBody/CollisionShape2D.queue_free()

func _on_e_body_body_entered(weapon):
	$LogoE.play("damaged")
	weapon.destroy()
	$LogoE/EBody/CollisionShape2D.queue_free()

func _on_g_body_body_entered(weapon):
	$LogoG.play("damaged")
	weapon.destroy()
	$LogoG/GBody/CollisionShape2D.queue_free()

func _on_a_body_body_entered(weapon):
	$LogoA.play("damaged")
	weapon.destroy()
	$LogoA/ABody/CollisionShape2D.queue_free()
