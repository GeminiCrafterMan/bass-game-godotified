@tool
class_name BreakableBlock
extends StaticBody2D

const styles = [
	"Test",
	"Blaze",
	"Video",
	"Smog",
	"Shark",
	"Origami",
	"Gale",
	"Guerrilla",
	"Reaper"
]
var Dmg_Vals = [
		1,	#0  Bass Buster 
		1,	#1  Copy Buster
		2,	#2  Copy Buster, medium shot
		4,	#3  Copy Buster, charge shot
		3,	#4  Scorch Barrier
		0,	#5  Freeze Frame (if it does damage like Time Stopper on Quick Man)
		1,	#6  Poison Cloud
		6,	#7  Fin Shredder
		2,	#8  Origami Star
		10,	#9  Wild Gale
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
		0	# Whatever's next...
]

var _style : int = 0
## Breakable Block sprite set to display
@export var style : int :
	get:
		return _style
	set(value):
		if (value < styles.size()) && (value >= 0):
			_style = value;
			$AnimatedSprite2D.play(styles[style])

func _ready():
	$AnimatedSprite2D.play(styles[style])

func _on_hitable_body_entered(weapon):
	if weapon.W_Type == 3 or weapon.W_Type == 7 or weapon.W_Type == 13:
		weapon.kill()
	else:
		weapon.destroy()
	$Collision.queue_free()
	$hitable.queue_free()
	$AnimatedSprite2D.play("Explode")
	await $AnimatedSprite2D.animation_finished
	queue_free()
