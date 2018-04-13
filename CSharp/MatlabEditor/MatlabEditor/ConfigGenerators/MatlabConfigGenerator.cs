using ScintillaNET;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MatlabEditor.ConfigGenerators
{
    public static class MatlabConfigGenerator
    {
        public static void Configure(Scintilla editor)
        {
            // Default configuration values.
            editor.Lexer = (Lexer)Matlab_LexerLang;
            InitSyntaxColoring(editor);
            InitNumberMargin(editor);
            InitCodeFolding(editor);
            InitAutoComplete(editor);
            InitHotkeys(editor);
        }

        #region Syntax coloring

        static void SetTextStyle(Scintilla editor, MatlabLexerConfig t, Color c, bool isbold = false, bool isItalic = false)
        {
            SetTextStyle(editor,(int)t, c, isbold, isItalic);
        }

        static void SetTextStyle(Scintilla editor, int t, Color c, bool isbold = false, bool isItalic = false)
        {
            editor.Styles[t].ForeColor = c;
            editor.Styles[t].Italic = isItalic;
            editor.Styles[t].Bold = isbold;
        }

        static private void InitSyntaxColoring(Scintilla editor)
        {
            editor.StyleResetDefault();

            SetTextStyle(editor,MatlabLexerConfig.DEFAULT, Color.DarkGray);
            SetTextStyle(editor,MatlabLexerConfig.COMMENT, Color.Green);
            SetTextStyle(editor,MatlabLexerConfig.NUMBER, Color.Red);
            SetTextStyle(editor,MatlabLexerConfig.STRING, Color.Purple);
            SetTextStyle(editor,MatlabLexerConfig.DOUBLEQUOTESTRING, Color.Purple);

            SetTextStyle(editor,MatlabLexerConfig.KEYWORD, Color.Blue);

            SetTextStyle(editor,MatlabLexerConfig.OPERATOR, Color.DarkCyan);
            SetTextStyle(editor,MatlabLexerConfig.COMMAND, Color.Gold);

            editor.SetKeywords(0, string.Join(" ", MatlabKeyWords));
        }

        #endregion

        #region Numbers, Bookmarks, Code Folding

        /// <summary>
        /// the background color of the text area
        /// </summary>
        private const int BACK_COLOR = 0x2A211C;

        /// <summary>
        /// default text color of the text area
        /// </summary>
        private const int FORE_COLOR = 0xB7B7B7;

        /// <summary>
        /// change this to whatever margin you want the line numbers to show in
        /// </summary>
        private const int NUMBER_MARGIN = 1;

        /// <summary>
        /// change this to whatever margin you want the bookmarks/breakpoints to show in
        /// </summary>
        private const int BOOKMARK_MARGIN = 2;
        private const int BOOKMARK_MARKER = 2;

        /// <summary>
        /// change this to whatever margin you want the code folding tree (+/-) to show in
        /// </summary>
        private const int FOLDING_MARGIN = 3;

        /// <summary>
        /// set this true to show circular buttons for code folding (the [+] and [-] buttons on the margin)
        /// </summary>
        private const bool CODEFOLDING_CIRCULAR = false;

        static private void InitNumberMargin(Scintilla editor)
        {

            editor.Styles[Style.LineNumber].BackColor = IntToColor(BACK_COLOR);
            editor.Styles[Style.LineNumber].ForeColor = IntToColor(FORE_COLOR);
            editor.Styles[Style.IndentGuide].ForeColor = IntToColor(FORE_COLOR);
            editor.Styles[Style.IndentGuide].BackColor = IntToColor(BACK_COLOR);

            var nums = editor.Margins[NUMBER_MARGIN];
            nums.Width = 30;
            nums.Type = MarginType.Number;
            nums.Sensitive = true;
            nums.Mask = 0;

            editor.MarginClick += editor_MarginClick;
        }

        static private void InitBookmarkMargin(Scintilla editor)
        {
            var margin = editor.Margins[BOOKMARK_MARGIN];
            margin.Width = 20;
            margin.Sensitive = true;
            margin.Type = MarginType.Symbol;
            margin.Mask = (1 << BOOKMARK_MARKER);

            var marker = editor.Markers[BOOKMARK_MARKER];
            marker.Symbol = MarkerSymbol.Circle;
            marker.SetBackColor(IntToColor(0xFF003B));
            marker.SetForeColor(IntToColor(0x000000));
            marker.SetAlpha(100);
        }

        static private void InitCodeFolding(Scintilla editor)
        {
            // Enable code folding
            editor.SetProperty("fold", "1");
            editor.SetProperty("fold.compact", "1");

            // Configure a margin to display folding symbols
            editor.IndentWidth = 5;

            editor.WrapIndentMode = WrapIndentMode.Indent;
            editor.IndentationGuides = IndentView.LookBoth;
            editor.WrapStartIndent = 5;

            editor.Margins[FOLDING_MARGIN].Type = MarginType.Symbol;
            editor.Margins[FOLDING_MARGIN].Mask = Marker.MaskAll;
            editor.Margins[FOLDING_MARGIN].Sensitive = true;
            editor.Margins[FOLDING_MARGIN].Width = 20;

            editor.InsertCheck += editor_InsertCheck;

            // Configure folding markers with respective symbols
            editor.Markers[Marker.Folder].Symbol = CODEFOLDING_CIRCULAR ? MarkerSymbol.CirclePlus : MarkerSymbol.BoxPlus;
            editor.Markers[Marker.FolderOpen].Symbol = CODEFOLDING_CIRCULAR ? MarkerSymbol.CircleMinus : MarkerSymbol.BoxMinus;
            editor.Markers[Marker.FolderEnd].Symbol = CODEFOLDING_CIRCULAR ? MarkerSymbol.CirclePlusConnected : MarkerSymbol.BoxPlusConnected;
            editor.Markers[Marker.FolderMidTail].Symbol = MarkerSymbol.TCorner;
            editor.Markers[Marker.FolderOpenMid].Symbol = CODEFOLDING_CIRCULAR ? MarkerSymbol.CircleMinusConnected : MarkerSymbol.BoxMinusConnected;
            editor.Markers[Marker.FolderSub].Symbol = MarkerSymbol.VLine;
            editor.Markers[Marker.FolderTail].Symbol = MarkerSymbol.LCorner;

            // Enable automatic folding
            editor.AutomaticFold = (AutomaticFold.Show | AutomaticFold.Click | AutomaticFold.Change);
        }

        static private void editor_InsertCheck(object sender, InsertCheckEventArgs e)
        {
            Scintilla editor = (Scintilla)sender;
            if ((e.Text.EndsWith("\r") || e.Text.EndsWith("\n")))
            {
                var curLine = editor.LineFromPosition(e.Position);
                var curLineText = editor.Lines[curLine].Text;

                var indent = System.Text.RegularExpressions.Regex.Match(curLineText, @"^\s*");
                e.Text += indent.Value; // Add indent following "\r\n"

                // Current line end with bracket?
                if (System.Text.RegularExpressions.Regex.IsMatch(curLineText, @"{\s*$"))
                    e.Text += '\t'; // Add tab
            }
        }

        static private void editor_MarginClick(object sender, MarginClickEventArgs e)
        {
            Scintilla editor = (Scintilla)sender;
            if (e.Margin == BOOKMARK_MARGIN)
            {
                // Do we have a marker for this line?
                const uint mask = (1 << BOOKMARK_MARKER);
                var line = editor.Lines[editor.LineFromPosition(e.Position)];
                if ((line.MarkerGet() & mask) > 0)
                {
                    // Remove existing bookmark
                    line.MarkerDelete(BOOKMARK_MARKER);
                }
                else
                {
                    // Add bookmark
                    line.MarkerAdd(BOOKMARK_MARKER);
                }
            }
        }

        #endregion

        #region AutoComplete

        static void InitAutoComplete(Scintilla editor)
        {
            editor.CharAdded += editor_CharAdded1;
        }

        static private void editor_CharAdded1(object sender, CharAddedEventArgs e)
        {
            Scintilla editor = (Scintilla)sender;

            // Find the word start
            var currentPos = editor.CurrentPosition;
            var wordStartPos = editor.WordStartPosition(currentPos, true);

            // Display the autocompletion list
            var lenEntered = currentPos - wordStartPos;
            if (lenEntered > 0)
            {
                if (!editor.AutoCActive)
                    editor.AutoCShow(lenEntered,
                        String.Join(" ",MatlabKeyWords));
                // "abstract as base break case catch checked continue default delegate do else event explicit extern false finally fixed for foreach goto if implicit in interface internal is lock namespace new null object operator out override params private protected public readonly ref return sealed sizeof stackalloc switch this throw true try typeof unchecked unsafe using virtual while");
            }
        }

        #endregion

        #region keys config

        private static void InitHotkeys(Scintilla editor)
        {

            // register the hotkeys with the form
            //HotKeyManager.AddHotKey(this, OpenSearch, Keys.F, true);
            //HotKeyManager.AddHotKey(this, OpenFindDialog, Keys.F, true, false, true);
            //HotKeyManager.AddHotKey(this, OpenReplaceDialog, Keys.R, true);
            //HotKeyManager.AddHotKey(this, OpenReplaceDialog, Keys.H, true);
            //HotKeyManager.AddHotKey(this, Uppercase, Keys.U, true);
            //HotKeyManager.AddHotKey(this, Lowercase, Keys.L, true);
            //HotKeyManager.AddHotKey(this, ZoomIn, Keys.Oemplus, true);
            //HotKeyManager.AddHotKey(this, ZoomOut, Keys.OemMinus, true);
            //HotKeyManager.AddHotKey(this, ZoomDefault, Keys.D0, true);
            //HotKeyManager.AddHotKey(this, CloseSearch, Keys.Escape);

            // remove conflicting hotkeys from scintilla
            editor.ClearCmdKey(Keys.Control | Keys.S);
            editor.ClearCmdKey(Keys.Control | Keys.F);
            editor.ClearCmdKey(Keys.Control | Keys.R);
            editor.ClearCmdKey(Keys.Control | Keys.H);
            editor.ClearCmdKey(Keys.Control | Keys.L);
            editor.ClearCmdKey(Keys.Control | Keys.U);

        }

        #endregion

        #region Helpers

        public static Color IntToColor(int rgb)
        {
            return Color.FromArgb(255, (byte)(rgb >> 16), (byte)(rgb >> 8), (byte)rgb);
        }

        #endregion

        #region Definitions

        public const int Matlab_LexerLang = 32;

        public enum MatlabLexerConfig
        {
            DEFAULT = 0,
            COMMENT = 1,
            COMMAND = 2,
            NUMBER = 3,
            KEYWORD = 4,
            STRING = 5,
            OPERATOR = 6,
            IDENTIFIER = 7,
            DOUBLEQUOTESTRING = 8,
        }

        public static string[] MatlabKeyWords = {
                "break" ,
                "case" ,
                "catch" ,
                "classdef" ,
                "continue" ,
                "else" ,
                "elseif" ,
                "end" ,
                "for" ,
                "function" ,
                "global" ,
                "if" ,
                "otherwise" ,
                "parfor" ,
                "persistent" ,
                "return" ,
                "spmd" ,
                "switch" ,
                "try" ,
                "methods",
                "properties",
                "while"
        };

        #endregion
    }
}
