namespace HorizontalTouchZoomViewer {
    partial class HorizontalTouchZoomViewer {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing) {
            if (disposing && (components != null)) {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent() {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(HorizontalTouchZoomViewer));
            this.tmrDelayedClosing = new System.Windows.Forms.Timer(this.components);
            this.tmrStopAndExit = new System.Windows.Forms.Timer(this.components);
            this.axShockwaveFlash1 = new AxShockwaveFlashObjects.AxShockwaveFlash();
            this.axDiamondTouch1 = new AxDIAMONDTOUCHLib.AxDiamondTouch();
            ((System.ComponentModel.ISupportInitialize)(this.axShockwaveFlash1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.axDiamondTouch1)).BeginInit();
            this.SuspendLayout();
            // 
            // tmrDelayedClosing
            // 
            this.tmrDelayedClosing.Tick += new System.EventHandler(this.tmrDelayedClosing_Tick);
            // 
            // tmrStopAndExit
            // 
            this.tmrStopAndExit.Tick += new System.EventHandler(this.tmrStopAndExit_Tick);
            // 
            // axShockwaveFlash1
            // 
            this.axShockwaveFlash1.Enabled = true;
            this.axShockwaveFlash1.Location = new System.Drawing.Point(63, 90);
            this.axShockwaveFlash1.Name = "axShockwaveFlash1";
            this.axShockwaveFlash1.OcxState = ((System.Windows.Forms.AxHost.State)(resources.GetObject("axShockwaveFlash1.OcxState")));
            this.axShockwaveFlash1.Size = new System.Drawing.Size(192, 192);
            this.axShockwaveFlash1.TabIndex = 2;
            // 
            // axDiamondTouch1
            // 
            this.axDiamondTouch1.Enabled = true;
            this.axDiamondTouch1.Location = new System.Drawing.Point(335, 120);
            this.axDiamondTouch1.Name = "axDiamondTouch1";
            this.axDiamondTouch1.OcxState = ((System.Windows.Forms.AxHost.State)(resources.GetObject("axDiamondTouch1.OcxState")));
            this.axDiamondTouch1.Size = new System.Drawing.Size(144, 36);
            this.axDiamondTouch1.TabIndex = 3;
            this.axDiamondTouch1.Visible = false;
            this.axDiamondTouch1.Touch += new AxDIAMONDTOUCHLib._DDiamondTouchEvents_TouchEventHandler(this.axDiamondTouch1_Touch);
            // 
            // HorizontalTouchZoomViewer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(722, 405);
            this.Controls.Add(this.axDiamondTouch1);
            this.Controls.Add(this.axShockwaveFlash1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.KeyPreview = true;
            this.Name = "HorizontalTouchZoomViewer";
            this.Text = "TouchZoomViewer Horizontal";
            this.Load += new System.EventHandler(this.HorizontalTouchZoomViewer_Load);
            this.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.HorizontalTouchZoomViewer_KeyPress);
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.HorizontalTouchZoomViewer_FormClosing);
            this.Resize += new System.EventHandler(this.HorizontalTouchZoomViewer_Resize);
            ((System.ComponentModel.ISupportInitialize)(this.axShockwaveFlash1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.axDiamondTouch1)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Timer tmrDelayedClosing;
        private System.Windows.Forms.Timer tmrStopAndExit;
        //private AxDIAMONDTOUCHLib.AxDiamondTouch axDiamondTouch1;
        private AxShockwaveFlashObjects.AxShockwaveFlash axShockwaveFlash1;
        private AxDIAMONDTOUCHLib.AxDiamondTouch axDiamondTouch1;
    }
}

