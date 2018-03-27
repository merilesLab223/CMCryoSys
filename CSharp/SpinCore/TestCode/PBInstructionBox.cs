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
using System.Drawing;
using System.Windows.Forms;
using System.Collections.Generic;
using SpinCore.SpinAPI;

namespace PulseBlasterNET
{
    /// <summary>
    /// PBInstructionBox is a user interface element to represent a PulseBlaster instruction.
    /// </summary>
    public partial class PBInstructionBox : UserControl
    {
        private const int DataDefault = 0;
        private const double DurationDefault = 1.0;
        private const int FlagsDefault = 0;
        private const OpCode OpCodeDefault = OpCode.CONTINUE;

        private const FlagStyle StyleDefault = PBInstructionBox.FlagStyle.PB24;
        private const TimeUnit TimeUnitDefault = TimeUnit.ms;

        private Stack<PBInstructionMemento> History;
        private Stack<PBInstructionMemento> Future;

        private CheckBox[] FlagCheckBoxes;

        private int _Data;
        private double _Duration;
        private int _Flags;
        private OpCode _OpCode;
        private FlagStyle _Style;
        private TimeUnit _TimeUnit;

        private int LastGoodDataValue;
        private string LastGoodDurationText;

        private bool _Edited;

        public class PBInstructionMemento : Memento
        {
            protected double _Duration;
            protected TimeUnit _TimeUnit;
            protected int _Flags;
            protected OpCode _OpCode;
            protected int _Data;

            public double Duration
            {
                get
                {
                    return _Duration;
                }
            }

            public TimeUnit TimeUnit
            {
                get
                {
                    return _TimeUnit;
                }
            }

            public int Flags
            {
                get
                {
                    return _Flags;
                }
            }

            public OpCode OpCode
            {
                get
                {
                    return _OpCode;
                }
            }

            public int Data
            {
                get
                {
                    return _Data;
                }
            }

            public PBInstructionMemento(PBInstructionBox Parent)
                : base(Parent)
            {
                _Duration = Parent.Duration;
                _TimeUnit = Parent.TimeUnit;
                _Flags = Parent.Flags;
                _OpCode = Parent.OpCode;
                _Data = Parent.Data;
            }
        }

        public enum FlagStyle : int
        {
            PB24,
            PB16,
            PB12,
            PBESRPRO
        }

        #region Attributes

        /// <summary>
        /// The data field of the instruction.
        /// </summary>
        public int Data
        {
            get
            {
                return _Data;
            }
            set
            {
                History.Push(new PBInstructionMemento(this));
                _Data = value;
                if (DataBox != null)
                {
                    DataBox.ValueChanged -= DataBox_ValueChanged;
                    DataBox.Value = _Data;
                    DataBox.ValueChanged += DataBox_ValueChanged;
                }

                OnValueChanged(EventArgs.Empty);
            }
        }

        /// <summary>
        /// Time duration of the instruction.
        /// </summary>
        public double Duration
        {
            get
            {
                return _Duration;
            }
            set
            {
                History.Push(new PBInstructionMemento(this));
                _Duration = value;
                if (DurationTextBox != null)
                {
                    DurationTextBox.TextChanged -= DurationTextBox_TextChanged;
                    DurationTextBox.Text = _Duration.ToString();
                    DurationTextBox.TextChanged += DurationTextBox_TextChanged;
                }

                OnValueChanged(EventArgs.Empty);
            }
        }

        /// <summary>
        /// The value of the flags field of the instruction.
        /// </summary>
        public int Flags
        {
            get
            {
                return _Flags;
            }
            set
            {
                History.Push(new PBInstructionMemento(this));
                _Flags = value;
                for (int i = 0; i < FlagCheckBoxes.Length; i++)
                {
                    if (FlagCheckBoxes[i] != null)
                    {
                        FlagCheckBoxes[i].CheckedChanged -= FlagCheckBox_CheckedChanged;
                        FlagCheckBoxes[i].Checked = ((_Flags & (1 << (23 - i))) != 0);
                        FlagCheckBoxes[i].CheckedChanged += FlagCheckBox_CheckedChanged;
                    }
                }

                OnValueChanged(EventArgs.Empty);
            }
        }

