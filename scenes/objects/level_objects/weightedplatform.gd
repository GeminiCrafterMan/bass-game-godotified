class_name WeightedPlatform
extends StaticBody2D

@export var distance : int = 0
@export var bottomlimit : int = 0
@export var resistance_up : int
@export var resistance_down : int
@export var weighted : int = 0
var ticks : int = 0
var roll : int = 0

func _physics_process(delta):
	if weighted == -1:
		if distance > 0:
			if ticks >= resistance_up:
				ticks = 0
				position.y -= 1
				distance -= 1
				roll -= 1
			else:
				ticks += 1
	if weighted == 1:
		if distance < bottomlimit:
			if ticks >= resistance_down:
				ticks = 0
				position.y += 1
				distance += 1
				roll += 1
			else:
				ticks += 1
			
	if roll == -1:
		roll = 6
	if roll == 7:
		roll = 0
		
	$Wheel.set_frame_and_progress(roll,0)
	
		


func _on_trigger_body_entered(body):
	ticks = 0
	weighted = 1


func _on_trigger_body_exited(body):
	ticks = 0
	weighted = -1
