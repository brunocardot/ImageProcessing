//  
// Image Pattern Processor Macro  
// Applied to computationally intensive artistic endeavors  
// Designed to work with any images
//
// 5.1.2026
//  

// https://imagej.net/ij/developer/macro/functions.html
// https://imagej.net/ij/developer/macro/macros.html

requires("1.52o");
var ijv = getVersion();
//  
// Globals Variables  
// ==============================================================================  
//  
var gPgmTitle="Image Pattern Processor";  
var gS,gZ,gA;                                 	// Square, Z, Angle  
var gAdjustement;                             	// Adjustement to keep copy/paste overlap so no hole is seen 
var gWidth, gHeight;                          	// Source File Information  
var gSourceID, gDestinationID;                	// ID for Source(Input) and Destination(Output) Files  
var gDestinationDir="c:\\Temp.Images";	   			// Default Location 
var gSourceFileName;                          	// Source file name  
var gDirpath;                                 	// Dir selection full path  
var gDirlist;                                 	// Dir selection file list  
var gSC=0;                                    	// Slice Count (for debugging)  
var gDelay=2000;                                // Pause Delay (Sleep ms)
var gDT=getTime();															// Save last DT
//  
// Global (from imagej)  
// ====================  
/* 
  
  nImages - count the number of opened images  
  
*/   
 
//  
// Menu Options (Listed in the correct order) 
// ==========================================================================  
//  
var s04=false;    // Slices  4  
var sRP=0;        // Repeat  
var s08=false;    // Slices  8  
var s09=false;    // Slices  9 (Not coded)  
var s16=false;    // Slices 16  
var s32=false;    // Slices 32  
var s64=false;    // Slices 64  
var s128=false;   // Slices 128  
var sDR=false;    // Drawing  
var sDN=false;    // Drawing Number A/B/C/D/E...  
var sMa=false;    // Build a Maze  
var sST=false;    // Build a Seamless Tile  
var sIGP=false;   // Build a Islamic Geometric Pattern
var sIGPsq=false; // Add Square Around the Tile  
var sDi=false;    // Source is a directory (all files will be processed)  
var sSS=false;    // Save Source  
var sSD=false;    // Save Destination  
var sCS=false;    // Change Selection  
var sRO=false;    // Rotate Image before to add selection  
var sDB1=false;   // Debug 1 - Drawline with different color around the selection  
var sSM=false;    // Silent Mode  
var sSR=false;    // Square Rendue
var sRM=0;        // Rotate Method
var sRR=false;    // Reduce Resolution  
var sLP=false;    // Low Speed  

// Execution Time of Macro
var sExecTimeTotal="0";
var sExecBegin=0; 
var sExecEnd=0;

// MACROs ======================================================================  
  
macro "ipp_tool [f9]" { 
    
// BEGIN MACRO ===============================================================  
  print ("Start ImageP Macro...");

  fct_Menu(); // Exit when press Cancel
  
	while (1) {
		sExecBegin = getTime();
		fct_ExecFeatures ();
		sExecEnd = getTime();
		sExecTimeTotal = ExecDuration (sExecBegin, sExecEnd,0);
		//
		fct_Menu();
	}

	function fct_ExecFeatures() {
		
		lFileSelect = false;  
		if (s04||s08||s09||s16||s32||s64||s128||sST||sDi) {  
			lFileSelect = fct_FileDirSelection();  // return true if we have at least one file identified  
		}  
			
		if (lFileSelect) {  
			if (!sDi) { // Source is a file
				doit_withfile(); 
			}
			if (sDi) { // Source is a directory
				var filecount = gDirlist.length;
				for (i=0; i<filecount; i++) {  
					if (!endsWith(gDirlist[i], "/")) {  
						open (gDirpath + gDirlist[i]);  
						print("file opened="+ gDirpath + gDirlist[i] + " nImages=" + nImages); // nImages: Returns number of open images 
						if (nImages>0) { 
							// showProgress(i/filecount); // Not working for some reason
							print ("File #" + i/filecount);
							doit_withfile(); 
							// run("Close");
							// close(); // Closes the active image
						} 
						else {
							run("Close"); // Closes non-image windows.
						}
					}  
				}    
			}  
		}  
		
		if (!lFileSelect) {  
			doit_withoutfile();  
		}  

		function doit_withfile() {   
			if (sST||s04||s08||s09||s16||s32||s64||s128) 
				fct_Main_ImageManipulation(); // Mandala Style Manipulation  
		}  
			
		function doit_withoutfile() {   
			//
			if (sDR) fct_Main_Drawing();          // Drawing  
			if (sMa) fct_Main_Maze();             // Maze    
			if (sIGP) {                           // Build a Islamic Geometric Pattern 
				w = 1000;                           // Square Size (First Quarter)  
				fct_Main_IslamicGeometricPattern(w,1); // Islamic Geometric Pattern  
				s04 = true;  
				fct_Main_ImageManipulation();  
				if (sIGPsq) { // Add Square 
					fct_ChangeColor(2); 
					setLineWidth(10);   
					drawLine(0,0,0,2*w); 
					drawLine(0,2*w,2*w,2*w); 
					drawLine(2*w,2*w,2*w,0); 
					drawLine(2*w,0,0,0);    
				}  
				s04 = false;  
				sST = true;  
				fct_Main_ImageManipulation();     
			}  
		}  
	}
}
  
//  
// Graphical Features  
//  
  
//  
// Main Manipulation Functions
//

