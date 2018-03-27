using System;
using System.Windows.Forms;

namespace PulseBlasterNET
{
    public class Memento
    {
        protected object _Parent;

        public object Parent
        {
            get
            {
                return _Parent;
            }
        }

        public Memento(object Parent)
        {
            _Parent = Parent;
        }
    }
}
