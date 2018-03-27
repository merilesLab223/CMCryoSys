/*
    Copyright 2009, SpinCore Technolgies, Inc.

    This file is part of SpinAPI.NET.

    SpinAPI.NET is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation, either version 3 of the License,
    or (at your option) any later version.

    SpinAPI.NET is distributed in the hope that it will be
    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SpinAPI.NET.  If not, see
    <http://www.gnu.org/licenses/>.
*/

using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using SpinCore.SpinAPI;
using System.Threading;
using System.IO;

namespace PulseBlasterNET
{
    public partial class MainForm : Form
    {
        private const int BoardNumberDefault = 0;
        private const int InitialInstructionCount = 2;

        double ClockFrequency = 100.0;

        private Stack<Command> History;
        private Stack<Command> Future;

        private int LastGoodBoardNumber;
        private string FileFilter = "$safeprojectname$ Files(*.pbn)|*.pbn|All files (*.*)|*.*";
        private string CurrentFileName = "";

        public class AddInstructionCommand : Command
        {
            private MainForm Parent;
            private PBInstructionBox Instruction;

            public AddInstructionCommand(MainForm Parent, PBInstructionBox Instruction)
            {
                this.Parent = Parent;
                this.Instruction = Instruction;
            }

            public void Execute()
            {
                this.Parent.InstructionLayoutPanel.Controls.Add(this.Instruction);
                this.Instruction.Number = this.Parent.InstructionLayoutPanel.Controls.Count - 1;
                this.Instruction.Style = LookupStyle(Program.SpinAPI.GetFirmwareID(Parent.BoardNumber));
                this.Parent.InstructionCountUpDown.ValueChanged -= this.Parent.InstructionCountUpDown_ValueChanged;
                this.Parent.InstructionCountUpDown.Value = this.Parent.InstructionLayoutPanel.Controls.Count;
                this.Parent.InstructionCountUpDown.ValueChanged += this.Parent.InstructionCountUpDown_ValueChanged;
            }

            public void Undo()
            {
                this.Parent.InstructionLayoutPanel.Controls.Remove(this.Instruction);
                this.Parent.InstructionCountUpDown.ValueChanged -= this.Parent.InstructionCountUpDown_ValueChanged;
                this.Parent.InstructionCountUpDown.Value = this.Parent.InstructionLayoutPanel.Controls.Count;
                this.Parent.InstructionCountUpDown.ValueChanged += this.Parent.InstructionCountUpDown_ValueChanged;
            }
        }

        public class RemoveInstructionCommand : Command
        {
            MainForm Parent;
            PBInstructionBox Instruction;

            public RemoveInstructionCommand(MainForm Parent, PBInstructionBox Instruction)
            {
                this.Parent = Parent;
                this.Instruction = Instruction;
            }

            public void Execute()
            {
                this.Parent.InstructionLayoutPanel.Controls.Remove(this.Instruction);
                this.Parent.InstructionCountUpDown.ValueChanged -= this.Parent.InstructionCountUpDown_ValueChanged;
                this.Parent.InstructionCountUpDown.Value = this.Parent.InstructionLayoutPanel.Controls.Count;
                this.Parent.InstructionCountUpDown.ValueChanged += this.Parent.InstructionCountUpDown_ValueChanged;
            }

            public void Undo()
            {
                this.Parent.InstructionLayoutPanel.Controls.Add(this.Instruction);
                this.Instruction.Number = this.Parent.InstructionLayoutPanel.Controls.Count - 1;
                this.Instruction.Style = LookupStyle(Program.SpinAPI.GetFirmwareID(Parent.BoardNumber));
                this.Parent.InstructionCountUpDown.ValueChanged -= this.Parent.InstructionCountUpDown_ValueChanged;
                this.Parent.InstructionCountUpDown.Value = this.Parent.InstructionLayoutPanel.Controls.Count;
                this.Parent.InstructionCountUpDown.ValueChanged += this.Parent.InstructionCountUpDown_ValueChanged;
            }
        }

        public class ChangeInstructionCommand : Command
        {
            MainForm Parent;
            PBInstructionBox Instruction;

            public ChangeInstructionCommand(MainForm Parent, PBInstructionBox Instruction)
            {
                this.Parent = Parent;
                this.Instruction = Instruction;
            }

            public void Execute()
            {
                this.Instruction.Redo();
            }

            public void Undo()
            {
                this.Instruction.Undo();
            }
        }