        /// <summary>
        /// The flow control OpCode associated with the instruction.
        /// </summary>
        public OpCode OpCode
        {
            get
            {
                return _OpCode;
            }
            set
            {
                History.Push(new PBInstructionMemento(this));
                _OpCode = value;
                if (OpCodeComboBox != null)
                {
                    OpCodeComboBox.SelectedIndexChanged -= OpCodeComboBox_SelectedIndexChanged;
                    OpCodeComboBox.SelectedIndex = OpCodeComboBox.FindString(_OpCode.ToString());
                    OpCodeComboBox.SelectedIndexChanged += OpCodeComboBox_SelectedIndexChanged;
                }

                OnValueChanged(EventArgs.Empty);
            }
        }

        public FlagStyle Style
        {
            get
            {
                return _Style;
            }
            set
            {
                _Style = value;

                if (FlagCheckBoxes != null)
                {
                    switch (_Style)
                    {
                        case FlagStyle.PB24:
                            for (int i = 0; i < FlagCheckBoxes.Length; i++)
                            {
                                FlagCheckBoxes[i].BackColor = SystemColors.Control;
                                FlagCheckBoxes[i].Enabled = true;
                            }
                            break;
                        case FlagStyle.PB16:
                            for (int i = 0; i < FlagCheckBoxes.Length; i++)
                            {
                                FlagCheckBoxes[i].BackColor = SystemColors.Control;

                                if ((23 - i) < 16)
                                    FlagCheckBoxes[i].Enabled = true;
                                else
                                    FlagCheckBoxes[i].Enabled = false;
                            }
                            break;
                        case FlagStyle.PB12:
                            for (int i = 0; i < FlagCheckBoxes.Length; i++)
                            {
                                FlagCheckBoxes[i].BackColor = SystemColors.Control;

                                if ((23 - i) < 12)
                                    FlagCheckBoxes[i].Enabled = true;
                                else
                                    FlagCheckBoxes[i].Enabled = false;
                            }
                            break;
                        case FlagStyle.PBESRPRO:
                            for (int i = 0; i < FlagCheckBoxes.Length; i++)
                            {
                                if ((23 - i) > 20)
                                    FlagCheckBoxes[i].BackColor = Color.Red;
                                else
                                    FlagCheckBoxes[i].BackColor = SystemColors.Control;

                                FlagCheckBoxes[i].Enabled = true;
                            }
                            break;
                    }
                }
            }
        }
        
        /// <summary>
        /// The timing unit associated with the duration of the instruction.
        /// <see cref="SpinAPI.TimingUnit"/>
        /// </summary>
        public TimeUnit TimeUnit
        {
            get
            {
                return _TimeUnit;
            }
            set
            {
                History.Push(new PBInstructionMemento(this));
                _TimeUnit = value;
                if (TimeUnitComboBox != null)
                {
                    TimeUnitComboBox.SelectedIndexChanged -= TimeUnitComboBox_SelectedIndexChanged;
                    TimeUnitComboBox.SelectedIndex = TimeUnitComboBox.FindString(_TimeUnit.ToString());
                    TimeUnitComboBox.SelectedIndexChanged += TimeUnitComboBox_SelectedIndexChanged;
                }

                OnValueChanged(EventArgs.Empty);
            }
        }

        /// <summary>
        /// The instruction number.
        /// </summary>
        public int Number
        {
            get
            {
                return int.Parse(InstructionNumberLabel.Text);
            }
            set
            {
                InstructionNumberLabel.Text = value.ToString();
            }
        }

        /// <summary>
        /// Whether or not the control has been edited lately.
        /// </summary>
        public bool Edited
        {
            get
            {
                return _Edited;
            }
            set
            {
                _Edited = value;
            }
        }

        #endregion

        #region Constructors

