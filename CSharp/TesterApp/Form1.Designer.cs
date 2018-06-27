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
            this.sqEditor = new SequenceEditor.SequenceEditor();
            this.SuspendLayout();
            // 
            // btnTestSaveSequence
            // 
            this.btnTestSaveSequence.Location = new System.Drawing.Point(389, 73);
            this.btnTestSaveSequence.Name = "btnTestSaveSequence";
            this.btnTestSaveSequence.Size = new System.Drawing.Size(270, 23);
            this.btnTestSaveSequence.TabIndex = 1;
            this.btnTestSaveSequence.Text = "Test Save Sequence";
            this.btnTestSaveSequence.UseVisualStyleBackColor = true;
            this.btnTestSaveSequence.Click += new System.EventHandler(this.btnTestSaveSequence_Click);
            // 
            // sqEditor
            // 
            this.sqEditor.Location = new System.Drawing.Point(0, 30);
            this.sqEditor.Name = "sqEditor";
            this.sqEditor.Size = new System.Drawing.Size(370, 465);
            this.sqEditor.TabIndex = 0;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(726, 495);
            this.Controls.Add(this.btnTestSaveSequence);
            this.Controls.Add(this.sqEditor);
            this.Name = "Form1";
            this.Text = "Form1";
            this.ResumeLayout(false);

        }

        #endregion

        private SequenceEditor.SequenceEditor sqEditor;
        private System.Windows.Forms.Button btnTestSaveSequence;
    }
}