        public int BoardNumber
        {
            get
            {
                return Program.SpinAPI.CurrentBoard;
            }
            set
            {
                try
                {
                    Program.SpinAPI.CurrentBoard = value;
                }
                catch (Exception)
                {
                }
                // if BoardNumberUpDown has been loaded, we should set that too.
                if (this.BoardNumberUpDown != null)
                    this.BoardNumberUpDown.Value = Program.SpinAPI.CurrentBoard;
            }
        }

        #region Constructors

        public MainForm()
        {
            InitializeComponent();

            // Initialize all member variables in the constructor.
            this.History = new Stack<Command>();
            this.Future = new Stack<Command>();

            if (Program.SpinAPI.BoardCount > 0)
                this.BoardNumber = MainForm.BoardNumberDefault;

            Program.SpinAPI.BoardCountChanged += new EventHandler(this.SpinAPI_BoardCountChanged);
        }

        #endregion

        private void MainForm_Load(object sender, EventArgs e)
        {
            // Can only change board number if there are boards.
            this.BoardNumberUpDown.Enabled = (Program.SpinAPI.BoardCount > 0);

            // BoardNumberUpDown.Maximum is one less than the number of boards.
            // But, if there are no boards, it must be set to 0 so setting Value
            // does not throw an OutOfBoundsException.
            this.BoardNumberUpDown.Maximum = (Program.SpinAPI.BoardCount > 0) ? Program.SpinAPI.BoardCount - 1 : 0;
            this.BoardNumberUpDown.Value = this.BoardNumber;

            // Can only use the board control buttons if there are boards.
            this.ControlGroupBox.Enabled = (Program.SpinAPI.BoardCount > 0);

            // Display the firmware id of the board if there is one.
            this.FirmwareIDTextBox.Text = (Program.SpinAPI.BoardCount > 0) ? this.FirmwareID(this.BoardNumber) : "";

            this.VersionTextBox.Text = Program.SpinAPI.Version;

            this.ClockFreqTextbox.Text = ClockFrequency.ToString();

            // Set some minimum number of instructions for the program specified
            // by InitialInstructionCount and prepare some PBInstructionControls.
            for (int i = 0; i < MainForm.InitialInstructionCount; i++)
            {
                PBInstructionBox Instruction = new PBInstructionBox();
                Instruction.ValueChanged += new EventHandler(this.Instruction_ValueChanged);
                Instruction.Number = this.InstructionLayoutPanel.Controls.Count;
                try
                {
                    Instruction.Style = LookupStyle(Program.SpinAPI.GetFirmwareID(this.BoardNumber));
                }
                catch (SpinAPIException exc)
                {

                    MessageBox.Show("Can not detect board. Please check connections.", exc.Source);
                    Close();
                }
                InstructionLayoutPanel.Controls.Add(Instruction);
            }

            if (this.InstructionLayoutPanel.Controls.Count > 0)
            {
                // We're using the padding setting of InstructionLayoutPanel to center the
                // PBInstructionBox controls inside.
                int SidePadding = (this.InstructionLayoutPanel.Width - InstructionLayoutPanel.Controls[0].Width) / 2;

                this.InstructionLayoutPanel.Padding = new Padding(SidePadding, 5, SidePadding, 5);
            }

            // The following menu items are not implemented and thus left invisible.
            this.UndoEditMenuStripItem.Enabled = false;
            this.RedoEditMenuStripItem.Enabled = false;

            PrintFileMenuStripItem.Visible = false;
            PrintPreviewFileMenuStripMenuItem.Visible = false;
            FileMenuStripSeparator2.Visible = false;

            EditMenuStripSeparator0.Visible = false;
            CutEditMenuStripItem.Visible = false;
            CopyEditMenuStripItem.Visible = false;
            PasteEditMenuStripItem.Visible = false;
            EditMenuStripSeparator1.Visible = false;
            SelectAllEditMenuStripItem.Visible = false;

            ToolsMenuStripItem.Visible = false;

            ContentsHelpMenuStripItem.Visible = false;
            IndexHelpMenuStripItem.Visible = false;
            SearchHelpMenuStripItem.Visible = false;
            HelpMenuStripSeparator0.Visible = false;
        }

