namespace MatlabEditor
{
    partial class MatlabParamTable
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
            this.tblParams = new System.Windows.Forms.DataGridView();
            this.cName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.cValue = new System.Windows.Forms.DataGridViewTextBoxColumn();
            ((System.ComponentModel.ISupportInitialize)(this.tblParams)).BeginInit();
            this.SuspendLayout();
            // 
            // tblParams
            // 
            this.tblParams.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.tblParams.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.cName,
            this.cValue});
            this.tblParams.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tblParams.Location = new System.Drawing.Point(0, 0);
            this.tblParams.Name = "tblParams";
            this.tblParams.Size = new System.Drawing.Size(499, 464);
            this.tblParams.TabIndex = 0;
            // 
            // cName
            // 
            this.cName.HeaderText = "Name";
            this.cName.Name = "cName";
            // 
            // cValue
            // 
            this.cValue.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.cValue.HeaderText = "Value";
            this.cValue.Name = "cValue";
            // 
            // MatlabParamTable
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.tblParams);
            this.Name = "MatlabParamTable";
            this.Size = new System.Drawing.Size(499, 464);
            ((System.ComponentModel.ISupportInitialize)(this.tblParams)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DataGridView tblParams;
        private System.Windows.Forms.DataGridViewTextBoxColumn cName;
        private System.Windows.Forms.DataGridViewTextBoxColumn cValue;
    }
}
