import 'package:flutter/material.dart';

/// Manages form state and validation
class FormState {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _errors = {};
  bool _isSubmitting = false;

  /// Get or create a text controller for a field
  TextEditingController getController(String fieldName) {
    return _controllers.putIfAbsent(
      fieldName,
      () => TextEditingController(),
    );
  }

  /// Get error for a field
  String? getError(String fieldName) {
    return _errors[fieldName];
  }

  /// Set error for a field
  void setError(String fieldName, String? error) {
    _errors[fieldName] = error;
  }

  /// Clear all errors
  void clearErrors() {
    _errors.clear();
  }

  /// Clear a specific field error
  void clearError(String fieldName) {
    _errors.remove(fieldName);
  }

  /// Get all form values
  Map<String, String> getFormValues() {
    final values = <String, String>{};
    _controllers.forEach((key, controller) {
      values[key] = controller.text;
    });
    return values;
  }

  /// Set form value
  void setValue(String fieldName, String value) {
    getController(fieldName).text = value;
  }

  /// Check if form is valid
  bool isValid() {
    return _errors.values.every((error) => error == null);
  }

  /// Check if form is submitting
  bool get isSubmitting => _isSubmitting;

  /// Set submitting state
  void setSubmitting(bool value) {
    _isSubmitting = value;
  }

  /// Reset form
  void reset() {
    _controllers.forEach((_, controller) {
      controller.clear();
    });
    clearErrors();
    _isSubmitting = false;
  }

  /// Dispose all controllers
  void dispose() {
    _controllers.forEach((_, controller) {
      controller.dispose();
    });
    _controllers.clear();
    _errors.clear();
  }
}