        /// <summary>
        /// The user only sets this.BoardNumber when she leaves the control. A few
        /// constraints on the value are applied, if passed, this.BoardNumber is set,
        /// otherwise it, the user is show a message box and the value is reset to the
        /// last good value.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void BoardNumberUpDown_Leave(object sender, EventArgs e)
        {
            try
            {
                this.BoardNumber = Convert.ToInt32(BoardNumberUpDown.Value);
                this.LastGoodBoardNumber = this.BoardNumber;

                this.FirmwareIDTextBox.Text = (Program.SpinAPI.BoardCount > 0) ? FirmwareID(this.BoardNumber) : "";
                foreach (Control Control in this.InstructionLayoutPanel.Controls)
                    ((PBInstructionBox)Control).Style = LookupStyle(Program.SpinAPI.GetFirmwareID(this.BoardNumber));
            }
            catch (ArgumentException)
            {
                // Bother the user about attempting to set an invalid board number.
                MessageBox.Show("Invalid board number. (Choose a value between 0 and " + (Program.SpinAPI.BoardCount - 1).ToString() + ".)");
                // Reset BoardNumber and BoardNumberUpDown.Value.
                BoardNumber = LastGoodBoardNumber;
                this.BoardNumberUpDown.Value = this.BoardNumber;
            }
        }

        private void Instruction_ValueChanged(object sender, EventArgs e)
        {
            // Don't execute the command as PBInstructionControl has taken care of that;
            // we just add it to the history stack.
            History.Push(new ChangeInstructionCommand(this, (PBInstructionBox)sender));
            UndoEditMenuStripItem.Enabled = true;

            // The user is moving in a new direction, so there are no more redos to be performed.
            // Clear out the future action stack. It would be best to clear the future state
            // stacks of all the PBInstructionBoxes here too as to prevent a memory leak, but I
            // can't think of a good object oriented way to do that yet.
            Future.Clear();
            RedoEditMenuStripItem.Enabled = false;
        }

        private void InstructionCountUpDown_ValueChanged(object sender, EventArgs e)
        {
            Command Command;

            int OldInstructionCount = this.InstructionLayoutPanel.Controls.Count;
            int NewInstructionCount = (int)this.InstructionCountUpDown.Value;

            if (NewInstructionCount > OldInstructionCount)
            {
                for (int i = OldInstructionCount; i < NewInstructionCount; i++)
                {
                    PBInstructionBox Instruction = new PBInstructionBox();
                    Instruction.ValueChanged += new EventHandler(Instruction_ValueChanged);

                    Command = new AddInstructionCommand(this, Instruction);
                    Command.Execute();
                    History.Push(Command);

                    Future.Clear();
                    RedoEditMenuStripItem.Enabled = false;
                }
            }
            else if (NewInstructionCount < OldInstructionCount)
            {
                for (int i = OldInstructionCount; i > NewInstructionCount; i--)
                {

                    PBInstructionBox Instruction = (PBInstructionBox)InstructionLayoutPanel.Controls[InstructionLayoutPanel.Controls.Count - 1];

                    Command = new RemoveInstructionCommand(this, Instruction);
                    Command.Execute();
                    History.Push(Command);

                    Future.Clear();
                    RedoEditMenuStripItem.Enabled = false;
                }
            }

            this.UndoEditMenuStripItem.Enabled = true;
        }

        private void LoadBoardButton_Click(object sender, EventArgs e)
        {
            try
            {
                // Initialize the board
                Program.SpinAPI.Init();

                // Set the clock
                Program.SpinAPI.SetClock(ClockFrequency);

                // Start programming
                Program.SpinAPI.StartProgramming(ProgramTarget.PULSE_PROGRAM);

                // Load the instructions
                foreach (Control Control in this.InstructionLayoutPanel.Controls)
                {
                    PBInstructionBox Instruction = (PBInstructionBox)Control;

                    Program.SpinAPI.PBInst(Instruction.Flags, Instruction.OpCode, Instruction.Data, Instruction.Duration, Instruction.TimeUnit);
                }

                // Stop programming
                Program.SpinAPI.StopProgramming();

                // Report success
                MessageBox.Show("Loaded board successfully.");
            }
            catch (SpinAPIException ex)
            {
                // Report any programming errors
                MessageBox.Show("Failed to program board: " + ex.Message);
            }
        }

        private void StartButton_Click(object sender, EventArgs e)
        {
            Program.SpinAPI.Start();
        }

        private void StopButton_Click(object sender, EventArgs e)
        {
            Program.SpinAPI.Stop();
        }

        private void LinkTextBox_LinkClicked(object sender, LinkClickedEventArgs e)
        {
            try
            {
                System.Diagnostics.Process.Start(e.LinkText);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
            }
        }
        