function fct_Main_ImageManipulation() { // Mandala, SeamlessTile
	
  setPasteMode("Copy"); 							// or "Blend", "Transparent-zero", "Transparent-white"  
  setBatchMode(sSM);    							// Will run fully silent if true  
  setBackgroundColor(255, 255, 255); 	// white color  
  setForegroundColor(255, 255, 255);  //
    
  if (nImages>0) { // check that at least one image is opened 
  
    // Read File Information  
    fct_Read_image_info(); 
		// Reduce Resolution (to speed up the manipulations)
    fct_Reduce_Resolution(); 
  
		if (sST) fct_SeamlessTitle ();
		
		//
		// Madala Slices - 4, 8, 16 and 32  
		//  
		if (s04) 	fct_Processimage_MandalaSlices (4);
		if (s08) 	fct_Processimage_MandalaSlices (8);
		if (s16) 	fct_Processimage_MandalaSlices (16);
		if (s32) 	fct_Processimage_MandalaSlices (32);  
		if (s64) 	fct_Processimage_MandalaSlices (64);  
		if (s128) fct_Processimage_MandalaSlices (128);  
		
		fct_SquareRendue();
		
		if (sSS) fct_FormatSaveImage(false,gSourceID,true,"Source",gDestinationDir,gSourceFileName);    
		//  
  }  
  else {  
    // No valid file  
    Dialog.create("Error");  
    Dialog.addMessage("No Valid File");  
    Dialog.show();  
  } 

	setBatchMode("exit and display");
		
	function fct_Processimage_MandalaSlices (lSlices) {
		//
		// Debugging
		//
		
		if (0) {
		 fct_Testing(); 
			return;
		}
		
		if (lSlices==4) {
			// 
			//  *** 1 time *** 
			// 
			fct_DrawTheSelection (lSlices, gSourceID);  
			fct_BuildSlices(lSlices);  

			// ********************* 
			// *** Repeat Option *** 
			// ********************* 
			for (i=1;i<sRP;i++) {  
				 
				selectImage(gSourceID);  
				close();  
				selectImage(gDestinationID);  
				gSourceID = getImageID();  
				
				selectImage(gSourceID);
				fct_Rotate_before();
				
				fct_DrawTheSelection (lSlices, gSourceID);  
				fct_Add_number_on_slice(lSlices,1);  
				
				fct_BuildSlices(lSlices);  
			}  

			fct_FormatSaveImage(false,gDestinationID,false,"s04",gDestinationDir,gSourceFileName);  // Save the output image  

		}
		
		else { // 8, and more
		
			gSC = 0;  
			fct_Log("1");
			fct_Rotate_before();
			fct_Log("2");
			fct_DrawTheSelection(lSlices,gSourceID);  
			fct_Log("3");
			fct_Add_number_on_slice(lSlices,1);  
			fct_Log("4");
			fct_BuildSlices(lSlices);  
			fct_Log("5");
			fct_FormatSaveImage(true,gDestinationID,true,lSlices,gDestinationDir,gSourceFileName); // Save the output image 
			fct_Log("6");
			//
		}
		
	}
	
	function fct_SeamlessTitle () { // Build a Seamless Tile 
	
		fct_DrawTheSelection(4, gSourceID);  
    fct_Processimage_SeamlessTile();  
    fct_FormatSaveImage(false,gDestinationID,false,"sST", gDestinationDir, gSourceFileName);  // Save the output image     
	
	}

	function fct_SquareRendue() { // Output is Square instead Circle

		if (!sSR) return;

		// Crop
		type = "freehand";
		
		L = 2*gS;
		c = L / 2 / sqrt(2);
		a = gS;
		l = a - c;
		x1 = l; y1 = l;
		x2 = a + c; y2 = y1;
		x3 = x2; y3 = a + c;
		x4 = l; y4 = y3; 
		x5 = x1; y5 = y1;
		makeSelection(type, newArray(x1,x2,x3,x4,x5), newArray (y1,y2,y3,y4,y5)); 
		run("Crop");  
		
	}
		
	function fct_Rotate_before() { // Rotate Image before processing
		//
		if (!sRO) return;
		
		//
		// Get min side for Square to be retained
		//
		selectImage(gSourceID); 
		getDimensions(width, height, channels, slices, frames);  
		gWidth = width;   
		gHeight = height;
		gS = minOf(gHeight, gWidth);
		// wait(1000);

		// Crop
		type = "freehand";
		x1=0; y1=0;  x2=gS; y2=0;  x3=gS; y3=gS;  x4=0; y4=gS;  x5=0; y5=0;  
		makeSelection(type, newArray(x1,x2,x3,x4,x5), newArray (y1,y2,y3,y4,x5)); 
		run("Crop");  
		
		// Rotate
		run("Select None");  
		run("Rotate... ", "angle=" + 90 + " grid=1 interpolation="+ sRM + " fill"); // Bilinear fill");
		// if (bPause)
		//	 if (sCS) waitForUser("Pending User Intervention", "Check Rotation"); 	
	}

	function fct_Testing1 () {
		
		pSlices = 8;
		a = 25;
		// Debugging Mode	
		gA = 360 / pSlices; // angle in degre  
		gAdjustement = 1;  	// Needed to adjust Selection to remain inside the picture canvas  
		Alpha = fct_da(gA/2); 	// 1/2 of the Angle  
		gS = gWidth * 0.8;  
		gZ = gS * tan(Alpha);  
		gZ = floor(gZ)+1; 	// round to the next integer for Z value  
		lL = gHeight/2;  
		x1= 0; y1=lL      -gAdjustement;  
		x2=gS; y2=lL - gZ -gAdjustement;  
		x3=gS; y3=lL + gZ +gAdjustement;  
		x4= 0; y4=lL      +gAdjustement;  
		makeSelection("freehand", newArray(x1,x2,x3,x4), newArray (y1,y2,y3,y4)); 
		
		run("Rotate... ", "angle=" + a + " grid=1 interpolation=" + sRM + " fill"); 
		
	}

	function fct_Testing2 () {
		
		if (0) { // Testing - Some Image are not working
			
			// 8 slices
			// first call with fct_a(0);
			s=0; // parameters is 0
			gSC++;  
			selectImage(gDestinationID);  
			roiManager("Select", 0);  
		
			//if (s==4) 
			//	setSelectionLocation(0, 0);  
			//else 
			
			setSelectionLocation(gS, gS-gZ-gAdjustement);  
			print ("gS = " + gS);
			print ("gZ = " + gZ);
			print ("gAdjustement = " + gAdjustement);
			print ("gS-gZ-gAdjustement = " + gS-gZ-gAdjustement);
			run("Paste");  
			// run("Select None");  
			
			//_Add_number_on_slice(s,0);  
			//if (sLP) wait(gDelay);
			//_Log("_a()");
			
			return;
			
		}
	}
	
	//  
	// Process the Image with Selection, Copy/Paste, Rotation, etc... 
	//  
	function fct_BuildSlices(pSlices) { // Slices Count like 4,8,16,32  
																
		if (roiManager("count")>0) roiManager("Delete");  
		roiManager("Add");  
		run("Copy");                                                  // Copy the source selection from roiManager 
			
		newImage("Target", "RGB White", gS*2, gS*2, 1);               // Create new Canvas (twice as the original) 
		
		// print ("gS = " + gS);
		// print ("gZ = " + gZ);
			
		gDestinationID = getImageID();  
		
		// Mandala Processing 
		 
		if (pSlices==  4) 	{  fct_a(4);  fct_b(4); 		fct_e();  fct_b(4);	fct_b(4); }  
		if (pSlices==  8)		{  fct_4();   fct_d(45); 	 	fct_f();  fct_4();  fct_f();  }  
		if (pSlices== 16) 	{  fct_8();	 	fct_d(45/2);  fct_f();  fct_8();  fct_f(); 	}    
		if (pSlices== 32) 	{  fct_16();  fct_d(45/4);  fct_f();  fct_16(); fct_f(); 	}  
		if (pSlices== 64) 	{  fct_32(); 	fct_d(45/8);  fct_f();  fct_32(); fct_f();	}  
		if (pSlices==128)		{  fct_64();  fct_d(45/16); fct_f();	fct_64(); fct_f(); 	}  
			
		function fct_2() 		{  fct_a(0);	fct_f(); 		 	fct_b(0); } 
		function fct_4() 		{  fct_2();	 	fct_d(90);		fct_2();  } 
		function fct_8() 		{  fct_4();	 	fct_d(45);  	fct_4();	} 
		function fct_16() 	{  fct_8();   fct_d(45/2);  fct_8(); 	}
		function fct_32() 	{  fct_16();  fct_d(45/4);	fct_16();	}
		function fct_64() 	{	 fct_32();  fct_d(45/8);  fct_32(); }		
		function fct_128() 	{  fct_64();  fct_d(45/16);	fct_64();	}
			
		/*  
			Rotate/flip functions  
			---------------------  
					3  
			 2  o  1  
					4  
		*/  
		function fct_a(s)   { // Paste in 1  
			gSC++;  
			selectImage(gDestinationID);  
			roiManager("Select", 0);  
			if (s==4) 
				setSelectionLocation(0, 0);  
			else 
				setSelectionLocation(gS, gS-gZ-gAdjustement);  
			run("Paste");  
			run("Select None");  
		  fct_Add_number_on_slice(s,0);  
			if (sLP) wait(gDelay);
		  fct_Log("_a()");
		}  
		function fct_b(s)   { // Move 1 to 2  
			selectImage(gDestinationID);  
			run("Flip Horizontally", "stack");  
		  fct_a(s);  
			if (sLP) wait(gDelay);
		  fct_Log("_b()");
		}  
		/*
		function fct_c()    { // Rotate 90  
			// selectImage(gDestinationID);  
			// run("Rotate 90 Degrees Left");  
		 fct_d(90);	
			if (sLP) wait(gDelay);
		} 
		*/	
		function fct_d(a)   { // Rotate 'a' degress  
			selectImage(gDestinationID);  
			run("Rotate... ", "angle=" + a + " grid=1 interpolation=" + sRM + " fill");  
			if (sLP) wait(gDelay);
		  fct_Log("_d()");
		} 
		function fct_e()    { // Flip Vertically
			run("Select None");  
			run("Flip Vertically", "stack");  
			if (sLP) wait(gDelay);
		  fct_Log("_e()");
		} 	
		function fct_f()    { // Flip Source, and Retake a Copy  
			selectImage(gSourceID);  
			run("Flip Vertically", "stack");  
			run("Copy");  
			if (sLP) wait(gDelay);
		  fct_Log("_f()");
		}  	
		function fct_g(x,y) { // Paste
			setSelectionLocation(x, y);  
			run("Paste");  
			if (sLP) wait(gDelay);
		  fct_Log("_g()");
		}  
			
	}  
	 
	//  
	// Seamless Tiles  
	//  
	function fct_Processimage_SeamlessTile() { 
	 
		// Prepare Pattern Title  
		type = "freehand";  
		
		if (roiManager("count")>0) roiManager("Delete");  
		run("Select None");  
		 
		newImage("Target", "RGB White", gS, gS, 1);  
		gDestinationID=getImageID();  
		
		/* 
		 *   Source  
		 *   1 2  
		 *   3 4  
		 *   
		 *   Destination  
		 *   4 3  
		 *   2 1  
		 */  
		
		// 1 to 4  
		selectImage(gSourceID);  
		x1=0; y1=0;  x2=gS/2; y2=0;  x3=gS/2; y3=gS/2;  x4=0; y4=gS/2;  x5=0; y5=0;  
		makeSelection(type, newArray(x1,x2,x3,x4,x5), newArray (y1,y2,y3,y4,y5));  
		roiManager("Add");  
		run("Copy");  
		selectImage(gDestinationID);  
		roiManager("Select", 0);  
		setSelectionLocation(gS/2,gS/2);  
		run("Paste");  
		run("Select None");  
			
		// 2 to 3  
		selectImage(gSourceID);  
		x1=gS/2; y1=0;  x2=gS; y2=0;  x3=gS; y3=gS/2;  x4=gS/2; y4=gS/2;  x5=gS/2; y5=0;  
		makeSelection(type, newArray(x1,x2,x3,x4,x5), newArray (y1,y2,y3,y4,y5));  
		//roiManager("Add");  
		run("Copy");  
		selectImage(gDestinationID);  
		roiManager("Select", 0);  
		setSelectionLocation(0,gS/2);  
		run("Paste");  
		run("Select None");  
		
		// 3 to 2  
		selectImage(gSourceID);  
		x1=0; y1=gS/2;  x2=gS/2; y2=gS/2;  x3=gS/2; y3=gS;  x4=0; y4=gS;  x5=0; y5=gS/2;  
		makeSelection(type, newArray(x1,x2,x3,x4,x5), newArray (y1,y2,y3,y4,y5));  
		//roiManager("Add");  
		run("Copy");  
		selectImage(gDestinationID);  
		roiManager("Select", 0);  
		setSelectionLocation(gS/2,0);  
		run("Paste");  
		run("Select None");  
		
		// 4 to 1  
		selectImage(gSourceID);  
		x1=gS/2; y1=gS/2;  x2=gS; y2=gS/2;  x3=gS; y3=gS;  x4=gS/2; y4=gS;  x5=gS/2; y5=gS/2;  
		makeSelection(type, newArray(x1,x2,x3,x4,x5), newArray (y1,y2,y3,y4,y5));  
		//roiManager("Add");  
		run("Copy");  
		selectImage(gDestinationID);  
		roiManager("Select", 0);  
		setSelectionLocation(0,0);  
		run("Paste");  
		run("Select None");  
		
		// debugging code: 
		// getSelectionBounds(xx, yy, ww, hh);  
		// fct_PrintSelectionImageInfo(x1,x2,x3,x4,x5,y1,y2,y3,y4,y5,xx,yy,ww,hh,W,H);  
		// exit;  
				
	}  
 
  // 
	// Add Number on each Slice for Publication/Debugging
	//  
	function fct_Add_number_on_slice(s,opt) {
		
		if (!sDB1) {    
			return;  
		}  
				
		if ((s==4)&&(opt==0)) {  
			setFont(getInfo("font.name"),gS/4);  
			drawString("#" + gSC, gS*0.5, gS*0.5);  
			print ("***Added Slices Numbers"+" gSC="+gSC+" gZ="+gZ+" gS="+gS);  
			return;  
		}  
			
		if (opt==0) { // Center Number  
			// print("Font=" + getInfo("font.name") +" Size=" + getValue("font.size") +" Height="+getValue("font.height"));  
			setFont(getInfo("font.name"),gZ/2);  
			drawString("#"+gSC, gS*1.75, gS+gZ/4);  
		}  
			
		if (opt==1) { // Corner Numbers  
			lFontSize=gZ/4; // font size  
			setFont(getInfo("font.name"),lFontSize);  
			drawString("<-", gS*0.2, gHeight/2+lFontSize/2);  
			drawString("^",  gS*0.9, gHeight/2-gZ*0.7+lFontSize);  
			drawString("v",  gS*0.9, gHeight/2+gZ*0.7+lFontSize/2);  
		}  
	}  
	 

}  

