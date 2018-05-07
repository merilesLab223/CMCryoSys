using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Tester
{
    class Program
    {
        static void Main(string[] args)
        {
            bool doSelfServer = false;
            CSCom.CSCom server = null;
            if (doSelfServer)
            {
                server = new CSCom.CSCom();
                server.LogMethod = (d, s) =>
                {
                    Console.WriteLine(d.ToString());
                };
                server.Listen();
                server.MessageRecived += Server_MessageRecived;
            }
            CSCom.CSCom clinet = new CSCom.CSCom();
            clinet.LogMethod = (d, s) =>
            {
                Console.WriteLine(d.ToString());
            };
            clinet.Connect();
            System.Threading.Thread.Sleep(100);
            if(clinet.WS.IsAlive)
            {
                Console.WriteLine("Connected to server.");
                CSCom.NPMessageNamepathData data = new CSCom.NPMessageNamepathData();
                float[] valToSend = new float[10000];
                valToSend[9999] = 23;
                data.Value = valToSend;
                data.Namepath = "lama";
                clinet.Send(new CSCom.NPMessage(new CSCom.NPMessageNamepathData[] { data }));
                System.Threading.Thread.Sleep(100);

                Console.WriteLine("Press <enter> to exit.");

                if(doSelfServer)
                    Console.ReadLine();
                
                clinet.Disconnect();
                clinet.Dispose();
                clinet = null;
            }
            else
            {
                Console.WriteLine("Could not connect.");
                Console.WriteLine("Press <enter> to exit.");
                Console.ReadLine();
            }

            if (doSelfServer)
            {
                server.StopListening();
                server.Dispose();
                server = null;
            }
        }

        private static void Server_MessageRecived(object sender, EventArgs e)
        {
            CSCom.CSCom server = (CSCom.CSCom)sender;
            CSCom.NPMessage map = server.PendingMessages.Dequeue();
            Console.WriteLine("Recived map with " + map.Namepaths.Count + " name paths");
        }
    }
}