        private void SpinAPI_BoardCountChanged(Object sender, EventArgs e)
        {
            int BoardCount = Program.SpinAPI.BoardCount;
            if (BoardCount < 1)
            {
                EnableControl(ControlGroupBox, false);

                EnableControl(BoardNumberUpDown, false);
                BoardNumber = MainForm.BoardNumberDefault;
                LastGoodBoardNumber = BoardNumber;
                SetUpDownValue(BoardNumberUpDown, LastGoodBoardNumber);
                SetUpDownMaximum(BoardNumberUpDown, 0);

                UpdateTextBox(FirmwareIDTextBox, "");

                foreach (Control Control in InstructionLayoutPanel.Controls)
                    SetInstructionStyle((PBInstructionBox)Control, PBInstructionBox.FlagStyle.PB24);
            }
            else
            {
                EnableControl(ControlGroupBox, true);

                EnableControl(BoardNumberUpDown, true);
                SetUpDownMaximum(BoardNumberUpDown, BoardCount - 1);

                if (Program.SpinAPI.CurrentBoard >= BoardCount)
                {
                    Program.SpinAPI.CurrentBoard = BoardCount - 1;
                    LastGoodBoardNumber = Program.SpinAPI.CurrentBoard - 1;
                    SetUpDownValue(BoardNumberUpDown, LastGoodBoardNumber);
                }

                UpdateTextBox(FirmwareIDTextBox, FirmwareID(BoardNumber));

                foreach (Control Control in InstructionLayoutPanel.Controls)
                    SetInstructionStyle((PBInstructionBox)Control, LookupStyle(Program.SpinAPI.GetFirmwareID(this.BoardNumber)));
            }
        }

        #region UpdateInvoke
        public delegate void UpdateTextBoxCallback(TextBox textBox, string text);
        public void UpdateTextBox(TextBox textbox, string str)
        {
            try
            {
                if (textbox.InvokeRequired)
                    Invoke(new UpdateTextBoxCallback(UpdateTextBox), new object[] { textbox, str });
                else
                    textbox.Text = str;
            }
            catch (Exception)
            {
            }
        }
        public delegate void SetUpDownValueCallback(NumericUpDown UpDown, decimal Value);
        public void SetUpDownValue(NumericUpDown UpDown, decimal Value)
        {
            try
            {
                if (UpDown.InvokeRequired)
                    Invoke(new SetUpDownValueCallback(SetUpDownValue), new object[] { UpDown, Value});
                else
                    UpDown.Value = Value;
            }
            catch (Exception)
            {
            }
        }
        public delegate void SetUpDownMaximumCallback(NumericUpDown UpDown, decimal Maximum);
        public void SetUpDownMaximum(NumericUpDown UpDown, decimal Maximum)
        {
            try
            {
                if (UpDown.InvokeRequired)
                    Invoke(new SetUpDownMaximumCallback(SetUpDownMaximum), new object[] { UpDown, Maximum });
                else
                    UpDown.Maximum = Maximum;
            }
            catch (Exception)
            {
            }
        }
        public delegate void EnableControlCallback(Control Control, bool Enabled);
        public void EnableControl(Control Control, bool Enabled)
        {
            try
            {
                if (Control.InvokeRequired)
                    Invoke(new EnableControlCallback(EnableControl), new object[] { Control, Enabled });
                else
                    Control.Enabled = Enabled;
            }
            catch (Exception)
            {
            }
        }
        public delegate void SetInstructionStyleCallback(PBInstructionBox Instruction, PBInstructionBox.FlagStyle Style);
        public void SetInstructionStyle(PBInstructionBox Instruction, PBInstructionBox.FlagStyle Style)
        {
            try
            {
                if (Instruction.InvokeRequired)
                    Invoke(new SetInstructionStyleCallback(SetInstructionStyle), new object[] { Instruction, Style });
                else
                    Instruction.Style = Style;
            }
            catch (Exception)
            {
            }
        }
        //public delegate void UpdateToolStripCallBack(ToolStripStatusLabel stripTextBox, string str);
        //public void UpdateToolStrip(ToolStripStatusLabel stripTextBox, string str)
        //{
        //    try
        //    {
        //        if (stripTextBox.InvokeRequired)
        //            Invoke(new UpdateToolStripCallBack(UpdateToolStrip), new object[] { stripTextBox, str });
        //        else
        //            stripTextBox.text = str;
        //    }
        //    catch (Exception)
        //    {
        //    }
        //}
        #endregion

        private void AboutHelpMenuStripItem_Click(object sender, EventArgs e)
        {
            AboutForm AboutForm = new AboutForm();
            AboutForm.ShowDialog();
        }

