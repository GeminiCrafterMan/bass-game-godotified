@tool
extends Area2D

class_name ScreenChange
@export var scrollX1 : int ##Left bounds of the current room
@export var scrollX2 : int ##Right bounds of the current room
@export var scrollY1 : int ##Top bounds of the current room
@export var scrollY2 : int ##Bottom bounds of the current room

var oldX1
var oldX2
var oldY1
var oldY2


var icon
var oldposx
var oldposy

var oldscalex
var oldscaley

@export var direction : int ##right = 1 down = 2 left = 3 up = 4

@export var screenmode : int

@export var ladderonly : bool
@export var onetimeuse : bool = true
@export var smooth : bool = false

func _on_body_entered(body):
	print("yo")
	if body.is_in_group("player") && GameState.transdir == 0:
		if ladderonly == false or GameState.playerstate == 7:
			if scrollX1 != GameState.scrollX1 or scrollX2 != GameState.scrollX2 or scrollY1 != GameState.scrollY1 or scrollY2 != GameState.scrollY2:
				
				#set these to make sure
				GameState.scrollX3 = GameState.scrollX1
				GameState.scrollX4 = GameState.scrollY2
				GameState.scrollY3 = GameState.scrollX1
				GameState.scrollY4 = GameState.scrollY2
				
				GameState.scrollX1 = scrollX1
				GameState.scrollX2 = scrollX2
				GameState.scrollY1 = scrollY1
				GameState.scrollY2 = scrollY2
		
				GameState.screenmode = screenmode
				
				if smooth == false:
					GameState.transdir = direction
					GameState.screentransiton = 25
				
				if onetimeuse == true:
					queue_free()
