extends CanvasLayer

#region Enums
enum WEAPONS {BUSTER, BLAZE, VIDEO, SMOG, SHARK, ORIGAMI, GALE, GUERRILLA, REAPER, PROTO, TREBLE, CARRY, ARROW, ENKER, PUNK, BALLADE, QUINT}
enum PALETTE {NONE, MD, NES, DOOM, PICO8, GB, VB, C64, CGA, G4, G8, G16}
#endregion

#region Schemas
var modSchema = Z.schema({
	"name": Z.string().non_empty(),
	"author": Z.string().non_empty(),
	"version": Z.string().non_empty(),
	"characterName": Z.string().non_empty(),
})
#endregion

#region Variables
## List of characters. Mods can add to this to add their own characters.
var characters : Array[String] = [
	"res://scenes/objects/players/maestro.tscn",
	"res://scenes/objects/players/bass.tscn",
	"res://scenes/objects/players/copy_robot.tscn",
	"res://scenes/objects/players/maestro.tscn" # Megaman
]
## List of life icon PNGs.
var lifeIcons : Array[String] = [
	"res://sprites/players/maestro/life.png",
	"res://sprites/players/bass/life.png",
	"res://sprites/players/copy_robot/life.png",
	"res://sprites/players/megaman/life.png"
]
## List of stage select portrait PNGs.
var stageSelectPlayerPortraits : Array[String] = [
	"res://sprites/players/maestro/stageselect.png",
	"res://sprites/players/bass/stageselect.png",
	"res://sprites/players/copy_robot/stageselect.png",
	"res://sprites/players/megaman/stageselect.png"
]
## List of stage select color translations. G: ...I couldn't make this pick Maestro's by default.
var stageSelectColorTranslations : Array[String] = [
	"res://sprites/players/maestro/stageseltrans.png",
	"res://sprites/players/bass/stageseltrans.png",
	"res://sprites/players/copy_robot/stageseltrans.png",
	"res://sprites/players/megaman/stageseltrans.png"
]


var maxCharacterID = characters.size() - 1 # Whyyyyy...?
var character_selected : int
var player # absolute path to player node
var player_lives : int = 3

# TODO: Could be improved using object pooling
var onscreen_bullets : int
var onscreen_sp_bullets : int

var playerposx
var playerposy
var playerstate

#Camera Variables
var camposx
var camposy
var screenmode

var scrollX1
var scrollX2
var scrollY1
var scrollY2

var dest_X
var dest_Y

var screentransiton : int
var transdir : int

var checkpoint

var current_weapon : int
var old_weapon : int
var current_hp = 28
var bolts = 0
var ETanks = 0
var WTanks = 0
var STanks = 0
var max_hp = 28 # G: upgradeable # M: not upgradable anymore # G: yeah but mod characters :))
var healamt = 0
var ammoamt = 0
var droptimer : int
var itemtimer : int

var PROGRESSDICT = {
	"BlazeDead": false,
	"VideoDead": false,
	"OrigamiDead": false,
	"GaleDead": false,
	"GuerillaDead": false,
	"ReaperDead": false,
	"SharkDead": false,
	"SmogDead": false,
	"EnkerDead": false,
	"PunkDead": false,
	"BalladeDead": false,
	"QuintDead": false,
	"TrebleDead": false,
	"ProtoManDead": false,
	"HaveProtoKey1": false,
	"HaveProtoKey2": false,
	"HaveProtoKey3": false,
	"HaveProtoKey4": false
}

var infinite_ammo : bool = false
var weapon_energy : Array = [
	0,	# Buster
	28,	# Scorch Barrier
	28,	# Freeze Frame
	28,	# Poison Cloud
	28,	# Fin Shredder
	28,	# Origami Star
	28,	# Wild Gale
	28,	# Rolling Bomb
	28,	# Boomerang Scythe
	28,	# Proto Buster
	28,	# Treble Boost
# CR-exclusive
	28,	# Carry
	28,	# Super Arrow
	28,	# Mirror Buster
	28,	# Screw Crusher
	28,	# Ballade Cracker
	28	# Sakugarne
]