function fct_Main_Drawing() { // Drawing Something Functions  
  // 
  if (sDN=="A") {
		//		
    sq = 5;
    gS=1000*sq;  
    newImage("Target", "RGB White", gS*2, gS*2, 1);  
  
    x1=gS*sq;   // start in Center of picture  
    y1=gS*sq;   // start in Center of picture  
    fct_ChangeRandomSeed();  
    im=1000*sq;  // i max  
    co=256; 
		setColor(co); // color  
    low=0.33; 
		high=0.66;  
    jump=100; // jump  
  
    for (i=0;i<im;i++) {
      r1=random;  
      r2=random;  
      m1=0; if (r1<low) m1=-1; if (r1>high) m1=1;  
      m2=0; if (r2<low) m2=-1; if (r2>high) m2=1;  
      x2= x1 + m1*jump;  
      y2= y1 + m2*jump;  
  
      opt = 1;   // *** Variations I am testing ***  
      if (opt==1) {
        setLineWidth(5);  
        fct_ChangeColor(0); fillRect(x1, y1, jump, jump); // Clear background  
        fct_ChangeColor(1);  
        if (m1==-1) fillOval(x1, y1, jump, jump);  
        if (m1== 0) fillRect(x1, y1, jump, jump);  
        if (m1== 1) drawOval(x1, y1, jump, jump);  
      }  
      if (opt==2) {  
        setLineWidth(50);  
        drawLine(x1, y1, x2, y2);  
      }  
  
      // print ("i="+i +" x1/x2="+x1+"/"+x2 +" y1/y2="+y1+"/"+y2 +" m1="+m1 +" m2="+m2+ " r1="+r1 +" r2="+r2);  
        
      // What do we do if start to go out of the box ?  
      x1=x2; y1=y2;  
      if ((x1>2*gS)||(x1<0)||(y1>2*gS)||(y1<0)) {  
        opt=1; //(1: reset x/y, 2: stop)  
        if (opt==1) {  
          // print ("Center @ i="+i);  
          x1=gS; y1=gS;  
          fct_ChangeRandomSeed();  
        }  
        if (opt==2) {  
          i=im+1;  
        }  
      }  
    }  
    // Saved Files  
    fct_FormatSaveImage(false,getImageID(),false,"sDR",gDestinationDir,"Drawing_"+ sDN + ".tiff");  // Save the output image  
  }  
  
  // Not Completed 
  if (sDN=="B") {  
    // In Progress...  
  }  
  
}  
  
