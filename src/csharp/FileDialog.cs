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

    public static string OpenFileDialog()
    {
        var openFileDialog = new OpenFileDialog
        {
            InitialDirectory = "C:/Users/jamie/Desktop/",
            Filter = "Poopliga files (*.poopliga, *.ppga, *.json)|*.poopliga;*.ppga;*.json|All files (*.*)|*.*",
            FilterIndex = 1,
            RestoreDirectory = false
        };


        if (openFileDialog.ShowDialog() == DialogResult.OK)
        {
            var path = openFileDialog.FileName;
            return path;
        }

        return null;
    }
    
    public static string SaveFileDialog()
    {
        var saveFileDialog = new SaveFileDialog
        {
            InitialDirectory = "C:/Users/jamie/Desktop/",
            Filter = "Poopliga files (*.poopliga, *.ppga, *.json)|*.poopliga;*.ppga;*.json|All files (*.*)|*.*",
            FilterIndex = 1,
            RestoreDirectory = false
        };


        if (saveFileDialog.ShowDialog() == DialogResult.OK)
        {
            var path = saveFileDialog.FileName;
            return path;
        }

        return null;
    }

//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
}