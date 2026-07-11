using Chess.Consts;
using Godot;
using System;
using System.Diagnostics;
using System.Runtime.CompilerServices;
// enums
public partial class UIManager : Control {
	// consts
	// exports
	// signals
	[Signal]
	public delegate void MenuStateChangedEventHandler();
	// public vars
	// private vars
	private Label TurnAmountLabel;
	private Label ColorLabel;
	private Label FiftyMoveRuleLabel;
	private CenterContainer EscMenu;
	private CenterContainer LoseMenu;
	// onready vars
	// built-in override methods
	public override void _Ready() {
		TurnAmountLabel = GetNode<Label>("IngameUI/PanelContainer/BoxContainer/TurnAmount/PanelContainer/BoxContainer/Value");
		ColorLabel = GetNode<Label>("IngameUI/PanelContainer/BoxContainer/ColorMove/PanelContainer/BoxContainer/Value");
		FiftyMoveRuleLabel = GetNode<Label>("IngameUI/PanelContainer/BoxContainer/FiftyMoveRule/PanelContainer/BoxContainer/Value");

		EscMenu = GetNode<CenterContainer>("EscMenu");
		LoseMenu = GetNode<CenterContainer>("LoseMenu");

	}
	public override void _Process(double delta) {

	}
	public void _OnContinuePressed(CenterContainer Source) {
		GD.Print("Continue Pressed");
		Source.Hide();
		CheckIfMenuOpen();
	}
	public void _OnRestartPressed(CenterContainer Source) {
		GD.Print("Restart Pressed");
		GetTree().ReloadCurrentScene();
	}
	public void _OnOptionsPressed(CenterContainer Source) {
		GD.Print("Options Pressed");
	}
	public void _OnMainMenuPressed(CenterContainer Source) {
		GD.Print("Main Menu Pressed");
	}
	public void _OnQuitPressed() {
		GD.Print("Quit Pressed");
		GetTree().Quit();
	}
	// public methods
	public void ToggleEscMenu() {
		if (LoseMenu.IsVisibleInTree()) {
			return;
		}
		if (EscMenu.IsVisibleInTree()) {
			EscMenu.Hide();
		} else {
			EscMenu.Show();
		}
		CheckIfMenuOpen();
	}
	public void ToggleLoseMenu() {
		if (LoseMenu.IsVisibleInTree()) {
			LoseMenu.Hide();
		} else {
			LoseMenu.Show();
		}
		CheckIfMenuOpen();
	}
	public void CheckIfMenuOpen() {
		bool IsMenuOpen = EscMenu.IsVisibleInTree() || LoseMenu.IsVisibleInTree();
		EmitSignal(SignalName.MenuStateChanged, IsMenuOpen);
	}
	public void SetLabels(int[] Values) {
		TurnAmountLabel.Text = Values[0].ToString();
		ColorLabel.Text = Enum.GetName(typeof(Piece.Color), Values[1]);
		FiftyMoveRuleLabel.Text = Values[2].ToString();
	}
	// private methods
}