function fct_Main_Maze() { // Build Maze (draft - build just a frame for now)  

  print ("Maze Started");  
  
  xmax=20; ymax=xmax; // Cell Count  
  ma = newArray(xmax*ymax);  
  
  W = 1000; H = W;  
  E = W / xmax;  
  
  newImage("Maze", "RGB White", W, H, 1);  
  X = 0; Y = 0; // origin of the drawing  
  fct_ChangeColor(2);  
  colorflag=false;  
  setLineWidth(2);  
  
  for (y=0;y<ymax;y++) {  
    for (x=0;x<xmax;x++) {  
      X=x*E;  
      Y=y*E;  
      // print("E="+E+" X="+X+ " x="+x+" Y="+Y+" y="+y);  
      // _ChangeColor(1);  
      if ((y==xmax)||(y==0)) if (d()) drawLine(X,   Y,   X+E, Y);  
      if (d()) drawLine(X+E, Y,   X+E, Y+E);  
      if (d()) drawLine(X+E, Y+E, X,   Y+E);  
      if (x==0)              if (d()) drawLine(X,   Y+E, X,   Y);  
      if (colorflag) colorflag=false; else colorflag=true;  
    }  
  }  
  
	print ("Maze Completed");  

	function d() {  
		red=0;green=0;blue=0;  
		if (colorflag) {  
			red=255; green=0; blue=0;  
		}  
		else {  
			red=0; green=0; blue=255;  
		}  
		co=256*256*red+256*green+blue;  
		setColor(co);  
		return true;  
		//if (random()>0.5) return true; else return false;  
	}  


}  
 
