extends Area2D

@export var topsolid : bool = true

func _ready() -> void:
	if topsolid == false:
		$Topbody.queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if topsolid == true:
		if GameState.playerstate == 7:
			$Topbody/TopBox.set_disabled(true)
		else:
			$Topbody/TopBox.set_disabled(false)
