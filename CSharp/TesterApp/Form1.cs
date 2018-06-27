using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TesterApp
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void btnTestSaveSequence_Click(object sender, EventArgs e)
        {
            SequenceEditor.JsonSequence sequence = new SequenceEditor.JsonSequence();
            sequence.Name = "lama";
            int n = 5;
            int lvl = 5;
            populateTestSqeuence(sequence, n, lvl);

            string json = Newtonsoft.Json.JsonConvert.SerializeObject(sequence, Newtonsoft.Json.Formatting.Indented);

            sqEditor.LoadSequence(sequence);
        }

        void populateTestSqeuence(SequenceEditor.JsonSequence sq, int n, int lvlsLeft = 0)
        {
            for (int i = 0; i < n; i++)
            {
                SequenceEditor.JsonSequence intern = new SequenceEditor.JsonSequence();
                intern.Name = "Internal Sequence " + lvlsLeft+"."+ i;
                if(lvlsLeft>0)
                {
                    populateTestSqeuence(intern, n, lvlsLeft - 1);
                }
                sq.InternalSequences.Add(intern);
            }

        }
    }
}
