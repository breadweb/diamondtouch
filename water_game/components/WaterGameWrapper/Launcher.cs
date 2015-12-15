using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Management;
using System.Text;
using System.Windows.Forms;
using System.Xml;
using System.IO;

namespace WaterGameWrapper
{
    public partial class Launcher : Form
    {
        private bool autostart;
        private bool debug;
        private bool fullscreen;
        private bool enablelcd;
        private ArrayList flashWindows;

        public Launcher()
        {
            InitializeComponent();
        }

        private void btnStart_Click(object sender, EventArgs e)
        {
            launchWindows();
        }

        private void Launcher_Load(object sender, EventArgs e)
        {
            // Read in external settings
            string configFile = Application.StartupPath + "\\assets\\appconfig.xml";
            if (!File.Exists(configFile))
            {
                MessageBox.Show("Could not find " + configFile);
                return;
            }

            XmlDocument xmlDoc = new XmlDocument();
            try
            {
                xmlDoc.Load(configFile);
                XmlNode elm = xmlDoc.DocumentElement;
                foreach (XmlNode node in elm.ChildNodes)
                {
                    if (!(node is XmlElement))
                        continue;

                    Console.WriteLine(node.Name + " = " + node.InnerXml);
                    switch (node.Name)
                    {
                        case "autostart":
                            autostart = Convert.ToBoolean(node.InnerXml);
                            break;
                        case "deubg":
                            debug = Convert.ToBoolean(node.InnerXml);
                            break;
                        case "fullscreen":
                            fullscreen = Convert.ToBoolean(node.InnerXml);
                            break;
                        case "enablelcd":
                            enablelcd = Convert.ToBoolean(node.InnerXml);
                            break;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error loading appconfig.xml:\n\n" + ex.Message);
                Application.Exit();
            }

            this.Location = new Point(
                (Screen.PrimaryScreen.WorkingArea.Width  - this.Width)  / 2,
                (Screen.PrimaryScreen.WorkingArea.Height - this.Height) / 2
            );

            ArrayList selections = new ArrayList();

            foreach (Screen screen in Screen.AllScreens)
            {
                selections.Add(screen.DeviceName + " " + screen.Bounds.Width + "x" + screen.Bounds.Height);
            }

            cbAdapaterLCD.DataSource = selections.Clone();
            cbAdapaterTable.DataSource = selections.Clone();

            // Try to figure out default display configuration
            int count = 0;
            foreach (Screen screen in Screen.AllScreens)
            {
                if ((screen.Bounds.Width == 1920 && screen.Bounds.Height == 1080) ||
                    (screen.Bounds.Width == 1920 && screen.Bounds.Height == 1200))
                    cbAdapaterLCD.SelectedIndex = count;

                if ((screen.Bounds.Width == 1400 && screen.Bounds.Height == 1050) ||
                    (screen.Bounds.Width == 1024 && screen.Bounds.Height == 768) ||
                    (screen.Bounds.Width == 1600 && screen.Bounds.Height == 1200) ||
                    (screen.Bounds.Width == 1440 && screen.Bounds.Height == 900))
                    cbAdapaterTable.SelectedIndex = count;

                count++;
            }

            if (autostart)
            {
                launchWindows();
            }
        }

        private void launchWindows()
        {
            flashWindows = new ArrayList();

            // Launch LCD window
            if (enablelcd)
            {
                FlashWindow windowLCD = new FlashWindow(this);
                windowLCD.selectedScreen = cbAdapaterLCD.SelectedIndex;
                windowLCD.flashFileName = "WaterGameLCD.swf";
                windowLCD.fullscreen = fullscreen;
                windowLCD.debug = debug;
                windowLCD.tableEnabled = false;
                windowLCD.Init();
                windowLCD.Show();
                flashWindows.Add(windowLCD);
            }

            // Launch table window
            FlashWindow windowTable = new FlashWindow(this);
            windowTable.selectedScreen = cbAdapaterTable.SelectedIndex;
            windowTable.flashFileName = "WaterGameTable.swf";
            windowTable.fullscreen = fullscreen;
            windowTable.debug = debug;
            windowTable.tableEnabled = true;
            windowTable.Init();
            windowTable.Show();
            flashWindows.Add(windowTable);
            

            this.WindowState = FormWindowState.Minimized;
        }

        public void sendFlashMessage(string callback, string message, FlashWindow sender)
        {
            foreach (FlashWindow flashWindow in flashWindows)
            {
                if (flashWindow != sender)
                    flashWindow.SendToFlash(callback, message);
            }
        }

        public void Exit()
        {
            foreach (FlashWindow flashWindow in flashWindows)
            {
                flashWindow.Close();
            }

            flashWindows.Clear();

            this.WindowState = FormWindowState.Normal;
        }
    }
}
