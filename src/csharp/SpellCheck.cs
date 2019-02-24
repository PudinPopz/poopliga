using Godot;
using System;
using NHunspell;

public class SpellCheck : Node
{
    public static void CheckString()
    {
        using (var hunspell = new Hunspell("en_us.aff", "en_us.dic"))
        {
            foreach (var item in hunspell.Suggest(" "))
            {
                GD.Print(item);
            }
			
        }
    }
}
