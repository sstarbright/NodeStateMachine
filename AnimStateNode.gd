class_name AnimStateNode
extends StateNode

## The name of the Animation associated with this State. Must include Library name.
@export var animation_name : String
## How much to scale the Animation when it plays.
@export var animation_speed := 1.0

func _ready() -> void:
	super._ready()
	
	var animation_player = state_machine.animation_player
	if animation_player.has_animation(animation_name):
		return
	
	push_error("Animation not found for %s in State Machine %s!" % [name, state_machine.name])

## INTERNAL - Enter this State and Exit the previous.
func _enter(is_initial : bool, trans_node : TransNode):
	var animation_player = state_machine.animation_player
	if trans_node && trans_node is AnimTransNode:
		animation_player.play(animation_name, trans_node.transition_time, animation_speed)
	else:
		animation_player.play(animation_name, -1, animation_speed)
	super._enter(is_initial, trans_node)
