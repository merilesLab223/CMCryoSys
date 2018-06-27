using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Newtonsoft.Json;

namespace SequenceEditor
{
    public class SequenceNode : TreeNode
    {
        public SequenceNode(SequenceEditor editor, int[] pathIndexs)
        {
            Editor = editor;
            PathIndexs = pathIndexs;
            UpdateSequenceInfo();
        }

        #region members

        /// <summary>
        /// the editor.
        /// </summary>
        public SequenceEditor Editor { get; private set; }

        /// <summary>
        /// The indexs to the sequence path.
        /// </summary>
        public int[] PathIndexs { get; private set; }

        /// <summary>
        /// The json sequence associated with the node.
        /// </summary>
        public JsonSequence Sequence
        {
            get
            {
                JsonSequence sqnce = Editor.Sequence;
                foreach (var idx in PathIndexs)
                {
                    if (sqnce == null)
                        break;
                    if (sqnce.InternalSequences.Count <= idx)
                    {
                        sqnce = null;
                        break;
                    }
                    sqnce = sqnce.InternalSequences[idx];
                }

                return sqnce;
            }
        }

        #endregion

        #region display methods

        public void UpdateSequenceInfo()
        {
            JsonSequence sq = Sequence;
            if (sq == null)
                return;

            this.Name = sq.Name;
            this.Text = sq.Name;
            int imgIdx= PathIndexs.Length == 0 ? 2 : 3;

            this.ImageIndex = imgIdx;
            this.StateImageIndex = imgIdx;
            this.SelectedImageIndex= imgIdx;

            this.Nodes.Clear();
            for (int i = 0; i < Sequence.InternalSequences.Count; i++)
            {
                this.Nodes.Add(new SequenceNode(Editor, PathIndexs.Concat(new int[] { i }).ToArray()));
            }
        }

        #endregion
    }
}
