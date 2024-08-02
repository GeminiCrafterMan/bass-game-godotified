class_name StageSelect
extends Control

const _playerPortraits := [
	preload("res://sprites/Menus/Stage Select - Bass - Atlas.tres"),
	preload("res://sprites/Menus/Stage Select - Copy Robot - Atlas.tres")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	var player := %Player as StageSelectPanel
	player.portrait = _playerPortraits[GameState.character_selected]
	await Fade.fade_in().finished
	%Player.grab_focus()
	
func panel_focused(index: int):
	var player := %Player as StageSelectPanel
	if not player: return
	var portrait := player.portrait as AtlasTexture
	if not portrait: return
	portrait.region.position.x = (floor(portrait.atlas.get_width()) / 9) * index
