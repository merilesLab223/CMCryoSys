using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace MatlabEditor
{
    /// <summary>
    /// Configuration file for MEditor
    /// </summary>
    public class MeditorConfig
    {
        public MeditorConfig()
        {
        }

        #region enums

        public enum AutoIndentType
        {
            /// <summary>
            /// No auto indent.
            /// </summary>
            None,
            /// <summary>
            /// Keep previous line indent.
            /// </summary>
            Simple,
        }

        #endregion

        #region configuration emembers.

        /// <summary>
        /// The lexer language in values.
        /// </summary>
        public int LexerLang { get; set; } = 1;

        /// <summary>
        /// The au
        /// </summary>
        public AutoIndentType AutoIndent { get; private set; } = AutoIndentType.Simple;

        /// <summary>
        /// A connection between colors and names. Replaces the connection between color styles and names.
        /// </summary>
        public Dictionary<string, ScintillaNET.Style> StyleByName { get; protected set; } = new Dictionary<string, ScintillaNET.Style>();

        /// <summary>
        /// Style by number. (Use only when unnamed.);
        /// </summary>
        public Dictionary<int, ScintillaNET.Style> Styles { get; protected set; } = new Dictionary<int, ScintillaNET.Style>();

        /// <summary>
        /// The map between names and styles for the config.
        /// </summary>
        public Dictionary<int, string> NamedStyles { get; protected set; } = new Dictionary<int, string>();

        #endregion

        #region GetterAndSetters


        #endregion

        #region conversion

        public static MeditorConfig FromFile(string fname)
        {
            return FromString(System.IO.File.ReadAllText(fname));
        }

        public static MeditorConfig FromString(string val)
        {
            return (MeditorConfig)JsonConvert.DeserializeObject(val, typeof(MeditorConfig));
        }

        public string ToJson(bool isPretty=true)
        {
            return JsonConvert.SerializeObject(this, isPretty? Formatting.Indented : Formatting.None);
        }

        public override string ToString()
        {
            return ToJson(false);
        }


        #endregion
    }
}
