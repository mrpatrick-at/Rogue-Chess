using Godot;
using System;
// enums
public partial class UIMenu : CenterContainer {
	// consts
	// exports
	// signals
	[Signal]
	public delegate void ContinuePressedEventHandler();
	[Signal]
	public delegate void RestartPressedEventHandler();
	[Signal]
	public delegate void OptionsPressedEventHandler();
	[Signal]
	public delegate void MainMenuPressedEventHandler();
	[Signal]
	public delegate void QuitPressedEventHandler();
	// public vars
	// private vars
	// onready vars
	// built-in override methods
	public override void _Ready() {
	}
	public override void _Process(double delta) {

	}
	public void _OnContinuePressed() {
		EmitSignal(SignalName.ContinuePressed, this);
	}
	public void _OnRestartPressed() {
		EmitSignal(SignalName.RestartPressed, this);
	}
	public void _OnOptionsPressed() {
		EmitSignal(SignalName.OptionsPressed, this);
	}
	public void _OnMainMenuPressed() {
		EmitSignal(SignalName.MainMenuPressed, this);
	}
	public void _OnQuitPressed() {
		EmitSignal(SignalName.QuitPressed);
	}

	// public methods

	// private methods
}
