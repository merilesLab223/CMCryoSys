namespace MatlabEditor
{
    partial class SequenceEditor
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.Parameters = new MatlabEditor.MatlabParamTable();
            this.Editor = new MatlabEditor.MEditor();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.FixedPanel = System.Windows.Forms.FixedPanel.Panel1;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.Parameters);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.Editor);
            this.splitContainer1.Size = new System.Drawing.Size(808, 499);
            this.splitContainer1.SplitterDistance = 366;
            this.splitContainer1.TabIndex = 0;
            // 
            // Parameters
            // 
            this.Parameters.Dock = System.Windows.Forms.DockStyle.Fill;
            this.Parameters.Location = new System.Drawing.Point(0, 0);
            this.Parameters.Name = "Parameters";
            this.Parameters.Size = new System.Drawing.Size(366, 499);
            this.Parameters.TabIndex = 0;
            // 
            // Editor
            // 
            this.Editor.Dock = System.Windows.Forms.DockStyle.Fill;
            this.Editor.Location = new System.Drawing.Point(0, 0);
            this.Editor.Name = "Editor";
            this.Editor.Size = new System.Drawing.Size(438, 499);
            this.Editor.TabIndex = 0;
            this.Editor.Text = "";
            // 
            // SequenceEditor
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.splitContainer1);
            this.Name = "SequenceEditor";
            this.Size = new System.Drawing.Size(808, 499);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        public MatlabParamTable Parameters;
        public MEditor Editor;
    }
}
