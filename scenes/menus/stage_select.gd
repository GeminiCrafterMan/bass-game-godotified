class_name StageSelect extends CanvasLayer

var fadeout : int = 120 # G: this does nothing?

# Called when the node enters the scene tree for the first time.
func _ready():
	var player := %Player as StageSelectPanel
	player.portrait.atlas = load(GameState.stageSelectPlayerPortraits[GameState.character_selected])
	await Fade.fade_in().finished
	%Player.grab_focus()

func _physics_process(_delta):
	await $Timer.timeout # G: turned timer int into a real timer using a node that was already here but unused
	$Darkness.hide()
	%Player.grab_focus()
	$Music.play() # Not at the very start of the scene; we have to wait for the fade-in
	$Rows/RowBright.play()
	
	$Background.material.set_shader_parameter("palette", load(GameState.stageSelectColorTranslations[GameState.character_selected]))
	$Rows.material.set_shader_parameter("palette", load(GameState.stageSelectColorTranslations[GameState.character_selected]))
		
	$"Rows/Row 2/RowPt1".material.set_shader_parameter("palette", load(GameState.stageSelectColorTranslations[GameState.character_selected]))
	$"Rows/Row 2/RowPt2".material.set_shader_parameter("palette", load(GameState.stageSelectColorTranslations[GameState.character_selected]))
	$"Rows/Row 2/RowPt3".material.set_shader_parameter("palette", load(GameState.stageSelectColorTranslations[GameState.character_selected]))
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Blaze Man/VBoxContainer/Portrait/Border".material.set_shader_parameter("palette", GameState.stageSelectColorTranslations[GameState.character_selected])
	
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Blaze Man/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Video Man/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Smog Man/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Shark Man/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Player/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Origami Man/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Gale Woman/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Guerilla Man/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Reaper Man/VBoxContainer/Portrait/PortraitFlash".play()
	
func panel_focused(index: int):
	var player := %Player as StageSelectPanel
	if not player: return
	var portrait := player.portrait as AtlasTexture
	if not portrait: return
	portrait.region.position.x = (floor(portrait.atlas.get_width()) / 9) * index
