using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SequenceEditor
{
    public partial class SequenceEditor : UserControl
    {
        public SequenceEditor()
        {
            InitializeComponent();
        }

        #region Parmeters

        public JsonSequence Sequence { get; private set; } = null;

        public TreeNode NodeParameters { get { return this.tvMain.Nodes["Parameters"]; } }
        public TreeNode NodeSequence { get { return this.tvMain.Nodes["Sequence"]; } }

        #endregion

        #region methods

        public void LoadSequence(JsonSequence sq)
        {
            Sequence = sq;
            int idx = -1;
            if (this.tvMain.Nodes.ContainsKey("Sequence"))
            {
                idx = this.tvMain.Nodes.IndexOfKey("Sequence");
                this.tvMain.Nodes.RemoveByKey("Sequence");
            }

            SequenceNode node = new SequenceNode(this, new int[] { });
            node.Name = "Sequence";
            if (idx > -1)
                this.tvMain.Nodes.Insert(idx, node);
            else this.tvMain.Nodes.Add(node);
        }

        #endregion
    }
}
