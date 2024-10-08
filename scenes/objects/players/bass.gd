extends MaestroPlayer

func _init() -> void:
	weapon_palette = [
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Scorch Barrier.png"),
		preload("res://sprites/players/bass/palettes/Freeze Frame.png"),
		preload("res://sprites/players/bass/palettes/Poison Cloud.png"),
		preload("res://sprites/players/bass/palettes/Fin Shredder.png"),
		preload("res://sprites/players/bass/palettes/Origami Star.png"),
		preload("res://sprites/players/bass/palettes/Wild Gale.png"),
		preload("res://sprites/players/bass/palettes/Rolling Bomb.png"),
		preload("res://sprites/players/bass/palettes/Boomerang Scythe.png"),
		preload("res://sprites/players/bass/palettes/Proto Buster.png"),
		preload("res://sprites/players/bass/palettes/Treble.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Proto Charge 1.png"),
		preload("res://sprites/players/bass/palettes/Proto Charge 2.png"),
		preload("res://sprites/players/weapons/ScytheCharge0.png"),
		preload("res://sprites/players/weapons/ScytheCharge1.png")
	]
	weapon_scenes = [
		preload("res://scenes/objects/players/weapons/special_weapons/origami_star.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/poison_cloud.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/scorch_barrier.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/rolling_bomb.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/fin_shredder.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/boomer_scythe.tscn")
	]
