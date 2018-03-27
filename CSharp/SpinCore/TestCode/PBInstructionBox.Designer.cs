namespace PulseBlasterNET
{
    partial class PBInstructionBox
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
            this.DataBox = new System.Windows.Forms.NumericUpDown();
            this.OpCodeComboBox = new System.Windows.Forms.ComboBox();
            this.DurationTextBox = new System.Windows.Forms.TextBox();
            this.TimeUnitComboBox = new System.Windows.Forms.ComboBox();
            this.DataPanel = new System.Windows.Forms.Panel();
            this.FlowControlGroupBox = new System.Windows.Forms.GroupBox();
            this.DataLabel = new System.Windows.Forms.Label();
            this.CodeLabel = new System.Windows.Forms.Label();
            this.FlagsGroupBox = new System.Windows.Forms.GroupBox();
            this.FlagsLayoutPanel = new System.Windows.Forms.FlowLayoutPanel();
            this.DurationGroupBox = new System.Windows.Forms.GroupBox();
            this.InstructionNumberLabel = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.DataBox)).BeginInit();
            this.DataPanel.SuspendLayout();
            this.FlowControlGroupBox.SuspendLayout();
            this.FlagsGroupBox.SuspendLayout();
            this.DurationGroupBox.SuspendLayout();
            this.SuspendLayout();
            // 
            // DataBox
            // 
            this.DataBox.Location = new System.Drawing.Point(103, 33);
            this.DataBox.Maximum = new decimal(new int[] {
            65535,
            0,
            0,
            0});
            this.DataBox.Name = "DataBox";
            this.DataBox.Size = new System.Drawing.Size(75, 20);
            this.DataBox.TabIndex = 24;
            this.DataBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.DataBox.ValueChanged += new System.EventHandler(this.DataBox_ValueChanged);
            this.DataBox.Leave += new System.EventHandler(this.DataBox_Leave);
            // 
            // OpCodeComboBox
            // 
            this.OpCodeComboBox.BackColor = System.Drawing.Color.LavenderBlush;
            this.OpCodeComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.OpCodeComboBox.FormattingEnabled = true;
            this.OpCodeComboBox.Location = new System.Drawing.Point(6, 32);
            this.OpCodeComboBox.MaxDropDownItems = 15;
            this.OpCodeComboBox.Name = "OpCodeComboBox";
            this.OpCodeComboBox.Size = new System.Drawing.Size(91, 21);
            this.OpCodeComboBox.TabIndex = 25;
            this.OpCodeComboBox.SelectedIndexChanged += new System.EventHandler(this.OpCodeComboBox_SelectedIndexChanged);
            this.OpCodeComboBox.Leave += new System.EventHandler(this.DataBox_Leave);
            // 
            // DurationTextBox
            // 
            this.DurationTextBox.Location = new System.Drawing.Point(6, 17);
            this.DurationTextBox.Name = "DurationTextBox";
            this.DurationTextBox.Size = new System.Drawing.Size(77, 20);
            this.DurationTextBox.TabIndex = 30;
            this.DurationTextBox.Text = "1.0";
            this.DurationTextBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.DurationTextBox.TextChanged += new System.EventHandler(this.DurationTextBox_TextChanged);
            this.DurationTextBox.Leave += new System.EventHandler(this.DurationTextBox_Leave);
            // 
            // TimeUnitComboBox
            // 
            this.TimeUnitComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.TimeUnitComboBox.FormattingEnabled = true;
            this.TimeUnitComboBox.Location = new System.Drawing.Point(86, 16);
            this.TimeUnitComboBox.Name = "TimeUnitComboBox";
            this.TimeUnitComboBox.Size = new System.Drawing.Size(42, 21);
            this.TimeUnitComboBox.TabIndex = 32;
            this.TimeUnitComboBox.SelectedIndexChanged += new System.EventHandler(this.TimeUnitComboBox_SelectedIndexChanged);
            // 
            // DataPanel
            // 
            this.DataPanel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right)));
            this.DataPanel.Controls.Add(this.FlowControlGroupBox);
            this.DataPanel.Controls.Add(this.FlagsGroupBox);
            this.DataPanel.Controls.Add(this.DurationGroupBox);
            this.DataPanel.Location = new System.Drawing.Point(43, 3);
            this.DataPanel.Name = "DataPanel";
            this.DataPanel.Size = new System.Drawing.Size(904, 72);
            this.DataPanel.TabIndex = 34;
            // 
            // FlowControlGroupBox
            // 
            this.FlowControlGroupBox.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.FlowControlGroupBox.Controls.Add(this.DataLabel);
            this.FlowControlGroupBox.Controls.Add(this.CodeLabel);
            this.FlowControlGroupBox.Controls.Add(this.OpCodeComboBox);
            this.FlowControlGroupBox.Controls.Add(this.DataBox);
            this.FlowControlGroupBox.Location = new System.Drawing.Point(713, 3);
            this.FlowControlGroupBox.Name = "FlowControlGroupBox";
            this.FlowControlGroupBox.Size = new System.Drawing.Size(184, 60);
            this.FlowControlGroupBox.TabIndex = 36;
            this.FlowControlGroupBox.TabStop = false;
            this.FlowControlGroupBox.Text = "Flow Control";
            // 
            // DataLabel
            // 
            this.DataLabel.AutoSize = true;
            this.DataLabel.Location = new System.Drawing.Point(100, 16);
            this.DataLabel.Name = "DataLabel";
            this.DataLabel.Size = new System.Drawing.Size(33, 13);
            this.DataLabel.TabIndex = 27;
            this.DataLabel.Text = "Data:";
            // 
            // CodeLabel
            // 
            this.CodeLabel.AutoSize = true;
            this.CodeLabel.Location = new System.Drawing.Point(6, 16);
            this.CodeLabel.Name = "CodeLabel";
            this.CodeLabel.Size = new System.Drawing.Size(35, 13);
            this.CodeLabel.TabIndex = 26;
            this.CodeLabel.Text = "Code:";
            // 
            // FlagsGroupBox
            // 
            this.FlagsGroupBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right)));
            this.FlagsGroupBox.Controls.Add(this.FlagsLayoutPanel);
            this.FlagsGroupBox.Location = new System.Drawing.Point(143, 10);
            this.FlagsGroupBox.Name = "FlagsGroupBox";
            this.FlagsGroupBox.Size = new System.Drawing.Size(564, 48);
            this.FlagsGroupBox.TabIndex = 35;
            this.FlagsGroupBox.TabStop = false;
            this.FlagsGroupBox.Text = "Flags";
            // 
            // FlagsLayoutPanel
            // 
            this.FlagsLayoutPanel.BackColor = System.Drawing.SystemColors.Control;
            this.FlagsLayoutPanel.Location = new System.Drawing.Point(6, 16);
            this.FlagsLayoutPanel.Name = "FlagsLayoutPanel";
            this.FlagsLayoutPanel.Size = new System.Drawing.Size(552, 31);
            this.FlagsLayoutPanel.TabIndex = 0;
            // 
            // DurationGroupBox
            // 
            this.DurationGroupBox.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.DurationGroupBox.Controls.Add(this.DurationTextBox);
            this.DurationGroupBox.Controls.Add(this.TimeUnitComboBox);
            this.DurationGroupBox.Location = new System.Drawing.Point(3, 10);
            this.DurationGroupBox.Name = "DurationGroupBox";
            this.DurationGroupBox.Size = new System.Drawing.Size(134, 48);
            this.DurationGroupBox.TabIndex = 34;
            this.DurationGroupBox.TabStop = false;
            this.DurationGroupBox.Text = "Duration";
            // 
            // InstructionNumberLabel
            // 
            this.InstructionNumberLabel.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.InstructionNumberLabel.AutoSize = true;
            this.InstructionNumberLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.InstructionNumberLabel.Location = new System.Drawing.Point(3, 29);
            this.InstructionNumberLabel.Name = "InstructionNumberLabel";
            this.InstructionNumberLabel.Size = new System.Drawing.Size(21, 24);
            this.InstructionNumberLabel.TabIndex = 35;
            this.InstructionNumberLabel.Text = "0";
            // 
            // PBInstructionBox
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.Controls.Add(this.InstructionNumberLabel);
            this.Controls.Add(this.DataPanel);
            this.Name = "PBInstructionBox";
            this.Size = new System.Drawing.Size(948, 78);
            this.Load += new System.EventHandler(this.PBControl_Load);
            ((System.ComponentModel.ISupportInitialize)(this.DataBox)).EndInit();
            this.DataPanel.ResumeLayout(false);
            this.FlowControlGroupBox.ResumeLayout(false);
            this.FlowControlGroupBox.PerformLayout();
            this.FlagsGroupBox.ResumeLayout(false);
            this.DurationGroupBox.ResumeLayout(false);
            this.DurationGroupBox.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.NumericUpDown DataBox;
        private System.Windows.Forms.ComboBox OpCodeComboBox;
        private System.Windows.Forms.TextBox DurationTextBox;
        private System.Windows.Forms.ComboBox TimeUnitComboBox;
        private System.Windows.Forms.Panel DataPanel;
        private System.Windows.Forms.GroupBox DurationGroupBox;
        private System.Windows.Forms.Label InstructionNumberLabel;
        private System.Windows.Forms.GroupBox FlagsGroupBox;
        private System.Windows.Forms.FlowLayoutPanel FlagsLayoutPanel;
        private System.Windows.Forms.GroupBox FlowControlGroupBox;
        private System.Windows.Forms.Label DataLabel;
        private System.Windows.Forms.Label CodeLabel;
    }
}
