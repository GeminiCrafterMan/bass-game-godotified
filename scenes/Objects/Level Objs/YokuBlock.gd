@tool
class_name YokuBlock
extends StaticBody2D

const styles = [
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
@export var style : int = 0


## there are 4 slots, each should bleed a bit into the next a good bit.
## INTERVAL 0: STARTS 0   ENDS 105
## INTERVAL 1: STARTS 60  ENDS 165
## INTERVAL 2: STARTS 120 ENDS 225
## INTERVAL 3: STARTS 180 ENDS 45
@export_range(0,3) var interval : int
var timer : int

func _ready():
	$Sprite2D.texture = load(styles[style])

func _physics_process(delta):
	if timer == interval * 60:
		if not Engine.is_editor_hint():
			$Sound.play()
		$Sprite2D.frame = 1
		$Sprite2D.visible = true
		$Shape.set_disabled(false)
	
	if timer == interval * 60 + 5:
		$Sprite2D.frame = 0
	
	if timer == interval * 60 + 100 || interval == 3 && timer == 40:
		$Sprite2D.frame = 1
		
	if timer == interval * 60 + 105 || interval == 3 && timer == 45:
		$Sprite2D.visible = false
		$Shape.set_disabled(true)
	
	timer = (timer + 1) % 240 ## advance the timer per tick and wrap at 240

