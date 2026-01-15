/// Types of dashboard controls available in the Rmotly app
///
/// Each control type has different interaction patterns and event payloads:
/// - [button]: Single tap trigger, sends `{ "pressed": true }`
/// - [toggle]: On/off switch, sends `{ "state": true/false }`
/// - [slider]: Range value selector, sends `{ "value": 0.0-1.0 }`
/// - [input]: Text input with submit, sends `{ "text": "user input" }`
/// - [dropdown]: Selection from options, sends `{ "selected": "option_id" }`
enum ControlType {
  /// A button control that triggers an action on tap
  button,

  /// A toggle/switch control for on/off states
  toggle,

  /// A slider control for selecting values in a range
  slider,

  /// A text input control for entering custom text
  input,

  /// A dropdown control for selecting from predefined options
  dropdown;

  /// Returns a human-readable label for the control type
  String get label {
    switch (this) {
      case ControlType.button:
        return 'Button';
      case ControlType.toggle:
        return 'Toggle';
      case ControlType.slider:
        return 'Slider';
      case ControlType.input:
        return 'Input';
      case ControlType.dropdown:
        return 'Dropdown';
    }
  }

  /// Returns a description of the control type
  String get description {
    switch (this) {
      case ControlType.button:
        return 'Trigger an action with a single tap';
      case ControlType.toggle:
        return 'Switch between on and off states';
      case ControlType.slider:
        return 'Select a value from a range';
      case ControlType.input:
        return 'Enter custom text or values';
      case ControlType.dropdown:
        return 'Choose from a list of options';
    }
  }

  /// Returns the event payload structure for this control type
  String get payloadDescription {
    switch (this) {
      case ControlType.button:
        return '{ "pressed": true }';
      case ControlType.toggle:
        return '{ "state": true/false }';
      case ControlType.slider:
        return '{ "value": 0.0-1.0 }';
      case ControlType.input:
        return '{ "text": "user input" }';
      case ControlType.dropdown:
        return '{ "selected": "option_id" }';
    }
  }
}
