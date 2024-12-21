extends Area2D

class_name ScreenChange
@export var scrollX1 : int ##Left bounds of the current room
@export var scrollX2 : int ##Right bounds of the current room
@export var scrollY1 : int ##Top bounds of the current room
@export var scrollY2 : int ##Bottom bounds of the current room

var icon
var oldposx
var oldposy

var oldscalex
var oldscaley

@export var direction : int ##right = 1 down = 2 left = 3 up = 4

@export var screenmode : int

func _on_body_entered(body):
	print("yo")
	if body.is_in_group("player") && GameState.transdir == 0:
		GameState.scrollX1 = scrollX1
		GameState.scrollX2 = scrollX2
		GameState.scrollY1 = scrollY1
		GameState.scrollY2 = scrollY2

		GameState.screenmode = screenmode
		GameState.transdir = direction
		GameState.screentransiton = 25
