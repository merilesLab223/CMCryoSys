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
    public class CSCom
    {
        /// <summary>
        /// Create a new com service that can connect or listen at the comServiceAddress
        /// </summary>
        /// <param name="comServiceAddress">The addres of the service, the schema must be ws://. i.e. "ws://localhost:50000/CScom"</param>
        public CSCom(string comServiceAddress = "ws://localhost:50000/CScom")
        {
            Pipe = new WebsocketPipe.WebsocketPipe<NPMessage>(new Uri(comServiceAddress));

            Pipe.LogMethod = (d, s) =>
            {
                if (DoLogging && Log != null)
                    Log(this, new LogEventArgs(d.ToString()));
            };

            Pipe.MessageRecived += (s, e) =>
            {
                if (this.MessageRecived != null)
                    this.MessageRecived(this, new MessageEventArgs(e.Message));
            };
        }

        ~CSCom()
        {
            try
            {
                Pipe.Stop();
            }
            catch
            {
            }
        }

        #region Properties

        /// <summary>
        /// The websocket pipe to use.
        /// </summary>
        public WebsocketPipe.WebsocketPipe<NPMessage> Pipe { get; private set; }

        /// <summary>
        /// If true then call log events.
        /// </summary>
        public bool DoLogging { get; set; } = false;

        #endregion

        #region Events

        public class LogEventArgs : EventArgs
        {
            public LogEventArgs(string msg="")
            {
                Message = msg;
            }

            public string Message { get; private set; } = "";
        }

        public event EventHandler<LogEventArgs> Log;

        public class MessageEventArgs: EventArgs
        {
            public MessageEventArgs(NPMessage msg)
            {
                Message = msg;
            }

            public NPMessage Message { get; private set; }
        }

        public event EventHandler<MessageEventArgs> MessageRecived;

        #endregion

        #region Com

        public void Connect()
        {
            Pipe.Connect();
        }

        public void Listen()
        {
            Pipe.Listen();
        }

        public void Stop()
        {
            Pipe.Stop();
        }

        #endregion

        #region Sending and reciving

        /// <summary>
        /// Sends a message and waits for response if needed.
        /// </summary>
        /// <param name="msg"></param>
        /// <param name="requireResponse"></param>
        /// <returns></returns>
        public NPMessage Send(NPMessage msg, bool requireResponse = false)
        {
            NPMessage response = null;
            if (requireResponse)
                Pipe.Send(msg, (rsp) =>
                {
                    response = rsp;
                });
            else Pipe.Send(msg);

            return response;
        }

        #endregion
    }
}
