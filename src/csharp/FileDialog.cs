using Godot;
using System;
using System.Windows;
using System.Windows.Forms;

public class FileDialog : Node
{

	public override void _Ready()
	{

	}

	[STAThread]
	public static string OpenFileDialog()
	{
		// Try catch blocks seem to reduce the likelihood of crashing.
		try
		{
			var openFileDialog = new OpenFileDialog
			{
				InitialDirectory = "",
				Filter = "Poopliga files (*.poopliga, *.ppga, *.json)|*.poopliga;*.ppga;*.json|All files (*.*)|*.*",
				FilterIndex = 1,
				RestoreDirectory = false
			};

			var result = openFileDialog.ShowDialog();
			if (result == DialogResult.OK)
			{
				var path = openFileDialog.FileName;
				return path;
			}
		}
		catch
		{
			return null;
		}

		return null;
	}

	[STAThread]
	public static string SaveFileDialog()
	{
		// Try catch blocks seem to reduce the likelihood of crashing.
		try
		{
			var saveFileDialog = new SaveFileDialog
			{
				InitialDirectory = "",
				Filter = "Poopliga files (*.poopliga, *.ppga, *.json)|*.poopliga;*.ppga;*.json|All files (*.*)|*.*",
				FilterIndex = 1,
				RestoreDirectory = false
			};

			var result = saveFileDialog.ShowDialog();
			if (result == DialogResult.OK)
			{
				var path = saveFileDialog.FileName;
				return path;
			}
		}
		catch
		{
			return null;
		}

		return null;
	}

}