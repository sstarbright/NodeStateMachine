@tool
class_name AnimStateMachine
extends StateMachine

## The AnimationPlayer to use for this State Machine.
@export var animation_player : AnimationPlayer:
	set(value):
		animation_player = value
		update_configuration_warnings()

## INTERNAL - Verify a Node as an AnimStateNode.
func verify_state(state : Node):
	return (state is AnimStateNode)

func _get_configuration_warnings():
	if !animation_player:
		var warnings = super._get_configuration_warnings()
		warnings.append("Animation Player must be set!")
		return warnings
	else:
		return super._get_configuration_warnings()