var max_weapon_energy : Array = [
# G: Energy use is always 1, *no matter what*. Increase energy and max_energy values to have larger shot counts.
# M: what the hell are you talking about???
# G: i literally have no idea, i think i was trying to think of how we'd spend ammo in a more automatic way but like
# G: that's stupid
	0,	# Buster
	28,	# Scorch Barrier
	28,	# Freeze Frame
	28,	# Poison Cloud
	28,	# Fin Shredder
	28,	# Origami Star
	28,	# Wild Gale
	28,	# Rolling Bomb
	28,	# Boomerang Scythe
	28,	# Proto Buster
	28,	# Treble Boost
# CR-exclusive
	28,	# Carry
	28,	# Super Arrow
	28,	# Mirror Buster
	28,	# Screw Crusher
	28,	# Ballade Cracker
	28	# Sakugarne
]

var weapons_unlocked = [
	# Buster, under no circumstances should this be disabled
	true, # Buster
	# Special weapons shared between Bass and Copy Robot
	false, # Blaze
	false, # Video
	false, # Smog
	false, # Shark
	false, # Origami
	false, # Gale
	false, # Guerrilla
	false, # Reaper
	false, # Proto Buster
	#Bass Only
	false, # Treble Boost
	#Copy Robot Only
	false, # Carry
	false, # Super Arrow
	false, # Mirror Buster
	false, # Screw Crusher
	false, # Ballade Cracker
	false, # Sakugarne
]

var modules_enabled = [
	true, # nothing lol
	false, # Blast Jump
	false, # Track 2
	false, # Mist Dash
	false, # Aqua Drive
	false, # Paper Cut
	false, # Aero Glide
	false, # Machine Buster
	false, # Spirit Dash
	false, # Proto Shield
]
#endregion

func refill_health() -> void:
	current_hp = max_hp # Reset HP

func refill_ammo() -> void:
	for n in weapon_energy.size():
		weapon_energy[n] = max_weapon_energy[n] # Reset WE

func load_custom() -> void:
	var file_names: Array[String]
	var dir = DirAccess.open("res://custom")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".pck"):
				print("Found custom file: " + file_name)
				file_names.append(file_name)
			file_name = dir.get_next()
	else:
		if OS.is_debug_build():
			push_warning("No custom folder found")

	for file in file_names:
		var resource_loaded = ProjectSettings.load_resource_pack(str("res://custom/", file))

		if resource_loaded:
			print(file + " loaded as resource")
			var mod_config = FileAccess.open("res://mod.json", FileAccess.READ)
			var json = JSON.new()
			var data = json.parse(mod_config.get_as_text())

			if data == OK:
				var result = modSchema.parse(json.data)
				if result.ok():
					# TODO: Add proper schema validation instead assuming JSON data is correct just because it's an array
					
					characters.append(str("res://scenes/objects/players/", result.data.characterName, '/', result.data.characterName, ".tscn" ))
					lifeIcons.append(str("res://sprites/players/", result.data.characterName, "/life.png"))
					stageSelectPlayerPortraits.append(str("res://sprites/players/", result.data.characterName, "/stageselect.png"))
					stageSelectColorTranslations.append(str("res://sprites/players/", result.data.characterName, "/stageseltrans.png"))
					maxCharacterID = characters.size() - 1
					print("Added character '", result.data.name, "' by '", result.data.author, '\'')
				else:
					push_error("mod.json is malformed: ", result.error)
			else:
				push_error("JSON parse Error: ", json.get_error_message(), " in ", mod_config, " at line ", json.get_error_line())
		else:
			push_error("Failed to load " + file + " as custom")

func _ready() -> void:
	load_custom()
