extends Resource

class_name CN_SF1_Spell

## The name of the spell that will be used in game
export var name: String
## The image icon that will be used for this spell (Drag in an image directly)
export var spell_texture: Texture

## Self - means no selection ex. egress as an example
## Enemeies - means only enemies can be targeted ex. blaze
## Characters - only allied force members ex. heal
export(int, "Self", "Enemeies", "Characters") var usable_on_actor_type

#export(Array, SpellLevelInfo) var test
# Make this a resource and have an array track it instead 
# this should be an array
#export var mp_usage_cost: int = 1
#export var level: int
#export var spell_range: int = 1
#export var spell_target_range: int = 1

export(Array, Resource) var levels

# TODO: expand on this for ROTDD type magic resistance
## The element type of the spell (Used when ROTDD conventions are enable for magic resistance)
export(int, "None", "Fire") var element_type: int

# TODO: check for other features in ROTDD
# have the nagging feeling I'm missing something

export var spell_use_range_path: String
export var spell_use_target_path: String

export var spell_animation_resource: Resource

func _ready():
	pass