function fct_Main_IslamicGeometricPattern(w,model) { // Islamic Geometric Pattern - Mosque X  
// w: square size  
// model: 1 - The Great Mosque of Cordoba (Spain)
// model: 2 - Esrefoglu Mosque

  print ("IslamicGeometricPattern Started");  

  red=0;
  green=0;
  blue=0; 
	
  function rc(x,y) {
    red=random*256;  
    green=random*256;  
    blue=random*256;  
    setForegroundColor(red, green, blue);
    floodFill(x, y);
  }
    
	h = w; 
	newImage("Maze", "RGB White", w, h, 1); 
		
	if (model ==1) {
				 
		Alpha = fct_da(45);  
		a = w * cos (Alpha);  
		b = (a*w) /(a+w);  
		c = b * cos (Alpha);  
		d0 = 2 * b;  
			
	  fct_ChangeColor(2);  
		lw = 4;  
		setLineWidth(lw);  
		
		// Here we draw Square #2  
		// 1 2  
		// 3 4  
		drawLine(0,0,c,w-c);    // line 1   
		drawLine(c,w-c,w,w);     // line 2  
		drawLine(0,w-b,w,w-d0);  // line 3  
		drawLine(b,w,d0,0);      // line 4  
		
		// floodfill, add color in each section
		if (0)
		{
			x = 0+lw; y = (w-b)/2;     fr = 255; fg = 0;   fb = 0;   setForegroundColor(fr, fg, fb); floodFill(x, y);     // pa  
			x = w-((w-b)/2); y = w-lw; fr = 255; fg = 0;   fb = 0;   setForegroundColor(fr, fg, fb); floodFill(x, y);     // pb  
			x = c+lw; y = w-b;         fr = 0;   fg = 255; fb = 0;   setForegroundColor(fr, fg, fb); floodFill(x, y);     // pc  
			x = w-lw; y = lw;          fr = 0;   fg = 0;   fb = 255; setForegroundColor(fr, fg, fb); floodFill(x, y);     // pd  
			x = b/2; y = lw;           fr = 100; fg = 0;   fb = 100; setForegroundColor(fr, fg, fb); floodFill(x, y);     // pe  
			x = w-lw; y = b/2;         fr = 100; fg = 255; fb = 100; setForegroundColor(fr, fg, fb); floodFill(x, y);     // pf  
			setForegroundColor(255, 255, 255); 
		}
		
		if (1)
		{
			x = 0+lw; y = (w-b)/2;     rc(x,y);  
			x = w-((w-b)/2); y = w-lw; rc(x,y);  
			x = c+lw; y = w-b;         rc(x,y);  
			x = w-lw; y = lw;          rc(x,y);  
			x = b/2; y = lw;           rc(x,y);  
			x = w-lw; y = b/2;         rc(x,y);  
			setForegroundColor(255, 255, 255); 
		}
		
		print ("w="+w+" Alpha="+Alpha+" cos(Alpha)="+cos(Alpha)+" a="+a+" b="+b+" c="+c+" d0="+d0);  
		//print ("x="+x+" y="+y);  
		
		// adjust to have what we need for Square #1 (-needed for the use of making Mandala(4)-)  
		run("Flip Horizontally", "stack");  
		
	}  

	if (model == 2) {
		//
  }

  print ("IslamicGeometricPattern Ended");  
}  
    
