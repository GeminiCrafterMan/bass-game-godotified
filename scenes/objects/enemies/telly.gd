extends Enemy_Template


var telly_hole : Telly_Hole
@onready var projectile
@onready var timer = $Timer
@onready var player := GameState.player as CharacterBody2D
func _ready():
	$Sprite.play("Spawn")
	$Timer.start(0.75)
	Atk_Dmg = 2
	Cur_HP = 1

	Dmg_Vals = [
		1,	#0  Bass Buster
		1,	#1  Copy Buster
		2,	#2  Copy Buster, medium shot
		4,	#3  Copy Buster, charge shot
		3,	#4  Scorch Barrier
		0,	#5  Freeze Frame (if it does damage like Time Stopper on Quick Man)
		1,	#6  Poison Cloud
		8,	#7  Fin Shredder
		2,	#8  Origami Star
		8,	#9  Wild Gale
		2,	#10 Rolling Bomb(?)
		3,	#11 Boomerang Scythe
		2,	#12 Proto Buster medium shot
		4,	#13 Proto Buster charged shot
		4,	#14 Super Arrow
		1,	#15 Mirror Buster
		2,	#16 Screw Crusher
		4,	#17 Ballade Cracker
		4,	#18 Sakugarne (Physical hit)
		1,	#19 Sakugarne (Rock)
		3,	#20 Blast jump
		4,	#21 Paper Cut slice
		5,	#22 Charged Boomer Scythe
		5,	#23 CR Shredder
		5,	#24 CR Shredder 2
		0	# Whatever's next...
]

func _physics_process(_delta):
	if Cur_HP <= 0:
		projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		if GameState.droptimer < 4:
			projectile = preload("res://scenes/objects/items/pickup.tscn").instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.dropped = true
		queue_free()

	if $Timer.is_stopped():
		$Sprite.play("Move")

	if $Sprite.animation == "Move":
		position.x = move_toward(position.x, GameState.player.position.x, 0.3)
		position.y = move_toward(position.y, GameState.player.position.y, 0.3)


func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	if Cur_Inv <= 0 or weapon.W_Type == 8 or weapon.W_Type == 11 or weapon.W_Type == 22:
		if Dmg_Vals[weapon.W_Type] == 0:
			if weapon.W_Type == 7:
				weapon.destroy()
			else:
				weapon.reflect()
		else:
			if weapon.is_in_group("scorch"):
				if GameState.character_selected == 1:
					weapon.durability -= 3
				else:
					weapon.durability -= 3
			Cur_HP -= Dmg_Vals[weapon.W_Type]
			Cur_Inv = 2
			if Cur_HP <= 0 or weapon.W_Type == 7 or weapon.W_Type == 11 or weapon.W_Type == 22:
				weapon.kill()
			else:
				weapon.destroy()

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _exit_tree() -> void:
	if telly_hole:
		telly_hole.num_tellies -= 1
