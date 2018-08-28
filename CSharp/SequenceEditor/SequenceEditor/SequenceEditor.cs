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

            tvMain.AfterSelect += TvMain_AfterSelect;
        }

        private void TvMain_AfterSelect(object sender, TreeViewEventArgs e)
        {
            // Called when the node element was selected.
            if (e.Node is SequenceNode && SequenceSelected != null)
            {
                SequenceSelected(this, e);
            }
        }

        #region Parmeters

        /// <summary>
        /// The sequence json object for this editor.
        /// </summary>
        public JsonSequence Sequence { get; private set; } = null;

        /// <summary>
        /// The paramters root.
        /// </summary>
        public TreeNode NodeParameters { get { return this.tvMain.Nodes["Parameters"]; } }

        /// <summary>
        /// The sequence root.
        /// </summary>
        public TreeNode NodeSequence { get { return this.tvMain.Nodes["Sequence"]; } }

        /// <summary>
        /// The currrent selected sequence node (if selected).
        /// </summary>
        public SequenceNode Selected { get { return tvMain.SelectedNode as SequenceNode; } }

        #endregion

        #region events

        /// <summary>
        /// Called when a diffrent sequence is selected. 
        /// </summary>
        public event EventHandler SequenceSelected;

        #endregion

        #region methods

        /// <summary>
        /// Called to load a sequence ito the editor.
        /// </summary>
        /// <param name="sq"></param>
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