function fct_Menu() { // Dialog Menu() 
  	
	// Create Dialog  
	title = "Image Pattern Processor";  
	
	// Dialog.create(title);  
	Dialog.createNonBlocking(title);  
	//
	var vLine = "-------------------------------------------------------------------------------";
	Dialog.setInsets   (0,10,0);
	Dialog.addMessage  ("Mandala:");
	Dialog.setInsets   (0,20,0);    
	Dialog.addCheckbox ("  4 Slices", false);  
	// Dialog.addSlider ("  Repeat", 1, 10, 1);  
	Dialog.addToSameRow();
	Dialog.addNumber   ("  Repeat", 1);  
	Dialog.addCheckbox ("  8 Slices", false);  
	Dialog.addCheckbox ("16 Slices", false);  
	Dialog.addCheckbox ("32 Slices", false);
  Dialog.addCheckbox ("64 Slices", false);
  Dialog.addCheckbox ("128 Slices", false);
  Dialog.setInsets   (0,10,0);   
	Dialog.addMessage  (vLine);  
	Dialog.addCheckbox ("Drawing", false);  
	Dialog.addToSameRow();
	Dialog.addChoice   ("Drawing#", newArray("A","B"));  
	Dialog.addCheckbox ("Maze", false);  
	Dialog.addCheckbox ("Seamless Tile", false);   
	Dialog.addCheckbox ("Islamic Geometric Pattern", false);  
	Dialog.addToSameRow();
	Dialog.addCheckbox ("Add Square around Tile", false);  
  Dialog.setInsets   (0,10,0);   
	Dialog.addMessage  (vLine);  
  Dialog.setInsets   (0,10,0);   
	Dialog.addMessage  ("Input:");  
	Dialog.addCheckbox ("Directory Source", false);  
  Dialog.setInsets   (0,10,0);   
	Dialog.addMessage  ("Output:");  
	Dialog.addCheckbox ("Save Source", false);  
	Dialog.addCheckbox ("Save Destination", false);  
  Dialog.setInsets   (0,10,0);   
	Dialog.addMessage  (vLine);  
  Dialog.setInsets   (0,10,0);   
	Dialog.addMessage  ("Options:");  
	Dialog.addCheckbox ("Change Selection", false);  
	Dialog.addCheckbox ("PreRotateFirst", false)  
	Dialog.addCheckbox ("Show Slices/Debug", false);  
	Dialog.addCheckbox ("Run Silent Mode", false);  
	Dialog.addCheckbox ("Square Rendue", false);  
	Dialog.addChoice   ("      Interpolation:", newArray("Bilinear", "Bicubic", "None"));  // Interpolation Method
	Dialog.addCheckbox ("Reduced Resolution (before processing)", false);  
	Dialog.addCheckbox ("Low Speed Mode", false);  
	
	//
	// Info Section
	//
	Dialog.setInsets   (0,10,0); 
	Dialog.addMessage  (vLine);  
  Dialog.setInsets   (0,10,0); 
	Dialog.addMessage  ("ImageJ Version = " + ijv);
	
	Dialog.setInsets   (0,10,0); 
	// var mem = toString ( floor (parseInt(IJ.currentMemory()) / parseInt(IJ.maxMemory()) * 100) ); // mem usage (%)
	// Dialog.addMessage  ("Mem = " + IJ.currentMemory())
	Dialog.addMessage  ("Mem = " + IJ.freeMemory());
	// Dialog.addMessage  ("Mem = " + IJ.maxMemory());
	// Dialog.addMessage  ("Mem = " + mem + "\%");
	
	Dialog.setInsets   (0,10,0); 
	Dialog.addMessage  ("Execution Time = " + sExecTimeTotal);
	
	// Show Dialog  		
	Dialog.show();

  // Read the Selections 
  // *** it needs to be in the same order *** 
   
  s04 = Dialog.getCheckbox();    print ("s04="+s04);  
  sRP = Dialog.getNumber();      print ("sRP="+sRP);  
  s08 = Dialog.getCheckbox();    print ("s08="+s08);  
  s16 = Dialog.getCheckbox();    print ("s16="+s16);  
  s32 = Dialog.getCheckbox();    print ("s32="+s32);  
  s64 = Dialog.getCheckbox();    print ("s64="+s64);  
  s128 = Dialog.getCheckbox();   print ("s128="+s128);  
    
  sDR = Dialog.getCheckbox();    print ("sDR="+sDR);  
  sDN = Dialog.getChoice();      print ("sDN="+sDN);  
    
  sMa = Dialog.getCheckbox();    print ("sMa="+sMa);  
  sST = Dialog.getCheckbox();    print ("sST="+sST);  
  sIGP = Dialog.getCheckbox();   print ("sIGP="+sIGP);  
  sIGPsq = Dialog.getCheckbox(); print ("sIGPsq="+sIGPsq);  
   
  sDi = Dialog.getCheckbox();    print ("sDi="+sDi); // Directory  
    
  sSS = Dialog.getCheckbox();    print ("sSS="+sSS);  
  sSD = Dialog.getCheckbox();    print ("sSD="+sSD);  
    
  sCS = Dialog.getCheckbox();    print ("sCS="+sCS); // Change Selection  
  sRO = Dialog.getCheckbox();    print ("sRO="+sRO); // Rotate Image before to add selection  
  sDB1 = Dialog.getCheckbox();   print ("sDB1="+sDB1);   
  sSM = Dialog.getCheckbox();    print ("sSM="+sSM); // Silent Mode  
  sSR = Dialog.getCheckbox();    print ("sSR="+sSR); // Square Mode 
  sRM = Dialog.getChoice();      print ("sRM="+sRM); // Rotate Method - Interpolation Mode
  sRR = Dialog.getCheckbox();    print ("sRR="+sRR); // Reduce Scale  
	sLP = Dialog.getCheckbox();    print ("sLP="+sLP); // Low Speed  
	// +Duration Line
	
}  
 
