using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PulseBlasterNET
{
    public interface Command
    {
        void Execute();
        void Undo();
    }
}