        private void ExitFileMenuStripItem_Click(object sender, EventArgs e)
        {
            if (!ContinueWithUnsavedChanges())
                return;

            Close();
        }

        private void InstructionLayoutPanel_Resize(object sender, EventArgs e)
        {
            int SidePadding = (InstructionLayoutPanel.Width - InstructionLayoutPanel.Controls[0].Width) / 2;
            InstructionLayoutPanel.Padding = new Padding(SidePadding, 5, SidePadding, 5);
        }

        private void NewFileStripMenuItem_Click(object sender, EventArgs e)
        {
            if (!ContinueWithUnsavedChanges())
                return;

            // This fires a ValueChanged event on InstructionCountUpDown, so it's before setting the new blank instructions.
            InstructionCountUpDown.Value = 2;

            InstructionLayoutPanel.Controls.Clear();

            for (int i = 0; i < InstructionCountUpDown.Value; i++)
            {
                PBInstructionBox InstructionControl = new PBInstructionBox();
                InstructionLayoutPanel.Controls.Add(InstructionControl);
                // Index instructions from zero.
                InstructionControl.Number = InstructionLayoutPanel.Controls.Count - 1;
            }

            CurrentFileName = "";
        }

        private void SaveFileMenuStripItem_Click(object sender, EventArgs e)
        {
            SaveToFile(CurrentFileName);
        }

        /// <summary>
        /// Check the instructions for unsaved changes. If there are, prompt the user for whether to continue.
        /// </summary>
        /// <returns>true if there are no unsaved changes or the user has chosen to disregard unsaved changes, false otherwise.</returns>
        private bool ContinueWithUnsavedChanges()
        {
            foreach (Control Control in InstructionLayoutPanel.Controls)
            {
                PBInstructionBox InstructionControl = (PBInstructionBox)Control;

                if (InstructionControl.Edited)
                {
                    DialogResult Result = MessageBox.Show("The current program has unsaved changes. Continue?", "Unsaved Changes...", MessageBoxButtons.YesNo);
                    if (Result == DialogResult.Yes)
                        return true;
                    else
                        return false;
                }
            }

            return true;
        }

        private bool SaveToFile(string FileName)
        {
            StreamWriter StreamWriter;

            if (FileName.Length == 0) {
                SaveFileDialog SaveFileDialog = new SaveFileDialog();
                SaveFileDialog.Filter = FileFilter;
                SaveFileDialog.RestoreDirectory = true;

                if (SaveFileDialog.ShowDialog() != DialogResult.OK)
                    return false;

                StreamWriter = new StreamWriter(SaveFileDialog.OpenFile());
                FileName = SaveFileDialog.FileName;
            }
            else
            {
                StreamWriter = new StreamWriter(FileName);   
            }

            foreach (Control Control in InstructionLayoutPanel.Controls)
            {
                PBInstructionBox InstructionControl = (PBInstructionBox)Control;

                StreamWriter.WriteLine(InstructionControl.ToString());
                InstructionControl.Edited = false;
            }

            StreamWriter.Close();

            return true;
        }

        private void OpenFileMenuStripItem_Click(object sender, EventArgs e)
        {
            Stream Stream;
            StreamReader StreamReader;
            OpenFileDialog OpenFileDialog = new OpenFileDialog();

            if (!ContinueWithUnsavedChanges())
                return;

            OpenFileDialog.Filter = FileFilter;
            OpenFileDialog.RestoreDirectory = true;

            if (OpenFileDialog.ShowDialog() != DialogResult.OK)
                return;

            Stream = OpenFileDialog.OpenFile();
            
            // An exception should probably be thrown if this happens, but for now, return.
            if (Stream == null)
                return;

            StreamReader = new StreamReader(Stream);

            CurrentFileName = OpenFileDialog.FileName;

            InstructionLayoutPanel.Controls.Clear();

            while (!StreamReader.EndOfStream)
            {
                string[] Fields = StreamReader.ReadLine().Split(new char[] {' '});
                PBInstructionBox InstructionControl = new PBInstructionBox();
                InstructionLayoutPanel.Controls.Add(InstructionControl);
                InstructionControl.Flags = int.Parse(Fields[0], System.Globalization.NumberStyles.AllowHexSpecifier);
                InstructionControl.OpCode = (OpCode)int.Parse(Fields[1], System.Globalization.NumberStyles.AllowHexSpecifier);
                InstructionControl.Data = int.Parse(Fields[2], System.Globalization.NumberStyles.AllowHexSpecifier);
                InstructionControl.Duration = double.Parse(Fields[3]);
                InstructionControl.TimeUnit = (TimeUnit)Enum.Parse(typeof(TimeUnit), Fields[4]);
                InstructionControl.Number = InstructionLayoutPanel.Controls.Count - 1;
                InstructionControl.Edited = false;
            }

            InstructionCountUpDown.Value = InstructionLayoutPanel.Controls.Count;

            StreamReader.Close();
        }

