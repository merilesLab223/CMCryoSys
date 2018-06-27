namespace SequenceEditor
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
            this.components = new System.ComponentModel.Container();
            System.Windows.Forms.TreeNode treeNode1 = new System.Windows.Forms.TreeNode("Parameters", 0, 0);
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(SequenceEditor));
            this.tvMain = new System.Windows.Forms.TreeView();
            this.lstTreeImages = new System.Windows.Forms.ImageList(this.components);
            this.SuspendLayout();
            // 
            // tvMain
            // 
            this.tvMain.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tvMain.ImageIndex = 0;
            this.tvMain.ImageList = this.lstTreeImages;
            this.tvMain.Location = new System.Drawing.Point(0, 0);
            this.tvMain.Name = "tvMain";
            treeNode1.ImageIndex = 0;
            treeNode1.Name = "Params";
            treeNode1.SelectedImageIndex = 0;
            treeNode1.Text = "Parameters";
            this.tvMain.Nodes.AddRange(new System.Windows.Forms.TreeNode[] {
            treeNode1});
            this.tvMain.SelectedImageIndex = 0;
            this.tvMain.Size = new System.Drawing.Size(455, 547);
            this.tvMain.TabIndex = 0;
            // 
            // lstTreeImages
            // 
            this.lstTreeImages.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("lstTreeImages.ImageStream")));
            this.lstTreeImages.TransparentColor = System.Drawing.Color.Transparent;
            this.lstTreeImages.Images.SetKeyName(0, "Properties");
            this.lstTreeImages.Images.SetKeyName(1, "Sequence");
            this.lstTreeImages.Images.SetKeyName(2, "Script");
            this.lstTreeImages.Images.SetKeyName(3, "Parameter");
            // 
            // SequenceEditor
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.tvMain);
            this.Name = "SequenceEditor";
            this.Size = new System.Drawing.Size(455, 547);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TreeView tvMain;
        private System.Windows.Forms.ImageList lstTreeImages;
    }
}
