extends CanvasLayer
var flashes
@onready var start_timer = $timer

# Called when the node enters the scene tree for the first time.
func _ready():
	start_timer.start(0.75)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if start_timer.is_stopped():
		await $READY.animation_finished
		flashes =+ 1
		$READY.play("READY")
		if flashes == 7:
			queue_free()
	
