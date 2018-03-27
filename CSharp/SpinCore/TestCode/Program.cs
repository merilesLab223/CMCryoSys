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
using System.Runtime.InteropServices;
using System.Windows.Forms;
using SpinCore.SpinAPI;

namespace PulseBlasterNET
{
    static class Program
    {
        public static SpinAPI SpinAPI;

        [DllImport("kernel32.dll", EntryPoint = "LoadLibrary")]
        static extern int LoadLibrary([MarshalAs(UnmanagedType.LPStr)] string lpLibFileName);

        [DllImport("kernel32.dll", EntryPoint = "GetProcAddress")]
        static extern IntPtr GetProcAddress(int hModule,[MarshalAs(UnmanagedType.LPStr)] string lpProcName);

        [DllImport("kernel32.dll", EntryPoint = "FreeLibrary")]
        static extern bool FreeLibrary(int hModule);

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
#if WIN64
            int spinapilibid = LoadLibrary(@"C:\SpinCore\SpinAPI\lib\spinapi64.dll");
#else
            int spinapilibid = LoadLibrary(@"C:\SpinCore\SpinAPI\lib32\spinapi.dll");
#endif

            if (SpinAPI == null)
                SpinAPI = new SpinAPI();

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm());

            FreeLibrary(spinapilibid);
        }
    }
}