        private void SaveAsFileMenuStripItem_Click(object sender, EventArgs e)
        {
            // Force the SaveFileDialog to appear.
            SaveToFile("");
        }

        private string FirmwareID(int BoardNumber)
        {
            int FirmwareID;

            FirmwareID = Program.SpinAPI.GetFirmwareID(BoardNumber);
            return string.Format("{0:D2}-{1:D2}", (FirmwareID & 0xFF00) >> 8, (FirmwareID & 0x00FF));
        }

        private void UndoEditMenuStripItem_Click(object sender, EventArgs e)
        {
            if (History.Count == 0)
                return;

            Command Command = History.Pop();

            Command.Undo();

            Future.Push(Command);

            RedoEditMenuStripItem.Enabled = true;

            if (History.Count == 0)
                UndoEditMenuStripItem.Enabled = false;
        }

        private void RedoEditMenuStripItem_Click(object sender, EventArgs e)
        {
            if (Future.Count == 0)
                return;

            Command Command = Future.Pop();

            Command.Execute();

            History.Push(Command);

            UndoEditMenuStripItem.Enabled = true;

            if (Future.Count == 0)
                RedoEditMenuStripItem.Enabled = false;
        }

        static private int LookupClockFrequency(int FirmwareID)
        {
            int ClockFrequency;

            switch (FirmwareID)
            {
                case 0x0D01:
                    ClockFrequency = 100000000;
                    break;
                case 0x0D1B:
                    ClockFrequency = 100000000;
                    break;
                case 0x0D02:
                    ClockFrequency = 100000000;
                    break;
                case 0x0D08: 
                    ClockFrequency = 100000000;
                    break;
                case 0x0D09:
                    ClockFrequency = 100000000;
                    break;
                case 0x0D0A:
                    ClockFrequency = 200000000;
                    break;
                case 0x0D0B:
                    ClockFrequency = 100000000;
                    break;
                default:
                    ClockFrequency = 100000000;
                    break;
            }

            if (ClockFrequency == 0)
                throw new Exception();

            return ClockFrequency;
        }

        static private int LookupCycleOffset(int FirmwareID)
        {
            int CycleOffset;

            switch (FirmwareID)
            {
                case 0x0D01:
                    CycleOffset = 3;
                    break;
                case 0x0D1B:
                    CycleOffset = 3;
                    break;
                case 0x0D02:
                    CycleOffset = 3;
                    break;
                case 0x0D08:
                    CycleOffset = 3;
                    break;
                case 0x0D09:
                    CycleOffset = 3;
                    break;
                case 0x0D0A:
                    CycleOffset = 3;
                    break;
                case 0x0D0B:
                    CycleOffset = 3;
                    break;
                default:
                    CycleOffset = 0;
                    break;
            }

            //if (CycleOffset == 0)
                //throw new Exception();

            return CycleOffset;
        }

        static private PBInstructionBox.FlagStyle LookupStyle(int FirmwareID)
        {
            PBInstructionBox.FlagStyle Style;

            switch (FirmwareID)
            {
                case 0x0D01:
                    Style = PBInstructionBox.FlagStyle.PB24;
                    break;
                case 0x0D1B:
                    Style = PBInstructionBox.FlagStyle.PB24;
                    break;
                case 0x0D02:
                    Style = PBInstructionBox.FlagStyle.PB24;
                    break;
                case 0x0D08:
                    Style = PBInstructionBox.FlagStyle.PB24;
                    break;
                case 0x0D09:
                    Style = PBInstructionBox.FlagStyle.PB24;
                    break;
                case 0x0D0A:
                    Style = PBInstructionBox.FlagStyle.PB24;
                    break;
                case 0x0D0B:
                    Style = PBInstructionBox.FlagStyle.PB24;
                    break;
                default:
                    Style = PBInstructionBox.FlagStyle.PB24;
                    break;
            }

            return Style;
        }

        private void ClockFreqTextbox_TextChanged(object sender, EventArgs e)
        {
            ClockFrequency = Double.Parse(ClockFreqTextbox.Text);
        }


    }
}
