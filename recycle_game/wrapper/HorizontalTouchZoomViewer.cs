using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Collections;
using System.Xml;
using System.IO;
using System.Runtime.InteropServices;

namespace HorizontalTouchZoomViewer {
    public partial class HorizontalTouchZoomViewer : Form {

        //private DTWebServiceFeed dtwebsvc = null;
        private string m_FlashFilename = "Collage.swf";
        private string m_Title = "";
        private string m_Title2 = "";
        private bool m_Maximized = false;
        private bool m_FullScreen = false;
        private int m_FlashMovieWidth = 0;
        private int m_FlashMovieHeight = 0;
        private bool m_FlashMovieLoaded = false;
        private bool m_IgnoreSubsequentIdenticalEvents = false;
        private bool m_PromptForUserRotations = false;
        private bool m_ShowResizingDirectionArrows = true;
        private bool m_ShowMovementDirectionArrows = true;
        private bool m_FlashLoadedAndListening = false;
        private string[] m_lastTouchEventString;
        private string toucherRotationsStr = "";
        private int[] m_rotateUser = new int[] { 0, 0, 0, 0, 0 };
        private String flashSwfPath;
        public Size m_topologyMapSize = new Size(1600, 1600);
        private bool diamondTouchStarted;

        // Support for distributed computers
        private bool m_Distributed_I_Am_The_Vertical = false;
        private bool m_Distributed_Enabled = false;
        private string m_Horizontal_IP_Address = "localhost";
        private string m_Vertical_IP_Address = "localhost";
        private int m_Horizontal_Port = 4335;
        private int m_Vertical_Port = 4336;

        public HorizontalTouchZoomViewer() {
            InitializeComponent();
            //dtwebsvc = new DTWebServiceFeed();









            // WE WILL NO LONGER PASS "this" ARG IN THE MULTI-CPU SETUP







            StartTouchTable();
        }

        private void HorizontalTouchZoomViewer_FormClosing(object sender, FormClosingEventArgs e) {
            //dtwebsvc.CloseForm();

            try {
                string externalCallString =
                        "<invoke name=\"AppClosing\" returntype=\"xml\">" +
                            "<arguments><string><![CDATA[" + "dummystring" + "]]></string></arguments>" +
                        "</invoke>";
                axShockwaveFlash1.CallFunction(externalCallString);
            } catch (Exception ex) {
                // Commenting out exception until can be fixed. Flash communication IS working -bread
                //MessageBox.Show("SendDTEvent exception: " + ex.Message + "\r\n\r\n" + ex.StackTrace);
            }

            tmrDelayedClosing.Enabled = true;
            StopTouchTable();
        }

        private void HorizontalTouchZoomViewer_Load(object sender, EventArgs e) {
            this.Top = Screen.FromControl(this).WorkingArea.Bottom - this.Height;
            axShockwaveFlash1.Dock = DockStyle.Fill;
            ReadConfigFile(false);

            if (diamondTouchStarted) {
                int cnt = 0;
                cnt = axDiamondTouch1.getReceiverIdCount();
                m_lastTouchEventString = new string[cnt];
                m_lastTouchEventString = new string[axDiamondTouch1.getReceiverIdCount()];
            } else {
                m_lastTouchEventString = new string[5];
            }
            for (int i = 0; i < m_lastTouchEventString.Length; i++) {
                m_lastTouchEventString[i] = "";
            }

            axDiamondTouch1.EventSegmentEnable = false;
            axDiamondTouch1.EventSignalEnable = false;
            axDiamondTouch1.ScreenCoordinatesEnable = true;
            flashSwfPath = Application.StartupPath + "\\" + m_FlashFilename;
            if (m_Title != "") {
                this.Text = m_Title;
            } else {
                this.Text = m_FlashFilename;
            }

            
            if (m_FullScreen) {
                this.FormBorderStyle = FormBorderStyle.None;
                this.WindowState = FormWindowState.Maximized;
            } else if (m_Maximized) {
                this.WindowState = FormWindowState.Maximized;
            } else if (m_FlashMovieHeight > 0 && m_FlashMovieWidth > 0) {
                //axShockwaveFlash1.Size = New Size(m_FlashMovieWidth, m_FlashMovieHeight)
                this.ClientSize = new Size(m_FlashMovieWidth, m_FlashMovieHeight); // causes resize
            }
            
            axShockwaveFlash1.Size = this.ClientSize;
            axShockwaveFlash1.Location = new Point(0, 0);
            if (m_PromptForUserRotations)
                axShockwaveFlash1.LoadMovie(0, Application.StartupPath + "\\rotationsPrompt.swf");
            else
                axShockwaveFlash1.LoadMovie(0, flashSwfPath);
            toucherRotationsStr = "";
            if (m_rotateUser.Length > 0)
                toucherRotationsStr += m_rotateUser[0];
            for (int i = 1; i < m_rotateUser.Length; i++)
                toucherRotationsStr += "," + m_rotateUser[i];
            // Can these be set so soon after LoadMovie -- duplicate in FlashLoadedAndListening and test later
            // If not, how do you tell Flash movie whether to skip promptForUserRotations? May need
            // a separate mechanism to tell Flash movie to wait for C# to set more state before it starts 
            // playing.
            axShockwaveFlash1.SetVariable("dt.toucherRotationString", toucherRotationsStr);
            axShockwaveFlash1.SetVariable("dt.promptForUserRotations", toucherRotationsStr);
            m_FlashMovieLoaded = true;
        }


