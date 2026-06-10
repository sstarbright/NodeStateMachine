class_name SprStateNode
extends StateNode

## The name of the Animation associated with this State.
@export var animation_name : String
## How much to scale the Animation when it plays.
@export var animation_speed := 1.0

var current_trans : SprBtwTransNode = null

func _process(_delta: float) -> void:
	if current_trans:
		var animator = state_machine.animator_node as AnimatedSprite3D
		if !animator.is_playing():
			animator.play(animation_name, animation_speed)
			animator.set_frame_and_progress(current_trans.target_start_frame, current_trans.target_start_progress)
			current_trans.finished.emit()
			current_trans = null

func _ready() -> void:
	super._ready()
	
	var animator = state_machine.animator_node
	if animator.sprite_frames.has_animation(animation_name):
		return
	
	push_error("Animation not found for %s in State Machine %s!" % [name, state_machine.name])

## INTERNAL - Enter this State and Exit the previous.
func _enter(is_initial : bool, trans_node : TransNode) -> bool:
	if super._enter(is_initial, trans_node):
		if state_machine is SprStateMachine:
			var animator = state_machine.animator_node
			
			if trans_node:
				if trans_node is SprBtwTransNode:
					animator.play(trans_node.transition_animation, trans_node.transition_speed)
					animator.set_frame_and_progress(0, 0.0)
					current_trans = trans_node
				elif trans_node is SprTransNode:
					animator.play(animation_name, animation_speed)
					animator.set_frame_and_progress(trans_node.target_start_frame, trans_node.target_start_progress)
			else:
				animator.play(animation_name, animation_speed)
				animator.set_frame_and_progress(0, 0.0)
			return true
	return false

## INTERNAL - Exit this State.
func _exit() -> bool:
	if current_trans:
		if current_trans.allow_cancel_transition:
			return super._exit()
		return false
	return super._exit()
