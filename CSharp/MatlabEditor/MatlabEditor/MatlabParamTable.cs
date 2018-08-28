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
    public partial class MatlabParamTable : UserControl
    {
        /// <summary>
        /// Changing the matalb param table.
        /// </summary>
        public MatlabParamTable()
        {
            InitializeComponent();
            tblParams.CellValueChanged += (s, e) =>
            {
                if (Changed != null)
                    Changed(this, e);
            };
        }

        /// <summary>
        /// When value was changed.
        /// </summary>
        public event EventHandler Changed;

        /// <summary>
        /// The collection matlab name.
        /// </summary>
        public string CollectionName { get; set; } = "params";

        /// <summary>
        /// Creates the collection in the eval.
        /// </summary>
        public bool CreateCollection { get; private set; } = true;

        /// <summary>
        /// Called from a value changed event.
        /// </summary>
        /// <returns></returns>
        public Dictionary<string, string> ToDictionary()
        {
            return tblParams.Rows.Cast<DataGridViewRow>().ToDictionary<DataGridViewRow, string, string>(
                r => r.Cells[0].Value as string, r => r.Cells[1].Value as string);
        }

        /// <summary>
        /// Evaluate to string.
        /// </summary>
        /// <returns></returns>
        public string getEvalCode()
        {
            StringBuilder builder = new StringBuilder();

            if (CreateCollection)
                builder.Append(CollectionName + " = struct();");

            foreach (DataGridViewRow r in tblParams.Rows)
            {
                string name = r.Cells[0].Value as string;
                string val = r.Cells[1].Value as string;
                builder.Append(CollectionName + ".(genvarname('" + name + "'))=" + val + ";");
            }

            return builder.ToString();
        }
    }
}
