extends TileMap

var time : int

# Called when the node enters the scene tree for the first time.
func _ready():
	var character_node = get_node(GameState.player)
	time = 0
	set_layer_enabled ( 1, true )
	set_layer_enabled ( 2, false )


func _get_configuration_warnings():
	if time == 0:
		set_layer_enabled ( 2, true )
		set_layer_enabled ( 1, false )
		time = 1
	else:
		set_layer_enabled ( 2, true )
		set_layer_enabled ( 1, false )
		time = 0
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
