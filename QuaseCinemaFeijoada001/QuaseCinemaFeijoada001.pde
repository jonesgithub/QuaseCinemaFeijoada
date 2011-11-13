//
// Quase-Cinema Feijoada 0.01
// Alexandre Rangel
// www.quasecinema.org
//
// built with Processing 2.0 alpha 2
// 2011.11.12
//

import controlP5.*; // controlP5 library
import codeanticode.gsvideo.*; // GSvideo library

import javax.media.opengl.GL; // openGL library
import processing.opengl.*; // openGL library

import sojamo.drop.*; // sDrop library


// controlP5
ControlP5 controlP5;
ControlWindow controlWindow;
ControlWindowCanvas cc;

ColorPicker colorPicker1, colorPicker2, colorPicker3, colorPicker4;

ListBox outputResolutionList;

public int fpsValue = 0;

// movies
public GSMovie myMovie1, myMovie2, myMovie3, myMovie4;

// directory
public String[] fileNames;
public String folderPath = " ";
ListBox dirListBox;

String newMovie = "";
public boolean change1 = false; boolean change2 = false; boolean change3 = false; boolean change4 = false;

SDrop drop;

// file filter
java.io.FilenameFilter txtFilter = new java.io.FilenameFilter() {
  boolean accept(File dir, String name) {
    return name.toLowerCase().endsWith(".mov")
    || name.toLowerCase().endsWith(".avi")
    || name.toLowerCase().endsWith(".mp4")
    || name.toLowerCase().endsWith(".ogg")
    || name.toLowerCase().endsWith(".mpg");
  }
};

//  quad mapping pre setup
String configFile = "data/quadsconfig.txt";
ProjectedQuads projectedQuads;
//PImage    quadImage;  
PGraphics quadGraphics1, quadGraphics2, quadGraphics3, quadGraphics4;

// variables pre setup
public int selectedLayer = 0;
//int myColorBackground = color(0,0,0);
int interfaceWidth = 1024;
int columnWidth = int (interfaceWidth/4);

float fade = 0.0;

public int changeResolution = 100;
//public int outputWidth = 1024; public int outputHeight = 768;
public int outputWidth = 1280; public int outputHeight = 1024;

boolean  layer1visibility = true;
boolean  layer2visibility = false; boolean  layer3visibility = false; boolean  layer4visibility = false;

boolean mapping1 = false; boolean mapping2 = false; boolean mapping3 = false; boolean mapping4 = false;

int layer1bpmVis, layer2bpmVis, layer3bpmVis, layer4bpmVis;

float layer1speed = 1.0; float layer2speed = 1.0; float layer3speed = 1.0; float layer4speed = 1.0;
//float layer1transparency = 255; float layer2transparency = 255; float layer3transparency = 255; float layer4transparency = 255;
public float layer1playback, layer2playback, layer3playback, layer4playback;

	

public boolean effectInvert1 = false; public boolean effectInvert2 = false;
public boolean effectInvert3 = false; public boolean effectInvert4 = false; 

public boolean effectPosterize1 = false; public boolean effectPosterize2 = false;
public boolean effectPosterize3 = false; public boolean effectPosterize4 = false; 


public void init(){
  frame.removeNotify();
  frame.setUndecorated(true);
  frame.addNotify();
  super.init();
}

// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------

//
// interface canvas screen
//

class MyCanvas extends ControlWindowCanvas {
  
  public void draw(PApplet theApplet) {
    
    
    // layer base
    theApplet.fill(40);
    theApplet.rect(0+(columnWidth*selectedLayer),20,columnWidth,700,3);
    
    
    // layer icons
    if (frameCount > 1) {
      theApplet.fill(128);
      theApplet.rect(8,22,164,124);
      theApplet.image(myMovie1, 10, 24, 160, 120);
      theApplet.rect(8+(columnWidth*1),22,164,124);
      theApplet.image(myMovie2, 10+(columnWidth*1), 24, 160, 120);
      theApplet.rect(8+(columnWidth*2),22,164,124);
      theApplet.image(myMovie3, 10+(columnWidth*2), 24,160, 120);
      theApplet.rect(8+(columnWidth*3),22,164,124);
      theApplet.image(myMovie4, 10+(columnWidth*3), 24,160, 120);
    }
    

    
//    if(theApplet.mousePressed) {
//      theApplet.fill(255,0,0,155);
//      theApplet.ellipse(theApplet.mouseX,theApplet.mouseY,20,20);
//    }

  //dropArea1.draw();
    
  }
}

// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------

// select an input dir
//File[] listFiles(String dir) {
//  
//    File file = new File(dir);
//
//    if (file.isDirectory()) {
//	File[] files = file.listFiles();
//	return files;
//    } else {
//	// If it's not a directory
//	return null;
//    }
//}


// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------


