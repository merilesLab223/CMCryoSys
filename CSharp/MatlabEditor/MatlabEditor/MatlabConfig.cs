using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MatlabEditor
{
    /// <summary>
    /// Holds information about the current matlab editor configuration.
    /// </summary>
    public class MatlabConfig
    {
        /// <summary>
        /// A list of the auto complete words.
        /// </summary>
        public List<string> AutoCompleteWords { get; private set; } = new List<string>();

        /// <summary>
        /// Returns the key words to show.
        /// </summary>
        public string KeyWordsString
        {
            get
            {
                return string.Join(" ", ConfigGenerators.MatlabConfigGenerator.MatlabKeyWords.Intersect(AutoCompleteWords));
            }
        }
    }
}
