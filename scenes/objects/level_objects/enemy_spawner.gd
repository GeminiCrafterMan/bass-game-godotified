@tool

extends Node2D

class_name enemy_spawn
var oldposx
var oldposy
var oldtype : int
var oldsubtype : int
var olddirection: int

@export var type : int ##The type of enemy.
@export var direction : int
@export var subtype : int
@export var difficulty : int ##0: Easy, 1: Normal, 2:Hard, 3:V.H.
@onready var baby
var enemytype = [
	preload("res://scenes/objects/enemies/sniper_joe.tscn"),
	preload("res://scenes/objects/enemies/gabyoall.tscn"),
	preload("res://scenes/objects/enemies/shotman.tscn"),
	preload("res://scenes/objects/enemies/wanaan_kai.tscn")
]

func _on_visible_on_screen_notifier_2d_screen_entered():
	if not Engine.is_editor_hint():
		if (GameState.difficulty == null) or (difficulty > GameState.difficulty):
			queue_free()
		if baby == null:
			baby = enemytype[type].instantiate()
			get_parent().add_child(baby)
			baby.position.x = position.x
			baby.position.y = position.y
			if direction == 1: 
				baby.scale.x = -1
			
			baby.position.x = position.x
			baby.position.y = position.y

func _process(delta):
	if not Engine.is_editor_hint():
		return
	if Engine.is_editor_hint():
		if baby == null:
			baby = enemytype[type].instantiate()
			get_parent().add_child(baby)
			baby.position.x = position.x
			baby.position.y = position.y
			
		if baby != null:
			if oldposx != position.x:
				baby.queue_free()
			if oldposy != position.y:
				baby.queue_free()
			if oldtype != type:
				baby.queue_free()
			if oldsubtype != subtype:
				baby.queue_free()
			if olddirection != direction:
				baby.queue_free()
		
		oldposx = position.x
		oldposy = position.y
		oldtype = type
	else:
		pass
		
