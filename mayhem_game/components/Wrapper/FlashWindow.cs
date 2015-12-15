using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Xml;
using System.Collections;

namespace WaterGameWrapper
{
    public partial class FlashWindow : Form
    {
        public string flashFileName = "Mayhem.swf";
        public int selectedScreen = 1;
        public bool fullscreen = true;
        public bool debug = false;
        public bool tableEnabled = true;
        private bool flashLoaded = false;
        private TableManager tableManager;
        private Launcher launcher;
        private bool readyToClose = false;

        public FlashWindow(Launcher launcher)
        {
            InitializeComponent();
            this.launcher = launcher;
            Console.WriteLine("FlashWindow constructor fired...");
        }

        private void FlashWindow_Load(object sender, EventArgs e)
        {
            Console.WriteLine("FlashWindow_Load called...");
        }

        public void Init()
        {
            Console.WriteLine("Init called...");

            if (debug)
            {
                TextBox tb = new TextBox();
                tb.Location = new Point(10, 10);
                tb.Size = new Size(300, 100);
                tb.Multiline = true;
                tb.Name = "textBox1";
                this.Controls.Add(tb);
                tb.BringToFront();
            }

            // Move to the selected screen
            Screen[] screens = Screen.AllScreens;
            Point point = new Point(screens[selectedScreen].Bounds.Location.X, screens[selectedScreen].Bounds.Location.Y);
            this.Location = point;

            int appWidth = screens[selectedScreen].Bounds.Width;
            int appHeight = screens[selectedScreen].Bounds.Height;
            this.ClientSize = new Size(appWidth, appHeight);

            // Set to fullscreen
            if (fullscreen)
            {
                this.FormBorderStyle = FormBorderStyle.None;
                this.WindowState = FormWindowState.Maximized;
            }
            else
            {
                // If debugging, do not resize window to full size of
                // flash movie otherwise it will be too large
                if (debug)
                    this.ClientSize = new Size(appWidth / 2, appHeight / 2);
            }

            // Initialize the touch table
            if (tableEnabled)
            {
                // An offset for the x position needs to be calculated 
                // for the point to client translation. This is just in case
                // this window is running on the second display and the layout
                // has it on the left of the primary.
                int offsetX = screens[selectedScreen].Bounds.X;

                tableManager = new TableManager(this, axShockwaveFlash, offsetX);
            }

            // Load the flash movie
            string filePath = Application.StartupPath + "\\" + flashFileName;
            if (!File.Exists(filePath))
            {
                MessageBox.Show("The Flash application could not be found. Please check the flash name in the configuration file and try again.");
                return;
            }

            axShockwaveFlash.Dock = DockStyle.Fill;
            axShockwaveFlash.Size = this.ClientSize;
            axShockwaveFlash.Location = new Point(0, 0);
            axShockwaveFlash.LoadMovie(0, filePath);
            flashLoaded = true;
        }

        private void FlashWindow_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!readyToClose)
            {
                e.Cancel = true;
                if (tableEnabled)
                    tableManager.StopTouchTable();
                tmrDelayedClosing.Enabled = true;
            }
        }

        private void FlashWindow_Resize(object sender, System.EventArgs e)
        {
            if (!flashLoaded)
                return;
            SendToFlash("onDTData", "resize=true&valid=true");
        }

        /**
         * Sending messages to the embedded flash movie
         */
        public void SendToFlash(string callback, string message)
        {
            if (!flashLoaded)
                return;

            try
            {
                string externalCallString =
                    "<invoke name=\"" + callback + "\" returntype=\"xml\">" +
                        "<arguments><string><![CDATA[" + message + "]]></string></arguments>" +
                    "</invoke>";
                axShockwaveFlash.CallFunction(externalCallString);
            }
            catch (Exception ex)
            {
                MessageBox.Show("SendToFlash exception: " + ex.Message + "\n\n" + ex.StackTrace);
            }
        }

        /**
         * Receiving messages from the embedded flash movie. Event message is
         * XML and is in the following format:
         * 
         * <invoke name="InovkeName" returntype="xml">
         *      <arguments>
         *          <string>7120ca0e-5e03-44bf-9c4e-178745b6e163</string>
         *          <number>460.81</number>
         *          <number>131.12</number>
         *      </arguments>
         * </invoke>
         */
        private void axShockwaveFlash_FlashCall(object sender, AxShockwaveFlashObjects._IShockwaveFlashEvents_FlashCallEvent e)
        {
            string invokeName = "";
            XmlDocument xmlDoc = new XmlDocument();

            try
            {
                xmlDoc.LoadXml(e.request);
                XmlNode elm = xmlDoc.DocumentElement;
                foreach (XmlAttribute attr in elm.Attributes)
                {
                    if (attr.Name.Equals("name"))
                    {
                        invokeName= attr.Value;
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("axShockwaveFlash_FlashCall exception: " + ex.Message + "\n\n" + ex.StackTrace);
                return;
            }

            switch (invokeName)
            {
                case "exit":
                    
                    launcher.Exit();
                    break;

                case "gamecue":

                    // Send cue to the other flash window

                    XmlNodeList xmlList = xmlDoc.GetElementsByTagName("arguments");
                    string cueName = xmlList[0].ChildNodes[0].InnerText;

                    launcher.sendFlashMessage("onGameCue", cueName, this);
                    break;

                default:
                    MessageBox.Show("Unhandled method name from flash");
                    break;
            }
        }

        private void tmrDelayedClosing_Tick(object sender, EventArgs e)
        {
            tmrDelayedClosing.Enabled = false;
            readyToClose = true;
            this.Close();
        }
    }
}