function fct_FormatSaveImage(ot, id, cl, fct, dir, fn) { // Format and Save the Image 

  // ot:  output type (true=circle/crop,false=as is)  
  // id:  picture id to be saved  
  // cl:  close the picture  
  // fct: function name 
  // dir: directory 
  // fn:  file name 
 
  // ffn = dir + "\\ij." + fct + "." + fn + "." +fct_DT(); 
  ffn = dir + "\\ij." + fct + "-" + sRM + "." + fn + "." +fct_DT(); 
                                                     
  if (ot) {  
    // Select Circle Output  
    selectImage(id);  
    makeOval(0, 0, gS*2, gS*2);  
    run("Clear Outside");  
  }  
  
  // Save and Close the output file  
  selectImage(id);  
  if (ot) {   
    run("Crop");    
    run("Select None");  
  }  
  
  if (sSD) {  
    saveAs("Tiff", ffn);  
    print ("SaveAs of " + ffn);  
    if (cl) run("Close");  
  }  
}  
  
function fct_DrawTheSelection (pSlices, pID) { // Draw the select based on the Slices # 

	// pSlices: Number of Slices  
  // pID:     Image ID  
  //
	
	// for 4, select biggest possible square 
	// for >4, Horizontal Camember (center middel left of the squared image) 

  selectImage(pID); // Select Source Image using Image ID 
  getDimensions(width, height, channels, slices, frames);  
  gWidth = width;   
  gHeight = height;  
  // print ("X: gSourceID="+gSourceID+" gWidth="+gWidth+" gHeight="+gHeight);  
     
  if (pSlices==4) { // =4 
    
    gS = minOf(gHeight, gWidth); // smallest square  
    type = "freehand";  
    x1=0; y1=0;  x2=gS; y2=0;  x3=gS; y3=gS;  x4=0; y4=gS;  x5=0; y5=0;  
  
    if (sDB1) 
		 fct_Drawline(x1,x2,x3,x4,y1,y2,y3,y4); 
      
    makeSelection(type, newArray(x1,x2,x3,x4,x5), newArray (y1,y2,y3,y4,x5));  
    print ("gS=" + gS);  
    print ("_Fct_DrawTheSelection() - Completed");  
  }  
  
  if (pSlices>4) { // >4 like 8, 16 and 32 
    
    gA = 360 / pSlices; // angle in degre  
    print ("pSlices=" + pSlices + " gA=" + gA);  
  
    gAdjustement = 1;  // Needed to adjust Selection to remain inside the picture canvas  
    Alpha = fct_da(gA/2); // 1/2 of the Angle  
  
		//
		// Selection Options
		//
		// Option 1 - use gS as W, and check that gZ is less than H/2
		// Option 2 - use gZ as H/2, and check that Gs is less than W
		// Option 3 - reduce area to min of W or H
		
		// Option 1
		gS = gWidth;
		gZ = gS * tan(Alpha);
		gZ = floor(gZ) + 1; 		  // round to the next integer
		if (gZ <= (gHeight / 2)) {
			// good
			print ("Selection Option #1");
		}
		else { // Option 2
		
			gZ = gHeight / 2;
			gS = gZ / tan(Alpha);
			gS = floor(gS) + 1; 		  // round to the next integer
			if (gZ <= (gHeight / 2)) {
				// good
				print ("Selection Option #2");
			} 
			else { // Option 3 - Reduce to smallest square
				gM = minOf(gHeight, gWidth); 	// smallest square
				gS = gM ;	 					  				// Height for the selection
				gZ = gS * tan(Alpha); 				// Width for the selection
				gZ = floor(gZ) + 1; 		  		// round to the next integer
				print ("Selection Option #3");
			}
		}	
		
		
		lL = gHeight/2;  
  
		if (0) {
			print ("gWidth     = " + gWidth);
			print ("gHeight    = " + gHeight);
			print ("lL         = " + lL);
			print ("gS         = " + gS);
			print ("gZ         = " + gZ);
			print ("pSlices    = " + pSlices);
			print ("gA         = " + gA);
			print ("Alpha      = " + Alpha);
			print ("tan(Alpha) = " + tan(Alpha));
		}
		
    // Add some pixel around the selection so we don't see white pixels
    // +-gAdjustement for the fours points with A, B, C and D  
    x1= 0; y1=lL      -gAdjustement;  
    x2=gS; y2=lL - gZ -gAdjustement;  
    x3=gS; y3=lL + gZ +gAdjustement;  
    x4= 0; y4=lL      +gAdjustement;  
  
		//
		// April 25 2023
		// Without below, some images are not working at all.
		//
		// TO BE RESTESTED WITHOUT THE BELOW
		//
		x1 = floor(x1);
		x2 = floor(x2);
		x3 = floor(x3);
		x4 = floor(x4);
		y1 = floor(y1);
		y2 = floor(y2);
		y3 = floor(y3);
		y4 = floor(y4);
		//
		
    if (sDB1) 
		 fct_Drawline(x1,x2,x3,x4,y1,y2,y3,y4);  
     
    makeSelection("freehand", newArray(x1,x2,x3,x4), newArray (y1,y2,y3,y4)); 
      
    getSelectionBounds(xx, yy, ww, hh);  
    fct_PrintSelectionImageInfo(x1,x2,x3,x4,0,y1,y2,y3,y4,0,xx,yy,ww,hh,gWidth,gHeight);  
  }  
	if (sCS) 
			waitForUser("Pending User Intervention", "Change/Move selection");  
}  
  
//
// =============================================================================  
// Utilities Functions  
// =============================================================================  
//
  
function fct_FileDirSelection() { // Selection of one File or one Directory  
	
  // Directory Selection  
  //====================  
  if (sDi) {
		//
    gDirpath = getDirectory("Choose a Directory ");  
    gDirlist = getFileList(gDirpath);  
    if (gDirlist.length>0)  
      return (true);  
  }  
  // File Selection  
  // ==============  
  else {		
    // is there a file already opened   
    if (nImages>0) {   
      // File is opened  
      return (true);  
    } 
    else {  
      // No File Opened   
      fn=File.openDialog(gPgmTitle + "- Please select source file:");  
      print ("File Selected = " + fn);  
      open(fn);  
      return (true);  
    }  
  }  
  // nothing, will exit...  
  return (false);  
}  

