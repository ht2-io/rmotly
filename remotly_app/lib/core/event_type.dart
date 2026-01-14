/// Types of events that can be triggered in the Remotly app
///
/// Events are created when users interact with dashboard controls.
/// Each event type corresponds to a specific control interaction.
enum EventType {
  /// Button press event - triggered when a button control is tapped
  buttonPress,

  /// Toggle change event - triggered when a toggle control state changes
  toggleChange,

  /// Slider change event - triggered when a slider control value changes
  sliderChange,

  /// Input submit event - triggered when text input is submitted
  inputSubmit,

  /// Dropdown select event - triggered when a dropdown option is selected
  dropdownSelect;

  /// Returns a human-readable label for the event type
  String get label {
    switch (this) {
      case EventType.buttonPress:
        return 'Button Press';
      case EventType.toggleChange:
        return 'Toggle Change';
      case EventType.sliderChange:
        return 'Slider Change';
      case EventType.inputSubmit:
        return 'Input Submit';
      case EventType.dropdownSelect:
        return 'Dropdown Select';
    }
  }

  /// Returns the string representation used in API calls
  String get value {
    switch (this) {
      case EventType.buttonPress:
        return 'button_press';
      case EventType.toggleChange:
        return 'toggle_change';
      case EventType.sliderChange:
        return 'slider_change';
      case EventType.inputSubmit:
        return 'input_submit';
      case EventType.dropdownSelect:
        return 'dropdown_select';
    }
  }

  /// Creates an EventType from a string value
  ///
  /// The comparison uses underscore-separated values (e.g., 'button_press').
  /// Returns null if the string doesn't match any event type.
  static EventType? fromString(String value) {
    switch (value) {
      case 'button_press':
        return EventType.buttonPress;
      case 'toggle_change':
        return EventType.toggleChange;
      case 'slider_change':
        return EventType.sliderChange;
      case 'input_submit':
        return EventType.inputSubmit;
      case 'dropdown_select':
        return EventType.dropdownSelect;
      default:
        return null;
    }
  }
}
