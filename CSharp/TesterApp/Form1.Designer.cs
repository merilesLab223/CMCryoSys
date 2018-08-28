namespace TesterApp
{
    partial class Form1
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

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.btnTestSaveSequence = new System.Windows.Forms.Button();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.panel1 = new System.Windows.Forms.Panel();
            this.txtSequenceName = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.sqEditor = new SequenceEditor.SequenceEditor();
            this.mEditor1 = new MatlabEditor.MEditor();
            this.matlabParamTable1 = new MatlabEditor.MatlabParamTable();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnTestSaveSequence
            // 
            this.btnTestSaveSequence.Location = new System.Drawing.Point(3, 3);
            this.btnTestSaveSequence.Name = "btnTestSaveSequence";
            this.btnTestSaveSequence.Size = new System.Drawing.Size(270, 23);
            this.btnTestSaveSequence.TabIndex = 1;
            this.btnTestSaveSequence.Text = "Test Save Sequence";
            this.btnTestSaveSequence.UseVisualStyleBackColor = true;
            this.btnTestSaveSequence.Click += new System.EventHandler(this.btnTestSaveSequence_Click);
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.FixedPanel = System.Windows.Forms.FixedPanel.Panel1;
            this.splitContainer1.Location = new System.Drawing.Point(0, 29);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.sqEditor);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.matlabParamTable1);
            this.splitContainer1.Panel2.Controls.Add(this.label2);
            this.splitContainer1.Panel2.Controls.Add(this.mEditor1);
            this.splitContainer1.Panel2.Controls.Add(this.label4);
            this.splitContainer1.Panel2.Controls.Add(this.label1);
            this.splitContainer1.Panel2.Controls.Add(this.txtSequenceName);
            this.splitContainer1.Size = new System.Drawing.Size(1106, 466);
            this.splitContainer1.SplitterDistance = 368;
            this.splitContainer1.TabIndex = 2;
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.btnTestSaveSequence);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(1106, 29);
            this.panel1.TabIndex = 4;
            // 
            // txtSequenceName
            // 
            this.txtSequenceName.Location = new System.Drawing.Point(81, 33);
            this.txtSequenceName.Name = "txtSequenceName";
            this.txtSequenceName.Size = new System.Drawing.Size(351, 20);
            this.txtSequenceName.TabIndex = 0;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(26, 36);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(35, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Name";
            this.label1.Click += new System.EventHandler(this.label1_Click);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(26, 99);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(32, 13);
            this.label4.TabIndex = 7;
            this.label4.Text = "Code";
            // 
            // label2
            // 
            this.label2.Location = new System.Drawing.Point(78, 56);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(589, 40);
            this.label2.TabIndex = 9;
            this.label2.Text = "The code to execute. All internal node\'s code will be added after the text \"% [In" +
    "ternal_Node_Code]\" if it dose not appear then all internal node code will be add" +
    "ed at the end.";
            // 
            // sqEditor
            // 
            this.sqEditor.Dock = System.Windows.Forms.DockStyle.Fill;
            this.sqEditor.Location = new System.Drawing.Point(0, 0);
            this.sqEditor.Name = "sqEditor";
            this.sqEditor.Size = new System.Drawing.Size(368, 466);
            this.sqEditor.TabIndex = 0;
            // 
            // mEditor1
            // 
            this.mEditor1.Location = new System.Drawing.Point(81, 99);
            this.mEditor1.Name = "mEditor1";
            this.mEditor1.Size = new System.Drawing.Size(191, 355);
            this.mEditor1.TabIndex = 8;
            this.mEditor1.Value = "";
            // 
            // matlabParamTable1
            // 
            this.matlabParamTable1.Location = new System.Drawing.Point(371, 152);
            this.matlabParamTable1.Name = "matlabParamTable1";
            this.matlabParamTable1.Size = new System.Drawing.Size(296, 222);
            this.matlabParamTable1.TabIndex = 10;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1106, 495);
            this.Controls.Add(this.splitContainer1);
            this.Controls.Add(this.panel1);
            this.Name = "Form1";
            this.Text = "Form1";
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.panel1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private SequenceEditor.SequenceEditor sqEditor;
        private System.Windows.Forms.Button btnTestSaveSequence;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtSequenceName;
        private System.Windows.Forms.Label label4;
        private MatlabEditor.MEditor mEditor1;
        private System.Windows.Forms.Label label2;
        private MatlabEditor.MatlabParamTable matlabParamTable1;
    }
}