        //private string m_StringParam1 = "";
        //private bool m_BooleanParam1;
        //private int m_IntegerParam1;
        private void ReadConfigFile() {
            ReadConfigFile(false);
        }
        private void ReadConfigFile(bool verbose) {
            string summary = "Configuration elements loaded:" + "\r\n" + "==============================";
            XmlDocument xmlDoc = new XmlDocument();
            XmlTextReader trdr = null;
            XmlValidatingReader reader = null;
            string tag = "";

            try {
                //xmlDoc.Load("config.xml") // use XmlValidatingReader instead, to validate it
                trdr = new XmlTextReader("config.xml");
                reader = new XmlValidatingReader(trdr);
                xmlDoc.Load(reader);
            } catch (FileNotFoundException fnfex) {
                if (verbose)
                    MessageBox.Show("Exception loading config file: " + fnfex.Message + "\r\n" + fnfex.ToString() + "\r\n" + fnfex.StackTrace, "DTBoxes");
                reader.Close();
                trdr.Close();
                return;
            } catch (Exception ex) {
                MessageBox.Show("Exception loading config file: " + ex.Message + "\r\n" + ex.ToString() + "\r\n" + ex.StackTrace, "DTBoxes");
                reader.Close();
                trdr.Close();
                return;
            }

            try {
                int newInteger;
                bool newBoolean;
                string newString;

                // Set Distributed to "true" to support socket connections between multiple computers

                try {
                    tag = "Distributed_Enabled";
                    newBoolean = XmlConvert.ToBoolean(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                    summary += "\r\n" + tag + "=" + newBoolean.ToString();
                    m_Distributed_Enabled = newBoolean;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "Distributed_I_Am_The_Vertical";
                    newBoolean = XmlConvert.ToBoolean(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                    summary += "\r\n" + tag + "=" + newBoolean.ToString();
                    m_Distributed_I_Am_The_Vertical = newBoolean;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "Horizontal_IP_Address";
                    newString = xmlDoc.SelectSingleNode("//" + tag).InnerText.Trim();
                    summary += "\r\n" + tag + "=" + newString;
                    m_Horizontal_IP_Address = newString;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "Vertical_IP_Address";
                    newString = xmlDoc.SelectSingleNode("//" + tag).InnerText.Trim();
                    summary += "\r\n" + tag + "=" + newString;
                    m_Vertical_IP_Address = newString;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "Horizontal_Port";
                    newInteger = XmlConvert.ToInt32(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                    summary += "\r\n" + tag + "=" + newInteger.ToString();
                    m_Horizontal_Port = newInteger;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "Vertical_Port";
                    newInteger = XmlConvert.ToInt32(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                    summary += "\r\n" + tag + "=" + newInteger.ToString();
                    m_Vertical_Port = newInteger;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }



                try {
                    tag = "FlashFilename";
                    newString = xmlDoc.SelectSingleNode("//" + tag).InnerText.Trim();
                    summary += "\r\n" + tag + "=" + newString;
                    m_FlashFilename = newString;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "Title";
                    newString = xmlDoc.SelectSingleNode("//" + tag).InnerText.Trim();
                    summary += "\r\n" + tag + "=" + newString;
                    m_Title = newString;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "Title2";
                    newString = xmlDoc.SelectSingleNode("//" + tag).InnerText.Trim();
                    summary += "\r\n" + tag + "=" + newString;
                    m_Title2 = newString;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                //try {
                //    tag = "maximized";
                //    newboolean = xmlconvert.toboolean(xmldoc.selectsinglenode("//" + tag).innertext);
                //    summary += "\r\n" + tag + "=" + newboolean.tostring();
                //    m_maximized = newboolean;
                //} catch (exception ex) {
                //    if (verbose)
                //        messagebox.show("error reading config entry: " + tag + ". exception: " + ex.message + "\r\n" + ex.stacktrace, "dtboxes");
                //}

                //try {
                //    tag = "fullscreen";
                //    newboolean = xmlconvert.toboolean(xmldoc.selectsinglenode("//" + tag).innertext);
                //    summary += "\r\n" + tag + "=" + newboolean.tostring();
                //    m_fullscreen = newboolean;
                //} catch (exception ex) {
                //    if (verbose)
                //        messagebox.show("error reading config entry: " + tag + ". exception: " + ex.message + "\r\n" + ex.stacktrace, "dtboxes");
                //}

                try {
                    tag = "IgnoreSubsequentIdenticalEvents";
                    newBoolean = XmlConvert.ToBoolean(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                    summary += "\r\n" + tag + "=" + newBoolean.ToString();
                    m_IgnoreSubsequentIdenticalEvents = newBoolean;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "PromptForUserRotations";
                    newBoolean = XmlConvert.ToBoolean(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                    summary += "\r\n" + tag + "=" + newBoolean.ToString();
                    m_PromptForUserRotations = newBoolean;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "ShowResizingDirectionArrows";
                    newBoolean = XmlConvert.ToBoolean(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                    summary += "\r\n" + tag + "=" + newBoolean.ToString();
                    m_ShowResizingDirectionArrows = newBoolean;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "ShowMovementDirectionArrows";
                    newBoolean = XmlConvert.ToBoolean(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                    summary += "\r\n" + tag + "=" + newBoolean.ToString();
                    m_ShowMovementDirectionArrows = newBoolean;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "RotateUser0";
                    newInteger = XmlConvert.ToInt32(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                    summary += "\r\n" + tag + "=" + newInteger.ToString();
                    m_rotateUser[0] = newInteger;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "RotateUser1";
                    newInteger = XmlConvert.ToInt32(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                    summary += "\r\n" + tag + "=" + newInteger.ToString();
                    m_rotateUser[1] = newInteger;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "RotateUser2";
                    newInteger = XmlConvert.ToInt32(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                    summary += "\r\n" + tag + "=" + newInteger.ToString();
                    m_rotateUser[2] = newInteger;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                try {
                    tag = "RotateUser3";
                    newInteger = XmlConvert.ToInt32(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                    summary += "\r\n" + tag + "=" + newInteger.ToString();
                    m_rotateUser[3] = newInteger;
                } catch (Exception ex) {
                    if (verbose)
                        MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
                }

                /*
                    try {
                        tag = "IntegerParam1";
                        newInteger = XmlConvert.ToInt32(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                        summary += "\r\n" + tag + "=" + newInteger.ToString();
                        m_IntegerParam1 = newInteger;
                    } catch (Exception ex) {
                        if (verbose) MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message+ "\r\n" + ex.StackTrace, "DTBoxes");
                    }

                    try {
                        tag = "StringParam1";
                        newString = xmlDoc.SelectSingleNode("//" + tag).InnerText.Trim();
                        summary += "\r\n" + tag + "=" + newString;
                        m_StringParam1 = newString;
                    } catch (Exception ex) {
                        if (verbose) MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message+ "\r\n" + ex.StackTrace, "DTBoxes");
                    }

                    try {
                        tag = "BooleanParam1";
                        newBoolean = XmlConvert.ToBoolean(xmlDoc.SelectSingleNode("//" + tag).InnerText);
                        summary += "\r\n" + tag + "=" + newBoolean.ToString();
                        m_BooleanParam1 = newBoolean;
                    } catch (Exception ex) {
                        if (verbose) MessageBox.Show("Error reading config entry: " + tag + ". Exception: " + ex.Message+ "\r\n" + ex.StackTrace, "DTBoxes");
                    }
                    */
            } catch (FormatException fex) {
                MessageBox.Show("Error reading config entry: " + tag + "\r\n" + fex.Message + "\r\n" + fex.StackTrace, "DTBoxes");
            } catch (Exception ex) {
                MessageBox.Show("Error reading config file: " + ex.Message + "\r\n" + ex.StackTrace, "DTBoxes");
            } finally {
                reader.Close();
                trdr.Close();
            }
            if (verbose)
                MessageBox.Show(summary);
        }

        private void axDiamondTouch1_Touch(object sender, AxDIAMONDTOUCHLib._DDiamondTouchEvents_TouchEvent e)
        {
            Console.WriteLine(e);
            SendDTEvent(false, e);
        }

        private void SendDTEvent(bool includeGestureInfo, AxDIAMONDTOUCHLib._DDiamondTouchEvents_TouchEvent e) {
            try {
                if (!m_FlashMovieLoaded)
                    return;
                Point pt = axShockwaveFlash1.PointToClient(new Point(e.x, e.y));
                Point ul_pt = axShockwaveFlash1.PointToClient(new Point(e.left, e.top));
                Point lr_pt = axShockwaveFlash1.PointToClient(new Point(e.right, e.bottom));
                string str = "";
                str += "receiver=" + e.receiverId.ToString();
                str += "&action=" + e.eventType.ToString();
                str += "&x=" + pt.X.ToString();
                str += "&y=" + pt.Y.ToString();
                str += "&ulx=" + ul_pt.X.ToString();
                str += "&uly=" + ul_pt.Y.ToString();
                str += "&lrx=" + lr_pt.X.ToString();
                str += "&lry=" + lr_pt.Y.ToString();
                str += "&xSegmentCount=" + e.xSegmentCount;
                str += "&ySegmentCount=" + e.ySegmentCount;
                str += "&valid=true"; // so Flash can distinguish valid input
                if (m_IgnoreSubsequentIdenticalEvents) {
                    if (e.receiverId > -1 && e.receiverId < axDiamondTouch1.getReceiverIdCount()) {
                        if (str.Equals(m_lastTouchEventString[e.receiverId])) {
                            return;
                        }
                    }
                    m_lastTouchEventString[e.receiverId] = str;
                }
                str += "&timestamp=" + e.timestamp;
                // Segment and Signal strings contain binary data. They can't be URL-encoded because they might contain "&"
                //axShockwaveFlash1.SetVariable("dt.DtXSegmentString", e.xSegmentString);
                //axShockwaveFlash1.SetVariable("dt.DtYSegmentString", e.ySegmentString);
                //axShockwaveFlash1.SetVariable("dt.DtXSignalString", e.xSignalString);
                //axShockwaveFlash1.SetVariable("dt.DtYSignalString", e.ySignalString);
                //axShockwaveFlash1.SetVariable("dt.DtEvent", str);
                //axShockwaveFlash1.FlashVars="dt.DtEvent="+ str;
                //this.Text = str;

                //string response = axShockwaveFlash1.CallFunction("<invoke name='tttt' returntype='xml'><arguments><string>'" + str + "'</string></arguments></invoke>");                 

                string externalCallString =
                                    "<invoke name=\"DTData\" returntype=\"xml\">" +
                                        "<arguments><string><![CDATA[" + str + "]]></string></arguments>" +
                                    "</invoke>";
                axShockwaveFlash1.CallFunction(externalCallString);
            } catch (Exception ex) {
                // Commenting out exception until can be fixed. Flash communication IS working -bread
                //MessageBox.Show("SendDTEvent exception: " + ex.Message + "\r\n\r\n" + ex.StackTrace);
            }
        }

        // FSCommand is no longer supported by Flash AS3
        private void axShockwaveFlash1_FSCommand(object sender, AxShockwaveFlashObjects._IShockwaveFlashEvents_FSCommandEvent e) {
            if (e.command == "STOP") {
                tmrStopAndExit.Enabled = true;
            }
        }

        private void tmrStopAndExit_Tick(object sender, System.EventArgs e) {
            tmrStopAndExit.Enabled = false;
            this.Close();
        }

        String dtevString = "";
        private void axShockwaveFlash1_FlashCall(object sender, AxShockwaveFlashObjects._IShockwaveFlashEvents_FlashCallEvent e) {
            //MessageBox.Show("axShockwaveFlash1_FlashCall: " + e.request);
            // incoming e.request is XML:
            //	<invoke name="Flash_SurfaceMove" returntype="xml">
            //		<arguments>
            //			<string>7120ca0e-5e03-44bf-9c4e-178745b6e163</string>
            //			<number>460.81</number>
            //			<number>131.12</number>
            //		</arguments>
            //	</invoke>
            // Now C# should invoke the method...
            //this.Text = "got to axShockwaveFlash1_FlashCall";
            try {
                XmlDocument doc = new XmlDocument();
                doc.LoadXml(e.request);
                XmlNode docElement = doc.DocumentElement;
                //XmlNodeList nl = docElement.Attributes(
                string str = "";
                //foreach (XmlNode n in  docElement.ChildNodes[0].ChildNodes) {
                //str += n.Name;
                string invokedMethodName = "";
                foreach (XmlAttribute attr in docElement.Attributes) {
                    if (attr.Name.Equals("name")) {
                        invokedMethodName = attr.Value;
                        break;
                    }
                }
                XmlNode n;
                string surfaceGuid;
                switch (invokedMethodName) {
                    case "TouchEventFromHorizontal":
                        n = docElement.SelectSingleNode("//invoke/arguments/string[position() = 1]/text()");
                        //String dtevString = n.InnerText;
                        dtevString = n.InnerText;
                        // Send dtevString to CollageVertical.
                        string externalCallString =
                                    "<invoke name=\"TouchEventFromHorizontal\" returntype=\"xml\">" +
                                        "<arguments><string><![CDATA[" + dtevString + "]]></string></arguments>" +
                                    "</invoke>";
                        try {








                            // CREATE SOCKET TO VERTICAL CPU. WE (horizontal) ARE THE CLIENT, SENDING
                            // A MESSAGE TO THE SERVER LISTENING ON THE vertical

                            // DO WE NEED THIS ANYMORE? DO ALL CallFunctions NOW GO DIRECTLY FROM FLASH TO TextSockerServer TO FLASH?

                            //remoteWindow.axShockwaveFlash1.CallFunction(externalCallString);







                        } catch (Exception e2) {
                            this.Text = "ERROR CALLING REMOTE FLASH FROM TouchEventFromHorizontal: " + e2.Message + "\t" + e2.StackTrace;
                        }
                        break;
                    case "FromFlash_Notify":
                        n = docElement.SelectSingleNode("//invoke/arguments/string[position() = 1]/text()");
                        surfaceGuid = n.InnerText;
                        n = docElement.SelectSingleNode("//invoke/arguments/number[position() = 1]/text()");
                        int surfaceLeft = (int)Math.Round(Decimal.Parse(n.InnerText));
                        n = docElement.SelectSingleNode("//invoke/arguments/number[position() = 2]/text()");
                        int surfaceTop = (int)Math.Round(Decimal.Parse(n.InnerText));
                        //MessageBox.Show("GUID=" + surfaceGuid+" left=" + surfaceLeft.ToString() + " top=" + surfaceTop.ToString());
                        break;
                    case "FlashLoadedAndListening": //DTFlash calls this, but rotationsPrompt.swf doesn't
                        // Now we can pass preferred rotations etc (anything from the C# config file)1
                        m_FlashLoadedAndListening = true;
                        //
                        axShockwaveFlash1.SetVariable("dt.xAntennaCount", axDiamondTouch1.getXAntennaCount().ToString());
                        axShockwaveFlash1.SetVariable("dt.yAntennaCount", axDiamondTouch1.getYAntennaCount().ToString());
                        axShockwaveFlash1.SetVariable("dt.antennaPitchUm", axDiamondTouch1.getAntennaPitchUm().ToString());
                        //						
                        axShockwaveFlash1.SetVariable("_root.ShowResizingDirectionArrows", m_ShowResizingDirectionArrows.ToString().ToLower());
                        axShockwaveFlash1.SetVariable("_root.ShowMovementDirectionArrows", m_ShowMovementDirectionArrows.ToString().ToLower());
                        toucherRotationsStr = "";
                        if (m_rotateUser.Length > 0)
                            toucherRotationsStr += m_rotateUser[0];
                        for (int i = 1; i < m_rotateUser.Length; i++)
                            toucherRotationsStr += "," + m_rotateUser[i];
                        axShockwaveFlash1.SetVariable("dt.toucherRotationString", toucherRotationsStr);
                        axShockwaveFlash1.SetVariable("dt.promptForUserRotations", "false");//C# already loaded rotationsPrompt.swf
                        break;
                    case "Flash_RotationsPromptComplete":
                        axShockwaveFlash1.SetVariable("nextMovie", flashSwfPath);
                        n = docElement.SelectSingleNode("//invoke/arguments/string[position() = 1]/text()");
                        string rotations = n.InnerText;
                        //MessageBox.Show("got Flash_RotationsPromptComplete signal from Flash. rotations=" +rotations+ "\n" +
                        //	flashSwfPath);	
                        string[] rotvals = rotations.Split();
                        for (int i = 0; i < rotvals.Length; i++) {
                            m_rotateUser[i] = Convert.ToInt32(rotvals[i]);
                        }
                        //string s = "";
                        //for (int j=0; j<rotvals.Length; j++) 
                        //	s += rotvals[j].ToString() + " ";
                        //MessageBox.Show("got Flash_RotationsPromptComplete signal from Flash. rotations=" +s+ "\n" +
                        //	flashSwfPath);	
                        //
                        //Flash will now do a _root.LoadMovie(nextMovie) and blow away state. 
                        //Pass new movie the new rotations and all in "FlashLoadedAndListening"
                        break;
                    case "FlashWantsToQuit":
                        // Rather than exit right a way, start a timer that handles the exiting after a brief delay. 
                        // This shuts down more cleanly because the Flash command that got us here can nicely return, first.
                        tmrStopAndExit.Enabled = true;
                        break;
                    default:
                        break;
                }
                str += "\r\n";
                //}
                //MessageBox.Show(str);
            } catch (Exception ex) {
                // Commenting out exception until can be fixed. Flash communication IS working -bread
                //MessageBox.Show("axShockwaveFlash1_FlashCall exception: " + ex.Message + "\r\n" + ex.StackTrace);
            }
            axShockwaveFlash1.SetReturnValue("<string>My return string from C# to Flash</string");
        }

        private void tmrDelayedClosing_Tick(object sender, EventArgs e) {
            tmrDelayedClosing.Enabled = false;
            this.Close();
        }

        private void HorizontalTouchZoomViewer_KeyPress(object sender, System.Windows.Forms.KeyPressEventArgs e) {
            // this.KeyPreview is TRUE
            if (e.KeyChar == (char)Keys.Escape) {
                if (this.WindowState == FormWindowState.Normal) {
                    this.FormBorderStyle = FormBorderStyle.None;
                    this.WindowState = FormWindowState.Maximized;
                } else {
                    this.WindowState = FormWindowState.Normal;
                    this.FormBorderStyle = FormBorderStyle.Sizable;
                }
            }
            if (e.KeyChar == (char)Keys.Space) {
                //dtwebsvc.Show();
            }
        }

        private void HorizontalTouchZoomViewer_Resize(object sender, EventArgs e) {
            if (!m_FlashMovieLoaded)
                return;
            axShockwaveFlash1.Size = this.ClientSize;
            //axShockwaveFlash1.SetVariable("dt.DtEvent", "resize=true&valid=true");
            string externalCallString =
                                    "<invoke name=\"DTData\" returntype=\"xml\">" +
                                        "<arguments><string><![CDATA[resize=true&valid=true]]></string></arguments>" +
                                    "</invoke>";
            axShockwaveFlash1.CallFunction(externalCallString);
        }

        private void StartTouchTable() {
            int res = 0;
            String str = "";


            res = axDiamondTouch1.Start();
            if (res == 0) {
                diamondTouchStarted = true;
            } else {
                diamondTouchStarted = false;
                switch (res) {
                    case 1:
                        str = "Warning starting DiamondTouch: already started";
                        diamondTouchStarted = true;
                        break;
                    case 2:
                        str = "Error starting DiamondTouch: no device (couldn't find a USB DiamondTouch device)";
                        break;
                    case 3:
                        str = "Error starting DiamondTouch: open failed";
                        break;
                    case 4:
                        str = "Error starting DiamondTouch: serial device (not supported)";
                        break;
                    case 5:
                        str = "Error starting DiamondTouch: thread start failed (couldn't start up a thread for some reason)";
                        break;
                    default:
                        str = "Error starting DiamondTouch: unknown error";
                        break;
                }
                MessageBox.Show(str, "DiamondTouch Error", MessageBoxButtons.OK);
            }
            System.Threading.Thread.Sleep(100); // ActiveX control created a new thread to start the device
        }

        private void StopTouchTable() {
            if (diamondTouchStarted) {
                axDiamondTouch1.Stop();
                diamondTouchStarted = false;
            }
        }

    }
}