        public PBInstructionBox()
        {
            InitializeComponent();

            // Number of TTL outputs on PulseBlaster is 24
            FlagCheckBoxes = new CheckBox[24];

            History = new Stack<PBInstructionMemento>();
            Future = new Stack<PBInstructionMemento>();

            _Data = DataDefault;
            LastGoodDataValue = _Data;

            _Duration = DurationDefault;
            LastGoodDurationText = _Duration.ToString();

            _Flags = FlagsDefault;

            _OpCode = OpCodeDefault;

            _Style = FlagStyle.PB24;

            _TimeUnit = TimeUnitDefault;

            _Edited = true;

            DataBox.Value = LastGoodDataValue;

            DurationTextBox.Text = LastGoodDurationText;

            // Literal values for check box sizes were calculated by hand
            for (int i = 0; i < 24; i++)
            {
                FlagCheckBoxes[i] = new CheckBox();
                FlagCheckBoxes[i].Text = (23 - i).ToString();
                FlagCheckBoxes[i].CheckAlign = ContentAlignment.TopCenter;
                FlagCheckBoxes[i].TextAlign = ContentAlignment.BottomCenter;
                FlagCheckBoxes[i].Checked = (_Flags & (1 << (23 - i))) != 0;
                FlagCheckBoxes[i].Width = 23;
                FlagCheckBoxes[i].Height = 31;
                FlagCheckBoxes[i].Margin = new Padding(0);
                FlagCheckBoxes[i].CheckedChanged += new EventHandler(FlagCheckBox_CheckedChanged);
                FlagsLayoutPanel.Controls.Add(FlagCheckBoxes[i]);
            }

            OpCodeComboBox.SelectedIndexChanged -= OpCodeComboBox_SelectedIndexChanged;
            OpCodeComboBox.DataSource = Enum.GetValues(typeof(OpCode));
            OpCodeComboBox.SelectedIndex = OpCodeComboBox.FindString(_OpCode.ToString());
            OpCodeComboBox.SelectedIndexChanged += OpCodeComboBox_SelectedIndexChanged;

            TimeUnitComboBox.SelectedIndexChanged -= TimeUnitComboBox_SelectedIndexChanged;
            TimeUnitComboBox.DataSource = Enum.GetValues(typeof(TimeUnit));
            TimeUnitComboBox.SelectedIndex = TimeUnitComboBox.FindString(_TimeUnit.ToString());
            TimeUnitComboBox.SelectedIndexChanged += TimeUnitComboBox_SelectedIndexChanged;
        }

        #endregion

        #region Events

        public event EventHandler ValueChanged;

        protected virtual void OnValueChanged(EventArgs e)
        {
            if (Future != null)
                Future.Clear();

            if (ValueChanged != null)
                ValueChanged(this, e);
        }

        #endregion

        #region EventHandlers

        private void PBControl_Load(object sender, EventArgs e)
        {
        }

        private void DataBox_ValueChanged(object sender, EventArgs e)
        {
            int i;

            try
            {
                i = Convert.ToInt32(DataBox.Value);
            }
            catch (Exception)
            {
                return;
            }

            if (i < 65535)
                LastGoodDataValue = i;
        }

        private void DataBox_Leave(object sender, EventArgs e)
        {
            int i;

            try
            {
                i = Convert.ToInt32(DataBox.Value);
            }
            catch (Exception)
            {
                MessageBox.Show("Invalid data value.");
                DataBox.Value = LastGoodDataValue;

                return;
            }

            if (i > 65535)
            {
                MessageBox.Show("Data value out of range.");
                DataBox.Value = LastGoodDataValue;
            }
            else
            {
                Data = i;
                Edited = true;
            }
        }

        private void DurationTextBox_TextChanged(object sender, EventArgs e)
        {
            double d;

            try
            {
                d = double.Parse(DurationTextBox.Text);
            }
            catch (Exception)
            {
                return;
            }
            if (d > 0)
                LastGoodDurationText = DurationTextBox.Text;
        }

        private void DurationTextBox_Leave(object sender, EventArgs e)
        {
            double d;

            try
            {
                d = double.Parse(DurationTextBox.Text);
            }
            catch (Exception)
            {
                MessageBox.Show("Invalid duration value.");
                DurationTextBox.Text = LastGoodDurationText;

                return;
            }
            if (d <= 0)
            {
                MessageBox.Show("Duration value must be greater than zero.");
                DurationTextBox.Text = LastGoodDurationText;
            }
            else
            {
                Duration = d;
                Edited = true;
            }
        }

        private void FlagCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            int f = 0;

            for (int i = 0; i < FlagCheckBoxes.Length; i++)
            {
                // FlagCheckBoxes is indexed left to right on the GUI,
                // but the left most box referes to bit 23 on the
                // PulseBlaster.
                if (FlagCheckBoxes[i].Checked)
                    f += 1 << (23 - i);
            }