function fct_da(a) { // Convert Degree to 'Radiant' 
	//
  n = a*PI/180;  
  print ("a=" + a + " PI/180=" + PI/180 + "_da(a)="+ n);  
  return (n);  
}  
 
function fct_Drawline(x1,x2,x3,x4,y1,y2,y3,y4) { // Draw 4 black lines 
	//
	// Draw 4 black lines 
	// ------------------ 
	// x1,y1 
	// x2,y2 
	// x3,y3 
	// x4,y4 
	// 
  fct_ChangeColor(2);  
  setLineWidth(5);  
  drawLine(x1, y1, x2, y2);  
  drawLine(x2, y2, x3, y3);  
  drawLine(x3, y3, x4, y4);  
  drawLine(x4, y4, x1, y1);  
}  
 
function fct_ChangeRandomSeed() { // Change Random Seed 
	//
  getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);  
  seed=round(1000*second*random);  
  random("seed", seed);  
}  
 
function fct_ChangeColor(r) { // Change Drawing Color 

	// r: 0 for reset to white (default)  
  //    1 for random  
  //    2 black
	
  co=0; 
  if (r==1) {  
    red=random*256;  
    green=random*256;  
    blue=random*256;  
    co=256*256*red+256*green+blue;  
  }  
  if (r==0) {  
    // co = 0;  // Black value  
    red=255;  
    green=255;  
    blue=255;  
    co=256*256*red+256*green+blue; // White value  
  }  
  if (r==2) { // Black 
    co=0;  
  }  
    
  setColor(co);  
}  
  
function fct_DT() { // Return Date Time Stamp 
	
  getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);  
  //print ("year="+year +", month="+(month+1)+", dayOfWeek="+dayOfWeek+", dayOfMonth="+dayOfMonth+", hour="+hour+", minute="+minute+", second="+second+", msec="+msec);  
  DT = d2s(month+1,0)+"-"+d2s(dayOfMonth,0)+"-"+d2s(year,0)+"_"+d2s(hour,0)+"-"+d2s(minute,0)+"-"+d2s(second,0);  
  return DT;  
}  

function ExecDuration(begin,end,option) { //
	//
	// option: 1: return ms between begin and end
	//         X: return  s between begin and end
  //
	
	var MS = floor(end-begin);
	var Delta = MS / 1000; // floor ((end-begin) / 1000);
	var Minutes = floor (Delta / 60);
	var Seconds = Delta - (Minutes * 60);
	var Duration = toString(Minutes) + " m " + toString(Seconds) + " s";
	
	if(option==1) return toString(MS);
	
	return Duration;
}	

function fct_TS() { // Return Time Spent since last call
	var TS = ExecDuration (gDT, getTime(),1);
	gDT = getTime();
  return TS;  
}  

function fct_Log (text) { // logging...
	// CSV Format
	print (fct_DT() + "," + text + "," + fct_TS() + " ms");
}

function fct_PrintSelectionImageInfo(x1,x2,x3,x4,x5,y1,y2,y3,y4,y5,xx,yy,ww,hh,W,H) { // Print Image Information 

  print ("Image Selection:");  
  print ("=========================================================");  
  print ("  Width="+W +" Height="+H);  
  print ("  gS="+gS   +" gZ="+gZ);  
  print ("  x1="+x1   +" y1="+y1);  
  print ("  x2="+x2   +" y2="+y2);  
  print ("  x3="+x3   +" y3="+y3);  
  print ("  x4="+x4   +" y4="+y4);  
  print ("  x5="+x5   +" y5="+y5);  
  print ("  Bounds is ("+xx+","+yy+","+ww+","+hh+")");  
  print ("=========================================================");  
	
}  
  
function fct_Read_image_info() { // Read information from the current active file   
 
  // gDestinationDir=getInfo("image.directory") + gTargetSubdir;  
  gSourceFileName = getInfo("image.filename");  
  gSourceID = getImageID();  
   
  getDimensions(width, height, channels, slices, frames);  
  gWidth = width;  
  gHeight = height;  
  
  print ("Info=" + getMetadata("Info") );  
  print ("getDimensions(" + gWidth + "," + gHeight + "," + channels + "," + slices + "," + frames + ")" );  
  print ("bitDepth="+ bitDepth()          );  
  //print ("X"+ " gWidth="+ gWidth + " gHeight=" + gHeight);  
   
  if (File.isDirectory(gDestinationDir)!=1) File.makeDirectory(gDestinationDir);  
  print ("gDestinationDir=" + gDestinationDir );  
}  

function fct_Reduce_Resolution() { // Reduce Resolution (Speed up Process)
  // needed due to memory limitation with imagej 
  if (sRR) {
		//
    if (gWidth>3000) { // 3000x3000=~34Mb
      //
      run("Size...", "width=1000 height=1000 constrain average interpolation=Bilinear");
      // run("Scale...", "x=0.25 y=0.25 interpolation=Bilinear average title=Target-1");        
      /*
      run("Original Scale");
      run("View 100%");
      run("To Selection");
      run("Set... ", "zoom=100 x=2611 y=2611");
      run("Scale...");
      run("Set... ", "zoom=100 x=1000 y=1000");
      run("View 100%");
      */
    }
  }
}  
  
function fct_Mem() { // Report Memory Status 
  print ("IJ.maxMemory()="+IJ.maxMemory()+" IJ.currentMemory()="+IJ.currentMemory()+" IJ.freeMemory()="+IJ.freeMemory());  
}  
  
// END MACRO ===================================================================  