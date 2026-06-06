class_name TransNode
extends Node

## INTERNAL - Type of Blocking the Advance Expression parser is currently blocked by.
enum BlockingType {
	## Currently NO Blocking.
	None,
	## Blocked by Number.
	## Waiting until non-valid character before looking for variable names again.
	Number,
	## Blocked by Single Quotation Mark.
	## Waiting until another Single Quotation Mark before looking for variable names again.
	SingleQuote,
	## Blocked by Double Quotation Mark.
	## Waiting until another Double Quotation Mark before looking for variable names again.
	DoubleQuote
}

## Triggered when this Transition is successfully triggered and the Transition has begun.
signal triggered

## INTERNAL - Keywords to filter out of the list of variable names found in the Advance Expression.
const EXPRESSION_KEYWORDS : Dictionary[String, bool] = {
	"null": true,
	"true": true,
	"false": true,
	"if": true,
	"elif": true,
	"else": true,
	"for": true,
	"while": true,
	"match": true,
	"when": true,
	"break": true,
	"continue": true,
	"pass": true,
	"return": true,
	"class": true,
	"class_name": true,
	"extends": true,
	"is": true,
	"in": true,
	"as": true,
	"self": true,
	"super": true,
	"signal": true,
	"func": true,
	"static": true,
	"const": true,
	"enum": true,
	"var": true,
	"breakpoint": true,
	"preload": true,
	"await": true,
	"yield": true,
	"assert": true,
	"void": true,
	"PI": true,
	"TAU": true,
	"INF": true,
	"NAN": true,
	"not": true,
	"and": true,
	"or": true
}

## The State that this Transition should travel the State Machine to.
@export var target_state : StateNode
## Whether this Transition should be used or not. Avoid setting Process Mode for TransNode, and use this instead.
@export var enabled := true
## Whether this Transition should proceed automatically when Advance Expression returns true.
@export var auto_transition := true
## An Advance Expression, used in two ways, depending on how auto_transition is set.
## If auto_transition is enabled, the Transition will be automatically triggered when the expression returns true.
## If auto_transition is disabled, any triggering of this Transition will only be allowed if the expression returns true.
## TODO - Allow for changing this at runtime
@export var advance_expression : String

## INTERNAL - The parsed Advance Expression.
@onready var _advance_express : Expression = Expression.new()
## INTERNAL - The variable names that will be queried for their values when the Advance Expression is checked.
var _expression_parameters : PackedStringArray = []
## INTERNAL - The values that will be loaded into the Advance Expression when checked.
var _expression_values : Array = []

## The State Machine associated with this Transition.
@onready var state_machine : StateMachine = get_parent().get_parent()

func _ready() -> void:
	if advance_expression:
		parse_expression_variables()
		if _advance_express.parse(advance_expression, _expression_parameters) != Error.OK:
			_advance_express.parse("true")
			_expression_parameters.clear()
			auto_transition = false
		else:
			for param in _expression_parameters:
				_expression_values.append(state_machine.advance_node.get(param))
	else:
		_advance_express.parse("true")
		auto_transition = false

func _process(_delta: float) -> void:
	if enabled:
		if auto_transition && _try_advance():
			triggered.emit()
			target_state._enter(false, self)

## INTERNAL - Used for filtering for variables in the Advance Expression.
func _is_part_of_variable(check_char : int):
	return check_char == 46 || (check_char >= 48 && check_char <= 57) || (check_char >= 65 && check_char <= 90) || check_char == 95 || (check_char >= 97 && check_char <= 122)

## INTERNAL - Check if the Advance Expression is true.
func _try_advance() -> bool:
	for idx in range(_expression_parameters.size()):
		_expression_values[idx] = state_machine.advance_node.get(_expression_parameters[idx])
	return _advance_express.execute(_expression_values)

## INTERNAL - Parse the Advance Expression string into a PackedStringArray of Variable Names.
func parse_expression_variables():
	var var_length := 0
	var current_blocking := BlockingType.None
	for idx in range(advance_expression.length()):
		var check_char = advance_expression[idx]
		var char_code = ord(check_char)
		if _is_part_of_variable(char_code):
			if current_blocking == 0:
				if (char_code >= 48 && char_code <= 57):
					if var_length > 0:
						var_length += 1
					else:
						current_blocking = BlockingType.Number
				else:
					var_length += 1
		else:
			if var_length > 0:
				var new_param := advance_expression.substr(idx-var_length, var_length)
				if !EXPRESSION_KEYWORDS.has(new_param):
					_expression_parameters.append(new_param.split(".")[0])
				var_length = 0
			
			if current_blocking == BlockingType.Number:
				current_blocking = BlockingType.None
			
			if check_char == '"':
				if current_blocking == BlockingType.DoubleQuote:
					current_blocking = BlockingType.None
				elif current_blocking == BlockingType.None:
					current_blocking = BlockingType.DoubleQuote
			elif check_char == "'":
				if current_blocking == BlockingType.SingleQuote:
					current_blocking = BlockingType.None
				elif current_blocking == BlockingType.None:
					current_blocking = BlockingType.SingleQuote
	if var_length > 0:
		var new_param := advance_expression.substr(advance_expression.length()-var_length, var_length)
		if !EXPRESSION_KEYWORDS.has(new_param):
			_expression_parameters.append(new_param.split(".")[0])

## INTERNAL - Switch directly to this Transition.
func _switch_to():
	if (!auto_transition && _try_advance()) || auto_transition:
		triggered.emit()
		target_state._enter(false, self)

## Trigger this Transition. Only works if enabled and currently processing.
func trigger() -> bool:
	if can_process() && enabled:
		get_parent()._switch_to(self)
		return true
	return false

## Enable this Transition.
func enable():
	enabled = true

## Disable this Transition.
func disable():
	enabled = false
