using System.Threading.Tasks;
using Godot;
using NHunspell;
using Godot.Collections;
using Control = Godot.Control;
using Object = Godot.Object;

// ReSharper disable ParameterTypeCanBeEnumerable.Global

// For performance testing with stopwatches

public class SpellCheck : Node
{
    [Signal]
    public delegate void SuggestionComplete();

    private static SpellCheck instance = new SpellCheck();

    private static readonly Hunspell Hunspell = new Hunspell("en_UK.aff", "en_UK.dic");

    private static bool _realtimeEnabled = true;

    private static string _currentWordForSuggestions = "";
    private static Array<string> _currentSuggestions = new Array<string>();

    private static Dictionary _ignoredWordsEditor = new Dictionary();
    private static Dictionary _ignoredWordsProject = new Dictionary();

    public class SpellCheckResult : Object
    {
        public readonly Control Block;
        public readonly int Index;
        public readonly string Word;

        public SpellCheckResult(Control block, int index, string word)
        {
            Block = block;
            Index = index;
            Word = word;
        }
    }

    public static void WarmUp()
    {
        for (var i = 0; i < 10; i++)
        {
            CheckString("According to all known laws of aviation, there is no way a bee should be able to fly.");
            CheckString(
                "Accorfding toa alal knfown lawzs owf aviatiaon, theare izs nno wway aa baee shouald bae ablae.");

            var test = CheckString("Thiz!  uwu iz sum? texxt tu vwarm upp da spiell chkear und makeed ita gud. :)");
            var spellCheckResult = new SpellCheckResult(new Control(), 8, "bepis");
            CheckBlocks(new Array<Control>());
        }
    }

    // Checks the TextEdits of the provided set of Dialogue Blocks for spelling errors.
    // Returns a Dictionary in the form {id : {index : word}}
    public static Array<SpellCheckResult> CheckBlocks(Array<Control> blocks)
    {
        var outputArr = new Array<SpellCheckResult>();
        foreach (var block in blocks)
        {
            var textEdit = (TextEdit) block.Get("dialogue_line_edit");
            var spellingErrors = CheckString(textEdit.Text);
            if (spellingErrors.Count > 0)
            {
                foreach (var indexWordPair in spellingErrors)
                {
                    var spellCheckResult = new SpellCheckResult(block, indexWordPair.Key, indexWordPair.Value);
                    // Add if block id isn't ignored by project settings
                    if (!_ignoredWordsProject.ContainsKey('"' + block.Name + '"'))
                        outputArr.Add(spellCheckResult);
                }
            }
        }

        return outputArr;
    }


    // Checks a given string for spelling errors.
    // Returns a Dictionary in the form {index : word}
    public static Godot.Collections.Dictionary<int, string> CheckString(string input)
    {
        var outputDict = new Godot.Collections.Dictionary<int, string>();

        // For each character
        var currentWord = "";
        for (var i = 0; i < input.Length; i++)
        {
            var currentChar = input[i];

            // If at a space character or final character, current word is complete.
            var isLastCharacter = i >= input.Length - 1;

            if ((!char.IsLetterOrDigit(currentChar) && currentChar != '-' && currentChar != '\'') || isLastCharacter)
            {
                if (isLastCharacter && char.IsLetterOrDigit(currentChar))
                    currentWord += currentChar;

                Hunspell.Spell(currentWord);

                // If word has incorrect spelling, add index and word to dictionary.
                if (!IsWordCorrect(currentWord))
                    outputDict.Add(i, currentWord);


                // Clear and move onto next word
                currentWord = "";

                continue;
            }

            currentWord += currentChar;
        }

        return outputDict;
    }

    private static bool IsWordCorrect(string word)
    {
        // Initial check of word in raw state
        if (Hunspell.Spell(word)) return true;

        // Strip trailing hyphen
        if (word.EndsWith("-"))
            word = word.Remove(word.Length - 1, 1);

        // If in ignored words dictionary, return true
        if (_ignoredWordsEditor.ContainsKey(word.ToLower()) || _ignoredWordsProject.ContainsKey(word.ToLower()))
            return true;

        // If still returning a spelling mistake after cleanup
        if (Hunspell.Spell(word) == false)
        {
            // Strip trailing 's' to allow plural acronyms
            if (word.EndsWith("s"))
                word = word.Remove(word.Length - 1, 1);


            // Ignore if word is all caps
            if (word == word.ToUpper())
                return true;

            return false;
        }

        return true;
    }

    private static Array<string> GetSuggestions(string word)
    {
        var outputArr = new Array<string>();

        foreach (var suggestion in Hunspell.Suggest(word))
        {
            outputArr.Add(suggestion);
        }

        return outputArr;
    }

    private static async void UpdateSuggestions()
    {
        await Task.Run(() => { _currentSuggestions = GetSuggestions(_currentWordForSuggestions); });

        instance.EmitSignal(nameof(SuggestionComplete));
    }

    public static async void RunSuggestionThread(string word)
    {
        _currentWordForSuggestions = word;
        UpdateSuggestions();
    }

    private static void SetIgnoredWordsEditor(Dictionary dict)
    {
        _ignoredWordsEditor = dict;
    }

    private static void SetIgnoredWordsProject(Dictionary dict)
    {
        _ignoredWordsProject = dict;
    }

    private static void SetRealtimeEnabled(bool enabled)
    {
        _realtimeEnabled = enabled;
    }

    private static bool IsRealtimeEnabled()
    {
        return _realtimeEnabled;
    }

    public static SpellCheck GetInstance()
    {
        return instance;
    }

    public static Array<string> GetCurrentSuggestions()
    {
        return _currentSuggestions;
    }
}