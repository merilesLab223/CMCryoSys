using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MatlabEditor
{
    /// <summary>
    /// Implements a sequence editor that allows for the generation of sequence code. And the json sequence representation.
    /// </summary>
    public partial class SequenceEditor : UserControl
    {
        public SequenceEditor()
        {
            InitializeComponent();
        }

        #region members

        /// <summary>
        /// The sequence associated with the editor.
        /// </summary>
        public Sequence Sequence { get; private set; } = new Sequence();

        #endregion

        #region Loading methods

        /// <summary>
        /// Loads the sequence from a file.
        /// </summary>
        /// <param name="path"></param>
        public void LoadSeqeunce(string path)
        {
            if (!System.IO.File.Exists(path))
                throw new Exception("File dose not exist.");

            string json = System.IO.File.ReadAllText(path);
            Sequence = Newtonsoft.Json.JsonConvert.DeserializeObject<Sequence>(json);
        }

        /// <summary>
        /// Saves the seqeunce to a file.
        /// </summary>
        /// <param name="filename"></param>
        public void SaveSequence(string filename)
        {
        }

        #endregion
    }
}
