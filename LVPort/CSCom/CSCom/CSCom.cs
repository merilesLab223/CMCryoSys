using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CSCom
{
    /// <summary>
    /// Imeplements a CS communication that allows for namepath data sending.
    /// </summary>
    public class CSCom : WebsocketPipe.WebsocketPipe<NPMessage>
    {
        /// <summary>
        /// Create a new com service that can connect or listen at the comServiceAddress
        /// </summary>
        /// <param name="comServiceAddress">The addres of the service, the schema must be ws://. i.e. "ws://localhost:50000/CScom"</param>
        public CSCom(string comServiceAddress = "ws://localhost:50000/CScom")
            : base(new Uri(comServiceAddress),
                 new WebsocketPipe.WebsocketPipeBinaryFormatingDataSerializer<NPMessage>())
        {
            this.LogMethod = (d, s) =>
            {
                if (DoLogging && Log != null)
                    Log(this, new LogEventArgs(d.ToString()));
            };
        }

        ~CSCom()
        {
            try
            {
                Stop();
            }
            catch
            {
            }
        }

        public Queue<NPMessage> PendingMessages { get; private set; }= new Queue<NPMessage>();

        /// <summary>
        /// If true then call log events.
        /// </summary>
        public bool DoLogging { get; set; } = false;

        public class LogEventArgs : EventArgs
        {
            public LogEventArgs(string msg="")
            {
                Message = msg;
            }

            public string Message { get; private set; } = "";
        }

        public event EventHandler<LogEventArgs> Log;
    }
}
