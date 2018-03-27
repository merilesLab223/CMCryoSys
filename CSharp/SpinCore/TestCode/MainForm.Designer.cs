namespace PulseBlasterNET
{
    partial class MainForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.BoardNumberLabel = new System.Windows.Forms.Label();
            this.VersionLabel = new System.Windows.Forms.Label();
            this.VersionTextBox = new System.Windows.Forms.TextBox();
            this.FirmwareIDLabel = new System.Windows.Forms.Label();
            this.FirmwareIDTextBox = new System.Windows.Forms.TextBox();
            this.LoadBoardButton = new System.Windows.Forms.Button();
            this.StartButton = new System.Windows.Forms.Button();
            this.StopButton = new System.Windows.Forms.Button();
            this.InstructionCountUpDown = new System.Windows.Forms.NumericUpDown();
            this.InstructionsGroupBox = new System.Windows.Forms.GroupBox();
            this.InformationGroupBox = new System.Windows.Forms.GroupBox();
            this.BoardNumberUpDown = new System.Windows.Forms.NumericUpDown();
            this.ControlGroupBox = new System.Windows.Forms.GroupBox();
            this.NameLabel = new System.Windows.Forms.Label();
            this.LinkTextBox = new System.Windows.Forms.RichTextBox();
            this.MenuStrip = new System.Windows.Forms.MenuStrip();
            this.FileMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.NewFileMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.OpenFileMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.FileMenuStripSeparator0 = new System.Windows.Forms.ToolStripSeparator();
            this.SaveFileMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.SaveAsFileMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.FileMenuStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.PrintFileMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.PrintPreviewFileMenuStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.FileMenuStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
            this.ExitFileMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.EditMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.UndoEditMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.RedoEditMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.EditMenuStripSeparator0 = new System.Windows.Forms.ToolStripSeparator();
            this.CutEditMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.CopyEditMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.PasteEditMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.EditMenuStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.SelectAllEditMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.ToolsMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.CustomizeToolsMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.OptionsToolsMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.HelpMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.ContentsHelpMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.IndexHelpMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.SearchHelpMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.HelpMenuStripSeparator0 = new System.Windows.Forms.ToolStripSeparator();
            this.AboutHelpMenuStripItem = new System.Windows.Forms.ToolStripMenuItem();
            this.StatusStrip = new System.Windows.Forms.StatusStrip();
            this.InstructionLayoutPanel = new System.Windows.Forms.FlowLayoutPanel();
            this.ClockFreqTextbox = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.InstructionCountUpDown)).BeginInit();
            this.InstructionsGroupBox.SuspendLayout();
            this.InformationGroupBox.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.BoardNumberUpDown)).BeginInit();
            this.ControlGroupBox.SuspendLayout();
            this.MenuStrip.SuspendLayout();
            this.SuspendLayout();
            // 
            // BoardNumberLabel
            // 
            this.BoardNumberLabel.AutoSize = true;
            this.BoardNumberLabel.Location = new System.Drawing.Point(13, 42);
            this.BoardNumberLabel.Name = "BoardNumberLabel";
            this.BoardNumberLabel.Size = new System.Drawing.Size(78, 13);
            this.BoardNumberLabel.TabIndex = 1;
            this.BoardNumberLabel.Text = "Board Number:";
            // 
            // VersionLabel
            // 
            this.VersionLabel.AutoSize = true;
            this.VersionLabel.Location = new System.Drawing.Point(6, 17);
            this.VersionLabel.Name = "VersionLabel";
            this.VersionLabel.Size = new System.Drawing.Size(86, 13);
            this.VersionLabel.TabIndex = 2;
            this.VersionLabel.Text = "SpinAPI Version:";
            // 
            // VersionTextBox
            // 
            this.VersionTextBox.Location = new System.Drawing.Point(94, 13);
            this.VersionTextBox.Name = "VersionTextBox";
            this.VersionTextBox.ReadOnly = true;
            this.VersionTextBox.Size = new System.Drawing.Size(72, 20);
            this.VersionTextBox.TabIndex = 3;
            this.VersionTextBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            // 
            // FirmwareIDLabel
            // 
            this.FirmwareIDLabel.AutoSize = true;
            this.FirmwareIDLabel.Location = new System.Drawing.Point(28, 68);
            this.FirmwareIDLabel.Name = "FirmwareIDLabel";
            this.FirmwareIDLabel.Size = new System.Drawing.Size(66, 13);
            this.FirmwareIDLabel.TabIndex = 4;
            this.FirmwareIDLabel.Text = "Firmware ID:";
            // 
            // FirmwareIDTextBox
            // 
            this.FirmwareIDTextBox.Location = new System.Drawing.Point(94, 65);
            this.FirmwareIDTextBox.Name = "FirmwareIDTextBox";
            this.FirmwareIDTextBox.ReadOnly = true;
            this.FirmwareIDTextBox.Size = new System.Drawing.Size(72, 20);
            this.FirmwareIDTextBox.TabIndex = 5;
            this.FirmwareIDTextBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            // 
            // LoadBoardButton
            // 
            this.LoadBoardButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)));
            this.LoadBoardButton.Location = new System.Drawing.Point(20, 24);
            this.LoadBoardButton.Name = "LoadBoardButton";
            this.LoadBoardButton.Size = new System.Drawing.Size(100, 50);
            this.LoadBoardButton.TabIndex = 6;
            this.LoadBoardButton.Text = "Load Board";
            this.LoadBoardButton.UseVisualStyleBackColor = true;
            this.LoadBoardButton.Click += new System.EventHandler(this.LoadBoardButton_Click);
            // 
            // StartButton
            // 
            this.StartButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)));
            this.StartButton.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.StartButton.ForeColor = System.Drawing.SystemColors.ControlText;
            this.StartButton.ImageAlign = System.Drawing.ContentAlignment.TopCenter;
            this.StartButton.Location = new System.Drawing.Point(160, 25);
            this.StartButton.Name = "StartButton";
            this.StartButton.Size = new System.Drawing.Size(100, 50);
            this.StartButton.TabIndex = 7;
            this.StartButton.Text = "Start";
            this.StartButton.UseVisualStyleBackColor = true;
            this.StartButton.Click += new System.EventHandler(this.StartButton_Click);
            // 
            // StopButton
            // 
            this.StopButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)));
            this.StopButton.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.StopButton.ImageAlign = System.Drawing.ContentAlignment.TopCenter;
            this.StopButton.Location = new System.Drawing.Point(300, 24);
            this.StopButton.Name = "StopButton";
            this.StopButton.Size = new System.Drawing.Size(100, 50);
            this.StopButton.TabIndex = 8;
            this.StopButton.Text = "Stop";
            this.StopButton.UseVisualStyleBackColor = true;
            this.StopButton.Click += new System.EventHandler(this.StopButton_Click);
            // 
            // InstructionCountUpDown
            // 
            this.InstructionCountUpDown.BackColor = System.Drawing.SystemColors.ControlLightLight;
            this.InstructionCountUpDown.Location = new System.Drawing.Point(10, 19);
            this.InstructionCountUpDown.Minimum = new decimal(new int[] {
            2,
            0,
            0,
            0});
            this.InstructionCountUpDown.Name = "InstructionCountUpDown";
            this.InstructionCountUpDown.ReadOnly = true;
            this.InstructionCountUpDown.Size = new System.Drawing.Size(80, 20);
            this.InstructionCountUpDown.TabIndex = 17;
            this.InstructionCountUpDown.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.InstructionCountUpDown.Value = new decimal(new int[] {
            2,
            0,
            0,
            0});
            this.InstructionCountUpDown.ValueChanged += new System.EventHandler(this.InstructionCountUpDown_ValueChanged);
            // 
            // InstructionsGroupBox
            // 
            this.InstructionsGroupBox.Controls.Add(this.InstructionCountUpDown);
            this.InstructionsGroupBox.Location = new System.Drawing.Point(190, 27);
            this.InstructionsGroupBox.Name = "InstructionsGroupBox";
            this.InstructionsGroupBox.Size = new System.Drawing.Size(100, 46);
            this.InstructionsGroupBox.TabIndex = 18;
            this.InstructionsGroupBox.TabStop = false;
            this.InstructionsGroupBox.Text = "Instructions";
            // 
            // InformationGroupBox
            // 
            this.InformationGroupBox.Controls.Add(this.BoardNumberUpDown);
            this.InformationGroupBox.Controls.Add(this.VersionLabel);
            this.InformationGroupBox.Controls.Add(this.BoardNumberLabel);
            this.InformationGroupBox.Controls.Add(this.FirmwareIDLabel);
            this.InformationGroupBox.Controls.Add(this.FirmwareIDTextBox);
            this.InformationGroupBox.Controls.Add(this.VersionTextBox);
            this.InformationGroupBox.Location = new System.Drawing.Point(12, 27);
            this.InformationGroupBox.Name = "InformationGroupBox";
            this.InformationGroupBox.Size = new System.Drawing.Size(172, 91);
            this.InformationGroupBox.TabIndex = 21;
            this.InformationGroupBox.TabStop = false;
            this.InformationGroupBox.Text = "Information";
            // 
            // BoardNumberUpDown
            // 
            this.BoardNumberUpDown.Location = new System.Drawing.Point(94, 40);
            this.BoardNumberUpDown.Name = "BoardNumberUpDown";
            this.BoardNumberUpDown.Size = new System.Drawing.Size(72, 20);
            this.BoardNumberUpDown.TabIndex = 6;
            this.BoardNumberUpDown.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.BoardNumberUpDown.Leave += new System.EventHandler(this.BoardNumberUpDown_Leave);
            // 
            // ControlGroupBox
            // 
            this.ControlGroupBox.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.ControlGroupBox.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("ControlGroupBox.BackgroundImage")));
            this.ControlGroupBox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.ControlGroupBox.Controls.Add(this.LoadBoardButton);
            this.ControlGroupBox.Controls.Add(this.StartButton);
            this.ControlGroupBox.Controls.Add(this.StopButton);
            this.ControlGroupBox.Location = new System.Drawing.Point(296, 27);
            this.ControlGroupBox.Name = "ControlGroupBox";
            this.ControlGroupBox.Size = new System.Drawing.Size(420, 91);
            this.ControlGroupBox.TabIndex = 23;
            this.ControlGroupBox.TabStop = false;
            this.ControlGroupBox.Text = "Control";
            // 
            // NameLabel
            // 
            this.NameLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.NameLabel.AutoSize = true;
            this.NameLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.NameLabel.Location = new System.Drawing.Point(734, 36);
            this.NameLabel.Name = "NameLabel";
            this.NameLabel.Size = new System.Drawing.Size(266, 24);
            this.NameLabel.TabIndex = 24;
            this.NameLabel.Text = "SpinCore PulseBlaster.NET";
            // 
            // LinkTextBox
            // 
            this.LinkTextBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.LinkTextBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.LinkTextBox.Enabled = false;
            this.LinkTextBox.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LinkTextBox.Location = new System.Drawing.Point(738, 73);
            this.LinkTextBox.Name = "LinkTextBox";
            this.LinkTextBox.ReadOnly = true;
            this.LinkTextBox.ScrollBars = System.Windows.Forms.RichTextBoxScrollBars.None;
            this.LinkTextBox.ShortcutsEnabled = false;
            this.LinkTextBox.Size = new System.Drawing.Size(218, 45);
            this.LinkTextBox.TabIndex = 0;
            this.LinkTextBox.TabStop = false;
            this.LinkTextBox.Text = "SpinCore Technologies, Inc.\nwww.spincore.com";
            this.LinkTextBox.LinkClicked += new System.Windows.Forms.LinkClickedEventHandler(this.LinkTextBox_LinkClicked);
            // 
            // MenuStrip
            // 
            this.MenuStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.FileMenuStripItem,
            this.EditMenuStripItem,
            this.ToolsMenuStripItem,
            this.HelpMenuStripItem});
            this.MenuStrip.Location = new System.Drawing.Point(0, 0);
            this.MenuStrip.Name = "MenuStrip";
            this.MenuStrip.Size = new System.Drawing.Size(1002, 24);
            this.MenuStrip.TabIndex = 25;
            this.MenuStrip.Text = "menuStrip1";
            // 
            // FileMenuStripItem
            // 
            this.FileMenuStripItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.NewFileMenuStripItem,
            this.OpenFileMenuStripItem,
            this.FileMenuStripSeparator0,
            this.SaveFileMenuStripItem,
            this.SaveAsFileMenuStripItem,
            this.FileMenuStripSeparator1,
            this.PrintFileMenuStripItem,
            this.PrintPreviewFileMenuStripMenuItem,
            this.FileMenuStripSeparator2,
            this.ExitFileMenuStripItem});
            this.FileMenuStripItem.Name = "FileMenuStripItem";
            this.FileMenuStripItem.Size = new System.Drawing.Size(37, 20);
            this.FileMenuStripItem.Text = "&File";
            // 
            // NewFileMenuStripItem
            // 
            this.NewFileMenuStripItem.Image = ((System.Drawing.Image)(resources.GetObject("NewFileMenuStripItem.Image")));
            this.NewFileMenuStripItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.NewFileMenuStripItem.Name = "NewFileMenuStripItem";
            this.NewFileMenuStripItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.N)));
            this.NewFileMenuStripItem.Size = new System.Drawing.Size(146, 22);
            this.NewFileMenuStripItem.Text = "&New";
            this.NewFileMenuStripItem.Click += new System.EventHandler(this.NewFileStripMenuItem_Click);
            // 
            // OpenFileMenuStripItem
            // 
            this.OpenFileMenuStripItem.Image = ((System.Drawing.Image)(resources.GetObject("OpenFileMenuStripItem.Image")));
            this.OpenFileMenuStripItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.OpenFileMenuStripItem.Name = "OpenFileMenuStripItem";
            this.OpenFileMenuStripItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.O)));
            this.OpenFileMenuStripItem.Size = new System.Drawing.Size(146, 22);
            this.OpenFileMenuStripItem.Text = "&Open";
            this.OpenFileMenuStripItem.Click += new System.EventHandler(this.OpenFileMenuStripItem_Click);
            // 
            // FileMenuStripSeparator0
            // 
            this.FileMenuStripSeparator0.Name = "FileMenuStripSeparator0";
            this.FileMenuStripSeparator0.Size = new System.Drawing.Size(143, 6);
            // 
            // SaveFileMenuStripItem
            // 
            this.SaveFileMenuStripItem.Image = ((System.Drawing.Image)(resources.GetObject("SaveFileMenuStripItem.Image")));
            this.SaveFileMenuStripItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.SaveFileMenuStripItem.Name = "SaveFileMenuStripItem";
            this.SaveFileMenuStripItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.S)));
            this.SaveFileMenuStripItem.Size = new System.Drawing.Size(146, 22);
            this.SaveFileMenuStripItem.Text = "&Save";
            this.SaveFileMenuStripItem.Click += new System.EventHandler(this.SaveFileMenuStripItem_Click);
            // 
            // SaveAsFileMenuStripItem
            // 
            this.SaveAsFileMenuStripItem.Name = "SaveAsFileMenuStripItem";
            this.SaveAsFileMenuStripItem.Size = new System.Drawing.Size(146, 22);
            this.SaveAsFileMenuStripItem.Text = "Save &As";
            this.SaveAsFileMenuStripItem.Click += new System.EventHandler(this.SaveAsFileMenuStripItem_Click);
            // 
            // FileMenuStripSeparator1
            // 
            this.FileMenuStripSeparator1.Name = "FileMenuStripSeparator1";
            this.FileMenuStripSeparator1.Size = new System.Drawing.Size(143, 6);
            // 
            // PrintFileMenuStripItem
            // 
            this.PrintFileMenuStripItem.Image = ((System.Drawing.Image)(resources.GetObject("PrintFileMenuStripItem.Image")));
            this.PrintFileMenuStripItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.PrintFileMenuStripItem.Name = "PrintFileMenuStripItem";
            this.PrintFileMenuStripItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.P)));
            this.PrintFileMenuStripItem.Size = new System.Drawing.Size(146, 22);
            this.PrintFileMenuStripItem.Text = "&Print";
            // 
            // PrintPreviewFileMenuStripMenuItem
            // 
            this.PrintPreviewFileMenuStripMenuItem.Image = ((System.Drawing.Image)(resources.GetObject("PrintPreviewFileMenuStripMenuItem.Image")));
            this.PrintPreviewFileMenuStripMenuItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.PrintPreviewFileMenuStripMenuItem.Name = "PrintPreviewFileMenuStripMenuItem";
            this.PrintPreviewFileMenuStripMenuItem.Size = new System.Drawing.Size(146, 22);
            this.PrintPreviewFileMenuStripMenuItem.Text = "Print Pre&view";
            // 
            // FileMenuStripSeparator2
            // 
            this.FileMenuStripSeparator2.Name = "FileMenuStripSeparator2";
            this.FileMenuStripSeparator2.Size = new System.Drawing.Size(143, 6);
            // 
            // ExitFileMenuStripItem
            // 
            this.ExitFileMenuStripItem.Name = "ExitFileMenuStripItem";
            this.ExitFileMenuStripItem.Size = new System.Drawing.Size(146, 22);
            this.ExitFileMenuStripItem.Text = "E&xit";
            this.ExitFileMenuStripItem.Click += new System.EventHandler(this.ExitFileMenuStripItem_Click);
            // 
            // EditMenuStripItem
            // 
            this.EditMenuStripItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.UndoEditMenuStripItem,
            this.RedoEditMenuStripItem,
            this.EditMenuStripSeparator0,
            this.CutEditMenuStripItem,
            this.CopyEditMenuStripItem,
            this.PasteEditMenuStripItem,
            this.EditMenuStripSeparator1,
            this.SelectAllEditMenuStripItem});
            this.EditMenuStripItem.Name = "EditMenuStripItem";
            this.EditMenuStripItem.Size = new System.Drawing.Size(39, 20);
            this.EditMenuStripItem.Text = "&Edit";
            // 
            // UndoEditMenuStripItem
            // 
            this.UndoEditMenuStripItem.Name = "UndoEditMenuStripItem";
            this.UndoEditMenuStripItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Z)));
            this.UndoEditMenuStripItem.Size = new System.Drawing.Size(144, 22);
            this.UndoEditMenuStripItem.Text = "&Undo";
            this.UndoEditMenuStripItem.Click += new System.EventHandler(this.UndoEditMenuStripItem_Click);
            // 
            // RedoEditMenuStripItem
            // 
            this.RedoEditMenuStripItem.Name = "RedoEditMenuStripItem";
            this.RedoEditMenuStripItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Y)));
            this.RedoEditMenuStripItem.Size = new System.Drawing.Size(144, 22);
            this.RedoEditMenuStripItem.Text = "&Redo";
            this.RedoEditMenuStripItem.Click += new System.EventHandler(this.RedoEditMenuStripItem_Click);
            // 
            // EditMenuStripSeparator0
            // 
            this.EditMenuStripSeparator0.Name = "EditMenuStripSeparator0";
            this.EditMenuStripSeparator0.Size = new System.Drawing.Size(141, 6);
            // 
            // CutEditMenuStripItem
            // 
            this.CutEditMenuStripItem.Image = ((System.Drawing.Image)(resources.GetObject("CutEditMenuStripItem.Image")));
            this.CutEditMenuStripItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.CutEditMenuStripItem.Name = "CutEditMenuStripItem";
            this.CutEditMenuStripItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.X)));
            this.CutEditMenuStripItem.Size = new System.Drawing.Size(144, 22);
            this.CutEditMenuStripItem.Text = "Cu&t";
            // 
            // CopyEditMenuStripItem
            // 
            this.CopyEditMenuStripItem.Image = ((System.Drawing.Image)(resources.GetObject("CopyEditMenuStripItem.Image")));
            this.CopyEditMenuStripItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.CopyEditMenuStripItem.Name = "CopyEditMenuStripItem";
            this.CopyEditMenuStripItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.C)));
            this.CopyEditMenuStripItem.Size = new System.Drawing.Size(144, 22);
            this.CopyEditMenuStripItem.Text = "&Copy";
            // 
            // PasteEditMenuStripItem
            // 
            this.PasteEditMenuStripItem.Image = ((System.Drawing.Image)(resources.GetObject("PasteEditMenuStripItem.Image")));
            this.PasteEditMenuStripItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.PasteEditMenuStripItem.Name = "PasteEditMenuStripItem";
            this.PasteEditMenuStripItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.V)));
            this.PasteEditMenuStripItem.Size = new System.Drawing.Size(144, 22);
            this.PasteEditMenuStripItem.Text = "&Paste";
            // 
            // EditMenuStripSeparator1
            // 
            this.EditMenuStripSeparator1.Name = "EditMenuStripSeparator1";
            this.EditMenuStripSeparator1.Size = new System.Drawing.Size(141, 6);
            // 
            // SelectAllEditMenuStripItem
            // 
            this.SelectAllEditMenuStripItem.Name = "SelectAllEditMenuStripItem";
            this.SelectAllEditMenuStripItem.Size = new System.Drawing.Size(144, 22);
            this.SelectAllEditMenuStripItem.Text = "Select &All";
            // 
            // ToolsMenuStripItem
            // 
            this.ToolsMenuStripItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.CustomizeToolsMenuStripItem,
            this.OptionsToolsMenuStripItem});
            this.ToolsMenuStripItem.Name = "ToolsMenuStripItem";
            this.ToolsMenuStripItem.Size = new System.Drawing.Size(48, 20);
            this.ToolsMenuStripItem.Text = "&Tools";
            // 
            // CustomizeToolsMenuStripItem
            // 
            this.CustomizeToolsMenuStripItem.Name = "CustomizeToolsMenuStripItem";
            this.CustomizeToolsMenuStripItem.Size = new System.Drawing.Size(130, 22);
            this.CustomizeToolsMenuStripItem.Text = "&Customize";
            // 
            // OptionsToolsMenuStripItem
            // 
            this.OptionsToolsMenuStripItem.Name = "OptionsToolsMenuStripItem";
            this.OptionsToolsMenuStripItem.Size = new System.Drawing.Size(130, 22);
            this.OptionsToolsMenuStripItem.Text = "&Options";
            // 
            // HelpMenuStripItem
            // 
            this.HelpMenuStripItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.ContentsHelpMenuStripItem,
            this.IndexHelpMenuStripItem,
            this.SearchHelpMenuStripItem,
            this.HelpMenuStripSeparator0,
            this.AboutHelpMenuStripItem});
            this.HelpMenuStripItem.Name = "HelpMenuStripItem";
            this.HelpMenuStripItem.Size = new System.Drawing.Size(44, 20);
            this.HelpMenuStripItem.Text = "&Help";
            // 
            // ContentsHelpMenuStripItem
            // 
            this.ContentsHelpMenuStripItem.Name = "ContentsHelpMenuStripItem";
            this.ContentsHelpMenuStripItem.Size = new System.Drawing.Size(122, 22);
            this.ContentsHelpMenuStripItem.Text = "&Contents";
            // 
            // IndexHelpMenuStripItem
            // 
            this.IndexHelpMenuStripItem.Name = "IndexHelpMenuStripItem";
            this.IndexHelpMenuStripItem.Size = new System.Drawing.Size(122, 22);
            this.IndexHelpMenuStripItem.Text = "&Index";
            // 
            // SearchHelpMenuStripItem
            // 
            this.SearchHelpMenuStripItem.Name = "SearchHelpMenuStripItem";
            this.SearchHelpMenuStripItem.Size = new System.Drawing.Size(122, 22);
            this.SearchHelpMenuStripItem.Text = "&Search";
            // 
            // HelpMenuStripSeparator0
            // 
            this.HelpMenuStripSeparator0.Name = "HelpMenuStripSeparator0";
            this.HelpMenuStripSeparator0.Size = new System.Drawing.Size(119, 6);
            // 
            // AboutHelpMenuStripItem
            // 
            this.AboutHelpMenuStripItem.Name = "AboutHelpMenuStripItem";
            this.AboutHelpMenuStripItem.Size = new System.Drawing.Size(122, 22);
            this.AboutHelpMenuStripItem.Text = "&About...";
            this.AboutHelpMenuStripItem.Click += new System.EventHandler(this.AboutHelpMenuStripItem_Click);
            // 
            // StatusStrip
            // 
            this.StatusStrip.Location = new System.Drawing.Point(0, 344);
            this.StatusStrip.Name = "StatusStrip";
            this.StatusStrip.Size = new System.Drawing.Size(1002, 22);
            this.StatusStrip.TabIndex = 26;
            this.StatusStrip.Text = "statusStrip1";
            // 
            // InstructionLayoutPanel
            // 
            this.InstructionLayoutPanel.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.InstructionLayoutPanel.AutoScroll = true;
            this.InstructionLayoutPanel.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.InstructionLayoutPanel.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.InstructionLayoutPanel.Location = new System.Drawing.Point(12, 124);
            this.InstructionLayoutPanel.Name = "InstructionLayoutPanel";
            this.InstructionLayoutPanel.Size = new System.Drawing.Size(988, 217);
            this.InstructionLayoutPanel.TabIndex = 27;
            this.InstructionLayoutPanel.Resize += new System.EventHandler(this.InstructionLayoutPanel_Resize);
            // 
            // ClockFreqTextbox
            // 
            this.ClockFreqTextbox.Location = new System.Drawing.Point(200, 87);
            this.ClockFreqTextbox.Name = "ClockFreqTextbox";
            this.ClockFreqTextbox.Size = new System.Drawing.Size(80, 20);
            this.ClockFreqTextbox.TabIndex = 28;
            this.ClockFreqTextbox.TextChanged += new System.EventHandler(this.ClockFreqTextbox_TextChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(197, 69);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(92, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Clock Freq. (MHz)";
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1002, 366);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.ClockFreqTextbox);
            this.Controls.Add(this.InstructionLayoutPanel);
            this.Controls.Add(this.StatusStrip);
            this.Controls.Add(this.LinkTextBox);
            this.Controls.Add(this.NameLabel);
            this.Controls.Add(this.InstructionsGroupBox);
            this.Controls.Add(this.InformationGroupBox);
            this.Controls.Add(this.ControlGroupBox);
            this.Controls.Add(this.MenuStrip);
            this.MainMenuStrip = this.MenuStrip;
            this.MinimumSize = new System.Drawing.Size(1010, 300);
            this.Name = "MainForm";
            this.Text = "PusleBlaster.NET";
            this.Load += new System.EventHandler(this.MainForm_Load);
            ((System.ComponentModel.ISupportInitialize)(this.InstructionCountUpDown)).EndInit();
            this.InstructionsGroupBox.ResumeLayout(false);
            this.InformationGroupBox.ResumeLayout(false);
            this.InformationGroupBox.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.BoardNumberUpDown)).EndInit();
            this.ControlGroupBox.ResumeLayout(false);
            this.MenuStrip.ResumeLayout(false);
            this.MenuStrip.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label BoardNumberLabel;
        private System.Windows.Forms.Label VersionLabel;
        private System.Windows.Forms.TextBox VersionTextBox;
        private System.Windows.Forms.Label FirmwareIDLabel;
        private System.Windows.Forms.TextBox FirmwareIDTextBox;
        private System.Windows.Forms.Button LoadBoardButton;
        private System.Windows.Forms.Button StartButton;
        private System.Windows.Forms.Button StopButton;
        private System.Windows.Forms.NumericUpDown InstructionCountUpDown;
        private System.Windows.Forms.GroupBox InstructionsGroupBox;
        private System.Windows.Forms.GroupBox InformationGroupBox;
        private System.Windows.Forms.GroupBox ControlGroupBox;
        private System.Windows.Forms.Label NameLabel;
        private System.Windows.Forms.RichTextBox LinkTextBox;
        private System.Windows.Forms.MenuStrip MenuStrip;
        private System.Windows.Forms.StatusStrip StatusStrip;
        private System.Windows.Forms.FlowLayoutPanel InstructionLayoutPanel;
        private System.Windows.Forms.NumericUpDown BoardNumberUpDown;
        private System.Windows.Forms.ToolStripMenuItem FileMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem NewFileMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem OpenFileMenuStripItem;
        private System.Windows.Forms.ToolStripSeparator FileMenuStripSeparator0;
        private System.Windows.Forms.ToolStripMenuItem SaveFileMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem SaveAsFileMenuStripItem;
        private System.Windows.Forms.ToolStripSeparator FileMenuStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem PrintFileMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem PrintPreviewFileMenuStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator FileMenuStripSeparator2;
        private System.Windows.Forms.ToolStripMenuItem ExitFileMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem EditMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem UndoEditMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem RedoEditMenuStripItem;
        private System.Windows.Forms.ToolStripSeparator EditMenuStripSeparator0;
        private System.Windows.Forms.ToolStripMenuItem CutEditMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem CopyEditMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem PasteEditMenuStripItem;
        private System.Windows.Forms.ToolStripSeparator EditMenuStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem SelectAllEditMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem ToolsMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem CustomizeToolsMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem OptionsToolsMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem HelpMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem ContentsHelpMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem IndexHelpMenuStripItem;
        private System.Windows.Forms.ToolStripMenuItem SearchHelpMenuStripItem;
        private System.Windows.Forms.ToolStripSeparator HelpMenuStripSeparator0;
        private System.Windows.Forms.ToolStripMenuItem AboutHelpMenuStripItem;
        private System.Windows.Forms.TextBox ClockFreqTextbox;
        private System.Windows.Forms.Label label1;
    }
}

