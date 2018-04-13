using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using ScintillaNET;
using Newtonsoft.Json;

namespace MatlabEditor
{
    /// <summary>
    /// Editor UI clss for matlab.
    /// </summary>
    public class MEditor : UserControl
    {
        #region Contstruction

        public MEditor()
            : this(Configuration.Matlab)
        {
        }

        public MEditor(Configuration cnfg = Configuration.Matlab, bool AutoConfigure=true)
        {
            InitializeComponent();

            m_editor = new Scintilla();
            pannelEditor.Controls.Add(m_editor);
            m_editor.Dock = DockStyle.Fill;

            m_editor.TextChanged += M_editor_TextChanged;

            if (AutoConfigure)
                ConfigureEditor(cnfg);
        }

        #region Text editing

        private void M_editor_TextChanged(object sender, EventArgs e)
        {
            LastChanged = DateTime.Now;
            if (TextChanged != null)
                TextChanged(this, e);
        }

        /// <summary>
        /// Called when the text is changed.
        /// </summary>
        public event EventHandler TextChanged;

        #endregion

        #endregion

        #region Control members

        private Panel pannelEditor;
        Scintilla m_editor;

        /// <summary>
        /// The date when the control last changed.
        /// </summary>
        public DateTime LastChanged { get; private set; }

        /// <summary>
        /// Returns the text value for the control.
        /// </summary>
        public string Value { get { return m_editor.Text; } set { m_editor.Text = value; } }

        /// <summary>
        /// The editor;
        /// </summary>
        public Scintilla Editor { get => m_editor; }

        #endregion

        #region Editor Initialization;

        public void ConfigureEditor(Configuration cnfg)
        {
            switch(cnfg)
            {
                case Configuration.Matlab:
                    ConfigGenerators.MatlabConfigGenerator.Configure(m_editor);
                    break;
            }
        }

        #endregion

        #region Load configuration

        public enum Configuration
        {
            Matlab,
        }

        #endregion

        #region Components

        private void InitializeComponent()
        {
            this.pannelEditor = new System.Windows.Forms.Panel();
            this.SuspendLayout();
            // 
            // pannelEditor
            // 
            this.pannelEditor.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pannelEditor.Location = new System.Drawing.Point(0, 0);
            this.pannelEditor.Name = "pannelEditor";
            this.pannelEditor.Size = new System.Drawing.Size(423, 305);
            this.pannelEditor.TabIndex = 0;
            // 
            // MEditor
            // 
            this.Controls.Add(this.pannelEditor);
            this.Name = "MEditor";
            this.Size = new System.Drawing.Size(423, 305);
            this.ResumeLayout(false);

        }

        #endregion

    }
}