void setup() {
  size(outputWidth, outputHeight, OPENGL);
  //hint(ENABLE_OPENGL_4X_SMOOTH);
  frame.setResizable(true);
  frameRate(60);
  //frame.setLocation(screen.width,0);
  //frame.setLocation(1024,0);
  frame.setLocation(1440,0);
  
  // variables setup
  QCsetupInterface();
  
  //
  // GStreamer setup
  //
  
  GSVideo.localGStreamerPath = "/Users/rangel/Documents/processing/libraries/GSVideo/library/gstreamer/macosx32";
  
  myMovie1 = new GSMovie(this, "Aviao.mov"); myMovie1.loop();
  
  myMovie2 = new GSMovie(this, sketchPath("data/Palatnik1.mov")); myMovie2.loop();
  
  myMovie3 = new GSMovie(this, sketchPath("data/Palatnik2.mov")); myMovie3.loop();
  
  myMovie4 = new GSMovie(this, sketchPath("data/Palatnik3.mov")); myMovie4.loop();
  
  //
  // projectedQuads setup
  //
  
  projectedQuads = new ProjectedQuads();  
  projectedQuads.load(configFile);  
  
  //we want to display 3 quads so if there was no config file or less than 3 were defined we increase num to 3
  if (projectedQuads.getNumQuads() < 4) { projectedQuads.setNumQuads(4); }
  
  quadGraphics1 = createGraphics(640, 480, OPENGL);
  quadGraphics2 = createGraphics(640, 480, OPENGL);
  quadGraphics3 = createGraphics(640, 480, OPENGL);
  quadGraphics4 = createGraphics(640, 480, OPENGL);
  
  projectedQuads.getQuad(0).setTexture(quadGraphics1); 
  projectedQuads.getQuad(1).setTexture(quadGraphics2);
  projectedQuads.getQuad(2).setTexture(quadGraphics3); 
  projectedQuads.getQuad(3).setTexture(quadGraphics4); 
  
  // drop setup
  drop = new SDrop(controlWindow.component(),this);
  
  
  
} // end setup

// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------

public void movieEvent(GSMovie gsMovie) {
  
  gsMovie.read();
  
  QCeffects();
}


// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------

void controlEvent(ControlEvent theEvent) {
  // ListBox is if type ControlGroup.
  // 1 controlEvent will be executed, where the event originates from a ControlGroup. therefore
  // you need to check the Event with if (theEvent.isGroup()) to avoid an error message from controlP5.
  
  if (theEvent.isGroup()) {
    // an event from a group e.g. scrollList
    //println(theEvent.group().value()+" from "+theEvent.group());
    
    if (theEvent.group() == outputResolutionList) {
      changeResolution = (int (theEvent.group().value()) );
    }
  }
}

// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------


public void draw() {
  
  background(0);
  
  //
  // drop
  //
  
  if (change1 == true && selectedLayer == 0) {
   myMovie1 = new GSMovie(this, newMovie);
   myMovie1.play();
   myMovie1.loop();
   change1 = false; 
  }
  
  
  //
  // interface update
  //
  if (random(100)>50){ controlP5.controller("fpsValue").setValue(int(frameRate)); }

  // playback heads
  controlP5.controller("layer1playback").setValue(map(myMovie1.time(),0.0,myMovie1.duration(),0.0,1.0));
  controlP5.controller("layer2playback").setValue(map(myMovie2.time(),0.0,myMovie2.duration(),0.0,1.0));
  controlP5.controller("layer3playback").setValue(map(myMovie3.time(),0.0,myMovie3.duration(),0.0,1.0));
  controlP5.controller("layer4playback").setValue(map(myMovie4.time(),0.0,myMovie4.duration(),0.0,1.0));

  
  
  //controlP5.draw();
  
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  //  output draw
  //
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  // pre-render layer 1
  if (layer1visibility) {
    //tint(red(colorPicker1.getColorValue()), green(colorPicker1.getColorValue()), blue(colorPicker1.getColorValue()));
    tint(colorPicker1.getColorValue());
    myMovie1.play();
    myMovie1.speed(layer1speed);
    if (mapping1) {
      // mapping
      quadGraphics1.beginDraw();
      image(myMovie1, 0, 0, 640, 480); 
      quadGraphics1.endDraw();
    } else {
      // no mapping
      image(myMovie1, 0, 0, outputWidth, outputHeight); 
    } // end if mapping
  } else {
     myMovie1.pause();
  }// end if layer1visibility
  
  // pre-render layer 2
  if (layer2visibility) {
    tint(colorPicker2.getColorValue());
    myMovie2.play();
    myMovie2.speed(layer2speed);
    if (mapping2) {
      // mapping
      quadGraphics2.beginDraw();
      image(myMovie2, 0, 0, 640, 480); 
      quadGraphics2.endDraw();
    } else {
      // no mapping
      image(myMovie2, 0, 0, outputWidth, outputHeight); 
    } // end if mapping
  } else {
     myMovie2.pause();
  }// end if layer2visibility
  
  
  // pre-render layer 3
  if (layer3visibility) {
    tint(colorPicker3.getColorValue());
    myMovie3.play();
    myMovie3.speed(layer3speed);
    if (mapping3) {
      // mapping
      quadGraphics3.beginDraw();
      image(myMovie3, 0, 0, 640, 480); 
      quadGraphics3.endDraw();
    } else {
      // no mapping
      image(myMovie3, 0, 0, outputWidth, outputHeight); 
    } // end if mapping
  } else {
     myMovie3.pause();
  }// end if layer3visibility
  
  // pre-render layer 4
  if (layer4visibility) {
    tint(colorPicker4.getColorValue());
    myMovie4.play();
    myMovie4.speed(layer4speed);
    if (mapping4) {
      // mapping
      quadGraphics4.beginDraw();
      image(myMovie4, 0, 0, 640, 480); 
      quadGraphics4.endDraw();
    } else {
      // no mapping
      image(myMovie4, 0, 0, outputWidth, outputHeight); 
    } // end if mapping
  } else {
     myMovie4.pause();
  }// end if layer4visibility
  
  // mapping draw
  if (mapping1 || mapping2 || mapping3 || mapping4) {
    projectedQuads.draw();
  }
  
  
  // render fade
  if (fade > 0.0) {
    fill(0,0,0,map(fade,0.0,100.0,0,255));
    rect(0,0,outputWidth,outputHeight);
  } 
  
  if (changeResolution != 100) { QCchangeResolution(); }
  
} // end draw




// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------


//int mX;
//int mY;

void mousePressed(){
  
  projectedQuads.mousePressed();
  
  //mX = mouseX;
  //mY = mouseY;
}

void mouseDragged(){
  
  projectedQuads.mouseDragged();
  
  //frame.setLocation(MouseInfo.getPointerInfo().getLocation().x-mX, MouseInfo.getPointerInfo().getLocation().y-mY);
}

// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------

void keyPressed(){
 
  projectedQuads.keyPressed();
  
  switch(key) {
     case '1':
       selectedLayer = 0; break; 
     case '2':
       selectedLayer = 1; break;
     case '3':
       selectedLayer = 2; break;
     case '4':
       selectedLayer = 3; break;
     
  case 'd': 
    String folderPath = selectFolder();
    if (folderPath == null) {
      println("No folder was selected..."); // if no folder was selected
    } 
    else {
      println(folderPath);
      fileNames = listFileNames(folderPath, txtFilter);
      println(fileNames);
      //for(int i=0;i<fileNames.length;i++) { 
        //
      //}
      //dirListBox.addItem(fileNames[0],0);
    }
break; // break 'd'
    
  case 'u':
    //myMovie.stop(); myMovie2.delete();
    myMovie1 = new GSMovie(this, "Palatnik2.mov");
    //myMovie1.read(); myMovie1.play();
    //file = File.getParentFile();
    //myMovie1.loadMovie();
    
    break; // break 'd'
    
  case 'r': //xxx
//    String tempString = selectFolder() + fileNames[int(random(fileNames.length))]; 
//    myMovie1 = new GSMovie(this, tempString);
//    myMovie1.loop();
    break; // break 'r'
    
  case 'i': //xxx
   effectInvert1 = !(effectInvert1);
  break; // break 'i'
    
  } // end switch 
}


// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------


// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir,java.io.FilenameFilter extension) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list(extension);
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}


// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------



  void dropEvent(DropEvent theDropEvent) {
    if(theDropEvent.isFile()) {
      File myFile = theDropEvent.file();
      if(myFile.isFile()) {
        println("toString()\t"+theDropEvent.toString());
        newMovie = theDropEvent.toString();
        change1 = true;
      }
    } // end theDropEvent.isFile()   
  } // end dropEvent


//class MyDropListener2 extends DropListener {
//  MyDropListener2() { setTargetRect(columnWidth*1,20,columnWidth*2,screenHeight); }
//  void dropEvent(DropEvent theEvent) {
//    if(theEvent.isFile()) {
//      File myFile = theEvent.file();
//      if(myFile.isFile()) {
//        println("toString()\t"+theEvent.toString());
//        newMovie = theEvent.toString();
//        change2 = true;
//      }
//    } // end theDropEvent.isFile()   
//  } // end dropEvent
//} // end class myDropListener
  
  
  
public void stop() {
  super.stop();
} 
  
      
      
      
      
      
      
      //println(myMouseX);
//      if ((mouseX - controlWindow.position()) < (columnWidth*2) ) {
//          myMovie2 = new GSMovie(this, theDropEvent.toString()); myMovie2.read();
//      } else if (mouseX > (columnWidth*2) && mouseX < (columnWidth*3) ) {
//          myMovie3 = new GSMovie(this, theDropEvent.toString()); myMovie3.read();
//      } else if (mouseX > (columnWidth*3) && mouseX < (columnWidth*4) ) {
//          myMovie4 = new GSMovie(this, theDropEvent.toString()); myMovie4.read();
//      }
//    }
//  }
//}



