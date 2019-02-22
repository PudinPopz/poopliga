using Godot;
using System;
using System.Windows;
using System.Windows.Forms;

public class FileDialog : Node
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";

    // Called when the node enters the scene tree for the first time.
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
                InitialDirectory = "C:/Users/jamie/Desktop/",
                Filter = "Poopliga files (*.poopliga, *.ppga, *.json)|*.poopliga;*.ppga;*.json|All files (*.*)|*.*",
                FilterIndex = 1,
                //ShowHelp = true,
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
                InitialDirectory = "C:/Users/jamie/Desktop/",
                Filter = "Poopliga files (*.poopliga, *.ppga, *.json)|*.poopliga;*.ppga;*.json|All files (*.*)|*.*",
                FilterIndex = 1,
                //ShowHelp = true,
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

//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
}