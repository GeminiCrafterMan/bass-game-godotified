extends MaestroPlayer

class_name CopyRobotPlayer

func _init() -> void:
	weapon_palette = [
		preload("res://sprites/Players/Copy Robot/Palettes/Copy Buster.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Scorch Barrier.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Track 2.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Poison Cloud.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Fin Shredder.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Origami Star.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Wild Gale.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Rolling Bomb.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Boomerang Scythe.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Copy Buster.png"), # Proto Shield
		preload("res://sprites/Players/Copy Robot/Palettes/Copy Buster.png"), # "Treble Boost" (skip it)
		preload("res://sprites/Players/Copy Robot/Palettes/Carry.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Super Arrow.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Mirror Buster.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Screw Crusher.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Ballade Cracker.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Sakugarne.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/ChargeX1.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/ChargeX2.png")
	]

func _ready() -> void:
	super._ready()