            Flags = f;

            Edited = true;
        }

        private void OpCodeComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            OpCode = (OpCode)OpCodeComboBox.SelectedValue;
            Edited = true;
        }

        private void TimeUnitComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            TimeUnit = (TimeUnit)TimeUnitComboBox.SelectedValue;
            Edited = true;
        }

        #endregion

        public override string ToString()
        {
            string String = "";

            String += String.Format("{0:X6}", Flags);
            String += " ";
            String += String.Format("{0:X1}", Convert.ToInt32(OpCode));
            String += " ";
            String += String.Format("{0:X5}", Data & 0xFFFFF);
            String += " ";
            String += Duration.ToString();
            String += " ";
            String += TimeUnit.ToString();

            return String;
        }

        public string ToHex(uint ClockFrequencyMHz, uint ClockCycleOffset)
        {
            string String = "";
            double ClockPeriod = (1 / ClockFrequencyMHz) * 10e-6;
            uint Length = Convert.ToUInt32(Duration * (int)TimeUnit) / 10 - ClockCycleOffset;

            String += String.Format("{0:X6}", Flags);
            String += " ";
            String += String.Format("{0:X1}", Convert.ToInt32(OpCode));
            String += " ";
            String += String.Format("{0:X5}", Data & 0xFFFFF);
            String += " ";
            String += String.Format("{0:X8}", Length);

            return String;
        }

        public string ToPBInterpreter()
        {
            string String = "";

            String += "Inst" + Number.ToString() + ":\t";
            String += "0b";

            for (int i = 0; i < FlagCheckBoxes.Length; i++)
            {
                if (FlagCheckBoxes[i].Checked)
                    String += "1";
                else
                    String += "0";
            }

            String += ", ";
            String += Duration.ToString();
            String += TimeUnit.ToString();

            String += ", ";
            String += OpCode.ToString();
            String += ", ";

            if (OpCode == OpCode.JSR || OpCode == OpCode.BRANCH)
            {
                String += "Inst";
            }

            String += Data.ToString();

            return String;
        }

        public void Undo()
        {
            if (History.Count == 0)
                return;

            Future.Push(new PBInstructionMemento(this));
            Restore(History.Pop());
        }

        public void Redo()
        {
            if (Future.Count == 0)
                return;

            History.Push(new PBInstructionMemento(this));
            Restore(Future.Pop());
        }

        public void Restore(PBInstructionMemento Memento)
        {
            _Data = Memento.Data;
            LastGoodDataValue = _Data;
            DataBox.ValueChanged -= DataBox_ValueChanged;
            DataBox.Value = LastGoodDataValue;
            DataBox.ValueChanged += DataBox_ValueChanged;

            _Duration = Memento.Duration;
            LastGoodDurationText = _Duration.ToString();
            DurationTextBox.TextChanged -= DurationTextBox_TextChanged;
            DurationTextBox.Text = LastGoodDurationText;
            DurationTextBox.TextChanged += DurationTextBox_TextChanged;

            _Flags = Memento.Flags;
            for (int i = 0; i < FlagCheckBoxes.Length; i++)
            {
                if (FlagCheckBoxes[i] != null)
                {
                    FlagCheckBoxes[i].CheckedChanged -= FlagCheckBox_CheckedChanged;
                    FlagCheckBoxes[i].Checked = ((_Flags & (1 << (23 - i))) != 0);
                    FlagCheckBoxes[i].CheckedChanged += FlagCheckBox_CheckedChanged;
                }
            }

            _OpCode = Memento.OpCode;
            OpCodeComboBox.SelectedIndexChanged -= OpCodeComboBox_SelectedIndexChanged;
            OpCodeComboBox.SelectedIndex = OpCodeComboBox.FindString(_OpCode.ToString());
            OpCodeComboBox.SelectedIndexChanged += OpCodeComboBox_SelectedIndexChanged;

            _TimeUnit = Memento.TimeUnit;
            TimeUnitComboBox.SelectedIndexChanged -= TimeUnitComboBox_SelectedIndexChanged;
            TimeUnitComboBox.SelectedIndex = TimeUnitComboBox.FindString(_TimeUnit.ToString());
            TimeUnitComboBox.SelectedIndexChanged += TimeUnitComboBox_SelectedIndexChanged;
        }
    }
}
