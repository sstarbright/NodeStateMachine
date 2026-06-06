@tool
class_name SprStateMachine
extends StateMachine

## The AnimationPlayer to use for this State Machine.
@export var animator_node : Node:
	set(value):
		animator_node = value
		update_configuration_warnings()

## INTERNAL - Verify a Node as an SprStateNode.
func verify_state(state : Node):
	return (state is SprStateNode)

func _get_configuration_warnings():
	if !animator_node || (animator_node is not AnimatedSprite2D && animator_node is not AnimatedSprite3D):
		var warnings = super._get_configuration_warnings()
		warnings.append("Animator must be set, and must be AnimatedSprite2D/3D!")
		return warnings
	else:
		return super._get_configuration_warnings()
