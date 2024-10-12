@tool
class_name YokuBlock
extends StaticBody2D

static var static_audio_player : AudioStreamPlayer2D
const styles = [
	"res://sprites/objects/yoku_blocks/Test.png",
	"res://sprites/objects/yoku_blocks/Blaze.png",
	"res://sprites/objects/yoku_blocks/Video.png",
	"res://sprites/objects/yoku_blocks/Smog.png",
	"res://sprites/objects/yoku_blocks/Shark.png",
	"res://sprites/objects/yoku_blocks/Origami.png",
	"res://sprites/objects/yoku_blocks/Gale.png",
	"res://sprites/objects/yoku_blocks/Guerrilla.png",
	"res://sprites/objects/yoku_blocks/Reaper.png"
]

var _style : int = 0
## Yoku Block sprite set to display
@export var style : int :
	get:
		return _style
	set(value):
		if (value < styles.size()) && (value >= 0):
			_style = value;
			$Sprite2D.texture = load(styles[_style])
			
#@onready var player = get_tree().get_nodes_in_group("Player")[0] 

## there are 4 slots, each should bleed a bit into the next a good bit.
## INTERVAL 0: STARTS 0   ENDS 105
## INTERVAL 1: STARTS 60  ENDS 165
## INTERVAL 2: STARTS 120 ENDS 225
## INTERVAL 3: STARTS 180 ENDS 45
@export_range(0,3) var interval : int

@onready var timer = $Timer

var state : bool = false # Off (in)

func _ready():
	timer.start(interval)
	if !static_audio_player:
		static_audio_player = $YokuSound
	$Sprite2D.texture = load(styles[_style])

func _physics_process(_delta):
	if timer.is_stopped(): # interval * 60
		if not Engine.is_editor_hint():
			var players = get_tree().get_nodes_in_group("player")
			if static_audio_player && players.size() >= 1:
				if position.distance_to(players[0].position) < 216:
					static_audio_player.play()
		$AnimationPlayer.play("default")
		timer.start(4)
