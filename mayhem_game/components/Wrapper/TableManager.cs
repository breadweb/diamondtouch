using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing;

namespace WaterGameWrapper
{
    class TableManager
    {
        private AxDIAMONDTOUCHLib.AxDiamondTouch axDiamondTouch;
        private AxShockwaveFlashObjects.AxShockwaveFlash axShockwaveFlash;
        private FlashWindow form;
        private bool tableStarted = false;
        private int offsetX = 0;

        public TableManager(FlashWindow form, AxShockwaveFlashObjects.AxShockwaveFlash axShockwaveFlash, int offsetX)
        {
            this.form = form;
            this.offsetX = offsetX;
            this.axShockwaveFlash = axShockwaveFlash;
            this.axDiamondTouch = new AxDIAMONDTOUCHLib.AxDiamondTouch();

            ((System.ComponentModel.ISupportInitialize)(this.axDiamondTouch)).BeginInit();

            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FlashWindow));
            this.axDiamondTouch.Enabled = true;
            this.axDiamondTouch.Location = new System.Drawing.Point(0, 0);
            this.axDiamondTouch.Name = "axShockwaveTouch";
            this.axDiamondTouch.OcxState = ((System.Windows.Forms.AxHost.State)(resources.GetObject("axShockwaveTouch.OcxState")));
            this.axDiamondTouch.Size = new System.Drawing.Size(10, 10);
            this.axDiamondTouch.Visible = false;
            this.axDiamondTouch.Touch += new AxDIAMONDTOUCHLib._DDiamondTouchEvents_TouchEventHandler(this.axDiamondTouch_Touch);
            form.Controls.Add(this.axDiamondTouch);


            ((System.ComponentModel.ISupportInitialize)(this.axDiamondTouch)).EndInit();

            StartTouchTable();
        }

        private void axDiamondTouch_Touch(object sender, AxDIAMONDTOUCHLib._DDiamondTouchEvents_TouchEvent e)
        {
            SendDTEvent(false, e);

            // Offset and point to client translation debugging
            if (form.debug)
            {
                TextBox tb = form.Controls["textBox1"] as TextBox;
                tb.Text = "offset = " + offsetX + Environment.NewLine; ;
                tb.Text += "DT coordinates: " + e.x + ", " + e.y + Environment.NewLine;
                Point pt = this.axShockwaveFlash.PointToClient(new Point(e.x, e.y));
                tb.Text += "PointToClient: " + pt.X + ", " + pt.Y + Environment.NewLine; ;
                tb.Text += "With offset: " + (pt.X + offsetX) + ", " + pt.Y + Environment.NewLine;
            }
        }

        private void SendDTEvent(bool includeGestureInfo, AxDIAMONDTOUCHLib._DDiamondTouchEvents_TouchEvent e)
        {
            try
            {
                Point pt = this.axShockwaveFlash.PointToClient(new Point(e.x, e.y));
                Point ul_pt = this.axShockwaveFlash.PointToClient(new Point(e.left, e.top));
                Point lr_pt = this.axShockwaveFlash.PointToClient(new Point(e.right, e.bottom));

                string str = "receiver=" + e.receiverId.ToString();
                str += "&action=" + e.eventType.ToString();
                str += "&x=" + (pt.X + offsetX).ToString();
                str += "&y=" + pt.Y.ToString();
                str += "&ulx=" + (ul_pt.X + offsetX).ToString();
                str += "&uly=" + ul_pt.Y.ToString();
                str += "&lrx=" + (lr_pt.X + offsetX).ToString();
                str += "&lry=" + lr_pt.Y.ToString();
                str += "&xSegmentCount=" + e.xSegmentCount;
                str += "&ySegmentCount=" + e.ySegmentCount;
                str += "&valid=true";
                str += "&timestamp=" + e.timestamp;

                form.SendToFlash("onDTData", str);
            }
            catch (Exception ex)
            {
                MessageBox.Show("SendDTEvent exception: " + ex.Message + "\r\n\r\n" + ex.StackTrace);
            }
        }

        public void StartTouchTable()
        {
            String str = "";
            int res = axDiamondTouch.Start();

            if (res == 0)
            {
                tableStarted = true;
            }
            else
            {
                tableStarted = false;
                switch (res)
                {
                    case 1:
                        str = "Warning starting DiamondTouch: already started";
                        tableStarted = true;
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

        public void StopTouchTable()
        {
            if (tableStarted)
            {
                axDiamondTouch.Stop();
                tableStarted = false;
            }
        }
    }
}
