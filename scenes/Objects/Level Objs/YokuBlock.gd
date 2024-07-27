extends Node2D

var timer : int
@export var interval : int
## there are 4 slots, each should bleed a bit into the next a good bit.
## INTERVAL 0: STARTS 0   ENDS 105
## INTERVAL 1: STARTS 60  ENDS 165
## INTERVAL 2: STARTS 120 ENDS 225
## INTERVAL 3: STARTS 180 ENDS 45

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
		
func _physics_process(delta):
	if timer == interval * 60:
		$AudioStreamPlayer.play()
		$Sprite2D2.visible = true
		$StaticBody2D/MainHitbox.set_disabled(false)
	
	if timer == interval * 60 + 5:
		$Sprite2D.visible = true
		$Sprite2D2.visible = false
		$StaticBody2D/MainHitbox.set_disabled(false)
	
	
	if timer == interval * 60 + 100 || interval == 3 && timer ==40:
		$Sprite2D2.visible = true
		$Sprite2D.visible = false
		
	if timer == interval * 60 + 105 || interval == 3 && timer ==45:
		$Sprite2D2.visible = false
		$StaticBody2D/MainHitbox.set_disabled(true)
	
	timer = timer+1 ## advance the timer per tick!
	
	if timer > 240:
		timer = 0
		

