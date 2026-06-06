class_name AnimStateNode
extends StateNode

## The name of the Animation associated with this State. Must include Library name.
@export var animation_name : String
## How much to scale the Animation when it plays.
@export var animation_speed := 1.0

func _ready() -> void:
	super._ready()
	
	var animation_player = state_machine.animation_player
	var animation_found = false
	for animation_listing in animation_player.get_animation_list():
		if animation_listing == animation_name:
			var animation = animation_player.get_animation(animation_listing)
			animation_found = true
			break
	if !animation_found:
		push_error("Animation not found for %s in State Machine %s!" % [name, state_machine.name])
		return

## INTERNAL - Enter this State and Exit the previous.
func _enter(is_initial : bool, trans_node : TransNode):
	var animation_player = state_machine.animation_player
	if trans_node && trans_node is AnimTransNode:
		animation_player.play(animation_name, trans_node.transition_time, animation_speed)
	else:
		animation_player.play(animation_name, -1, animation_speed)
	super._enter(is_initial, trans_node)
