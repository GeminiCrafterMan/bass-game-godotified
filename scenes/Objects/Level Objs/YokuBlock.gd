@tool
extends Node2D

var timer : int
@export var style : int = 0
var styles = [
	"res://sprites/Objects/Yoku Blocks/Test.png",
	"res://sprites/Objects/Yoku Blocks/Blaze.png",
	"res://sprites/Objects/Yoku Blocks/Video.png",
	"res://sprites/Objects/Yoku Blocks/Smog.png",
	"res://sprites/Objects/Yoku Blocks/Shark.png",
	"res://sprites/Objects/Yoku Blocks/Origami.png",
	"res://sprites/Objects/Yoku Blocks/Gale.png",
	"res://sprites/Objects/Yoku Blocks/Guerrilla.png",
	"res://sprites/Objects/Yoku Blocks/Reaper.png"
]

@export var interval : int
## there are 4 slots, each should bleed a bit into the next a good bit.
## INTERVAL 0: STARTS 0   ENDS 105
## INTERVAL 1: STARTS 60  ENDS 165
## INTERVAL 2: STARTS 120 ENDS 225
## INTERVAL 3: STARTS 180 ENDS 45

func _ready():
	$Sprite2D.texture = load(styles[style])

func _physics_process(delta):
	if timer == interval * 60:
		if not Engine.is_editor_hint():
			$YokuSound.play()
		$Sprite2D.frame = 1
		$Sprite2D.visible = true
		$StaticBody2D/MainHitbox.set_disabled(false)
	
	if timer == interval * 60 + 5:
		$Sprite2D.frame = 0
		$Sprite2D.visible = true
		$StaticBody2D/MainHitbox.set_disabled(false)
	
	if timer == interval * 60 + 100 || interval == 3 && timer == 40:
		$Sprite2D.frame = 1
		$Sprite2D.visible = true
		
	if timer == interval * 60 + 105 || interval == 3 && timer == 45:
		$Sprite2D.visible = false
		$StaticBody2D/MainHitbox.set_disabled(true)
	
	timer = timer+1 ## advance the timer per tick!
	
	if timer > 240:
		timer = 0
		

