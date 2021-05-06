// PlotMaker mk.II By Adam Dworetzky
// A program to help make line drawn adaptations of images and text with added noise for variation
// Includes color options, export sizing, different font choices, and some other things!
// Use, add to, break, and fix however you would like. The only thing I ask is that you make cool stuff

//Instructions before using:
//Must install Drop, HersheyFont, Control.P5, and Processing.SVG. All are available in the native processing libraries tool

// The random images pulled from the web are all from unsplash.com, the rights to said photos are free for commercial and non-commercial use. Policy can be found here:https://unsplash.com/license

// Copyright 2021 Adam Dworetzky
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import processing.svg.*;
import de.ixdhof.hershey.*;
import controlP5.*;
import drop.*;
import milchreis.imageprocessing.*;
import milchreis.imageprocessing.utils.*;
import at.mukprojects.console.*;


ControlP5 cp5;
SDrop drop;
Console console;
NoiseField nfCyan;
NoiseField nfMagenta;
NoiseField nfYellow;
NoiseField nfBlack;

//  TODO
// change layer color (DONE)
// drag and drop img (DONE)
// change size of export(done) with presets for different papers(DONE)
// Font Selection (DONE)
// Dual Images, like double exposure (stretch but cool)
// image filter and simple adjustments (done?)
// toggles to turn on and off layers (NOT DONE)
// Toggle to switch back to blue, red, and black layer (NOT DONE)
// Random word input for text layer (NOT DONE)
// rotate image button (NOT DONE)
// switch width and height button(NOT DONE)
// if no image data, dont draw (NOT DONE)
// Image resize Error, doesnt always work
// lable in margin wont draw to fi buffer

PGraphics ib;
PGraphics tb;
PGraphics fi;

PImage imageForBuffer;
PFont font;
HersheyFont hf;

String unsplashKeyword = "";
int imageDimensionWidth = 900;
int imageDimensionHeight = 1600;
PVector bufferDimensions;

int margin;
float displacmentFactor = 20;
float noiseVar;
int randNoiseSeed;

boolean record = false;
boolean layer1On = false;
boolean layer2On = false;
boolean layer3On = false;
boolean layer4On = false;
boolean splitView = true;
boolean showConsoleOn = true;
boolean imageView, outputView;

int uiOriginX = 0;
int uiOriginY = 0;

color uIbackground = color(80,200);
color uIForground = color(90);
color uIActive = color(120);

Slider viewportScalerSlider, toleranceRangeSlider, textXPosSlider, textYPosSlider, textRotationSlider, tSizeSlider, leadingSlider, spacingSlider, imageXPosSlider, imageYPosSlider, imageScaleSlider, marginSlider, brightnessSlider, textBoxWidthSlider;
Range yellowToleranceRange, magentaToleranceRange, cyanToleranceRange, blackToleranceRange;
float viewportScaler, toleranceRange, textXPos, textYPos, textRotation, tSize, leading, lineSpacing, imageXPos, imageYPos, imageScale, yellowTolerance, magentaTolerance, cyanTolerance, blackTolerance, exposure, textBoxWidthOffset;

ColorWheel layer1CP, layer2CP, layer3CP, layer4CP;
float layer1ColorPicker,layer2ColorPicker,layer3ColorPicker, layer4ColorPicker;

Textfield tbInput, unsplashKeywordInput, outputHeightInput, outputWidthInput;

ScrollableList sizePresetList, viewportPresetList, fontSelectionList;

void setup() {
    // size(1000, 1000);
    size(1440, 880,JAVA2D);
    background(10);
    surface.setResizable(true);

    font = createFont("fonts/Basteleur-Bold.ttf", 50);
    smooth();

    // set up graphics buffers
    // postcard:383,575, a4: 598,842,a3:842,1191, Tabloid: 1225,842, Letter: 612,842
    bufferDimensions = new PVector(383, 575);
    ib = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y),JAVA2D);
    tb = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y),JAVA2D);
    fi = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y),JAVA2D);
    fi.smooth(8);

    // Drag and Drop Setup
    drop = new SDrop(this);

    // Hershey Font label set up
    hf = new HersheyFont(this, "futural.jhf");
    hf.textSize(5);

    // Sdrop setup
    drop = new SDrop(this);

    // set up UI
    cp5 = new ControlP5(this);

    // Console draw set up
    console = new Console(this);
    console.start();

    // create tabs
    cp5.addTab("Text")
        .setColorBackground(uIbackground)
        .setColorLabel(color(255))
        .setColorActive(uIActive);
    cp5.addTab("Output")
        .setColorBackground(uIbackground)
        .setColorLabel(color(255))
        .setColorActive(uIActive);
    cp5.addTab("Viewport")
        .setColorBackground(uIbackground)
        .setColorLabel(color(255))
        .setColorActive(uIActive);
    cp5.addTab("Export")
        .setColorBackground(uIbackground)
        .setColorLabel(color(255))
        .setColorActive(uIActive);
    cp5.getTab("default")
        .setColorBackground(uIbackground)
        .setColorLabel(color(255))
        .setColorActive(uIActive)
        .setLabel("Image");

    // create UI elements
    viewportScalerSlider = makeSlider("viewportScaler", uiOriginX+10, uiOriginY+30, 0, 2, .90);
    imageXPosSlider = makeSlider("imageXPos", uiOriginX+10, uiOriginY+75, -ib.width / 2, ib.width / 2, 0);
    imageYPosSlider = makeSlider("imageYPos", uiOriginX+10, uiOriginY+90, -ib.height / 2, ib.height / 2, 0);
    imageScaleSlider = makeSlider("imageScale", uiOriginX+10, uiOriginY+105, 0, 2, 1);
    cp5.addTextlabel("exposureLabel")
        .setText("EXPOSURE")
        .setPosition(uiOriginX+35,uiOriginY+135)
        ;
    cp5.addButton("exposureDown")
        .setValue(0)
        .setPosition(uiOriginX+10, uiOriginY+130)
        .setSize(20, 20)
        .setCaptionLabel("-");
    cp5.addButton("exposureUp")
        .setValue(0)
        .setPosition(uiOriginX+90, uiOriginY+130)
        .setSize(20, 20)
        .setCaptionLabel("+");

    cp5.addTextlabel("contrastLabel")
        .setText("CONTRAST")
        .setPosition(uiOriginX+35,uiOriginY+165)
        ;
    cp5.addButton("contrastDown")
        .setValue(0)
        .setPosition(uiOriginX+10, uiOriginY+160)
        .setSize(20, 20)
        .setCaptionLabel("-");
    cp5.addButton("contrastUp")
        .setValue(0)
        .setPosition(uiOriginX+90, uiOriginY+160)
        .setSize(20, 20)
        .setCaptionLabel("+");

    // http://www.sojamo.com/libraries/controlP5/reference/controlP5/Range.html
    yellowToleranceRange = cp5.addRange("yellowTolerance")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(uiOriginX+10,uiOriginY+30)
             .setSize(200,20)
             .setHandleSize(10)
             .setRange(-5,5)
             .setRangeValues(-1,1)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(uIActive)
             .setColorBackground(uIbackground)  
             ;
    magentaToleranceRange = cp5.addRange("magentaTolerance")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(uiOriginX+10,uiOriginY+60)
             .setSize(200,20)
             .setHandleSize(10)
             .setRange(-5,5)
             .setRangeValues(-1,1)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(uIActive)
             .setColorBackground(uIbackground)  
             ;
    cyanToleranceRange = cp5.addRange("cyanTolerance")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(uiOriginX+10,uiOriginY+90)
             .setSize(200,20)
             .setHandleSize(10)
             .setRange(-5,5)
             .setRangeValues(-1,1)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(uIActive)
             .setColorBackground(uIbackground)  
             ;
    blackToleranceRange = cp5.addRange("blackTolerance")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(uiOriginX+10,uiOriginY+120)
             .setSize(200,20)
             .setHandleSize(10)
             .setRange(-5,5)
             .setRangeValues(-1,1)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(uIActive)
             .setColorBackground(uIbackground) 
             ;
    toleranceRangeSlider = makeSlider("toleranceRange", uiOriginX+10, uiOriginY+150, 0, 5, 2);
    tSizeSlider = makeSlider("tSize", uiOriginX+10, uiOriginY+75, 0, 500, 70);
    textXPosSlider = makeSlider("textXPos", uiOriginX+10, uiOriginY+30, -tb.width / 2, tb.width / 2, 0);
    textYPosSlider = makeSlider("textYPos", uiOriginX+10, uiOriginY+45, -tb.height / 2, tb.height / 2, 0 - tSize / 2);
    leadingSlider = makeSlider("leading", uiOriginX+10, uiOriginY+90, -100, 100, 0);
    marginSlider = makeSlider("margin", uiOriginX+10, uiOriginY+165, 5, 100, 30);
    textBoxWidthSlider = makeSlider("textBoxWidthOffset", uiOriginX+10, uiOriginY+105, 0, tb.width / 2, 0);
    textRotationSlider = cp5.addSlider("textRotation")
        .setPosition(uiOriginX+10, uiOriginY+60)
        .setWidth(100)
        .setRange(0, 360)
        .setValue(0)
        .setColorForeground(uIActive)
        .setNumberOfTickMarks(13);
    spacingSlider = cp5.addSlider("lineSpacing")
        .setPosition(uiOriginX+10, uiOriginY+180)
        .setWidth(100)
        .setRange(1, 5)
        .setValue(2)
        .setColorForeground(uIActive)
        .setNumberOfTickMarks(5);
    layer1CP = cp5.addColorWheel("layer1ColorPicker")
        .setPosition(uiOriginX+360, uiOriginY+20)
        .setRGB(color(255, 255, 0))
        .moveTo("Output")
        .hide();
    layer2CP = cp5.addColorWheel("layer2ColorPicker")
        .setPosition(uiOriginX+360, uiOriginY+20)
        .setRGB(color(255, 0, 255,.8))
        .moveTo("Output")
        .hide();
    layer3CP = cp5.addColorWheel("layer3ColorPicker")
        .setPosition(uiOriginX+360, uiOriginY+20)
        .setRGB(color(0, 255, 255,.8))
        .moveTo("Output")
        .hide();
    layer4CP = cp5.addColorWheel("layer4ColorPicker")
        .setPosition(uiOriginX+360, uiOriginY+20)
        .setRGB(color(0, 0, 0,.8))
        .moveTo("Output")
        .hide();
    cp5.addButton("layer1")
        .setValue(0)
        .setPosition(uiOriginX+300, uiOriginY+30)
        .setSize(50, 20);
    cp5.addButton("layer2")
        .setValue(0)
        .setPosition(uiOriginX+300, uiOriginY+55)
        .setSize(50, 20);
    cp5.addButton("layer3")
        .setValue(0)
        .setPosition(uiOriginX+300, uiOriginY+80)
        .setSize(50, 20);
    cp5.addButton("layer4")
        .setValue(0)
        .setPosition(uiOriginX+300, uiOriginY+105)
        .setSize(50, 20);
    cp5.addButton("randomColors")
        .setValue(0)
        .setPosition(uiOriginX+300, uiOriginY+130)
        .setSize(70, 20);
    cp5.addButton("averageTolerance")
        .setValue(0)
        .setPosition(uiOriginX+10, uiOriginY+210)
        .setSize(100
        , 20);
    cp5.addButton("hideConsole")
        .setValue(0)
        .setPosition(uiOriginX+10, uiOriginY+50)
        .setSize(70, 20);
    unsplashKeywordInput = cp5.addTextfield("unsplashKeyword")
        .setPosition(uiOriginX+10, uiOriginY+30)
        .setSize(100, 20)
        .setFocus(false)
        .setAutoClear(false)
        .setColor(color(255, 0, 0));
    tbInput = cp5.addTextfield("input")
        .setPosition(uiOriginX+210, uiOriginY+30)
        .setSize(100, 20)
        .setFocus(true)
        .setAutoClear(false)
        .setColor(color(255, 0, 0))
        .setText("");
    outputWidthInput = cp5.addTextfield("outputWidth")
        .setPosition(uiOriginX+10, uiOriginY+30)
        .setSize(100, 20)
        .setFocus(false)
        .setAutoClear(false)
        .setColor(color(255, 0, 0))
        .setText("383");
        outputWidthInput.setText("383");
    outputHeightInput = cp5.addTextfield("outputHeight")
        .setPosition(uiOriginX+10, uiOriginY+65)
        .setSize(100, 20)
        .setFocus(false)
        .setAutoClear(false)
        .setColor(color(255, 0, 0))
        .setText("575");
    cp5.addButton("saveSVG")
        .setValue(1)
        .setPosition(uiOriginX+190, uiOriginY+30)
        .setSize(50, 20);
    cp5.addButton("savePNG")
        .setValue(1)
        .setPosition(uiOriginX+190, uiOriginY+65)
        .setSize(50, 20);
    println("Loading Image...");
    cp5.addButton("newImage")
        .setValue(0)
        .setPosition(uiOriginX+120, uiOriginY+30)
        .setSize(50, 20);
    cp5.addButton("fitImage")
        .setValue(0)
        .setPosition(uiOriginX+180, uiOriginY+30)
        .setSize(50, 20);
    cp5.addButton("updateBufferSize")
        .setValue(0)
        .setPosition(uiOriginX+10, uiOriginY+100)
        .setSize(80, 20);
    sizePresetList = cp5.addScrollableList("sizePreset")
        .setPosition(uiOriginX+100, uiOriginY+100)
        .setSize(100, 100)
        .setBarHeight(20)
        .setItemHeight(20)
        .setType(ScrollableList.DROPDOWN);
        sizePresetList.close();
        sizePresetList.addItem("Postcard",0);
        sizePresetList.addItem("a4",1);
        sizePresetList.addItem("a3",2);
        sizePresetList.addItem("Tabloid",3);
        sizePresetList.addItem("Letter",4);
        sizePresetList.addItem("Instagram",5);
    viewportPresetList = cp5.addScrollableList("viewportPreset")
        .setPosition(uiOriginX+100, uiOriginY+100)
        .setSize(100, 100)
        .setBarHeight(20)
        .setItemHeight(20)
        .setType(ScrollableList.DROPDOWN);
        viewportPresetList.close();
        viewportPresetList.addItem("Split View",0);
        viewportPresetList.addItem("Output View",1);
        viewportPresetList.addItem("Image View",2);
    fontSelectionList = cp5.addScrollableList("fontSelection")
        .setPosition(uiOriginX+210, uiOriginY+70)
        .setSize(100, 100)
        .setBarHeight(20)
        .setItemHeight(20)
        .setType(ScrollableList.DROPDOWN);
        fontSelectionList.close();
        fontSelectionList.addItem("Basteleur",0);
        fontSelectionList.addItem("Format 1452",1);
        fontSelectionList.addItem("Hngl",2);
        fontSelectionList.addItem("IBM Plex Mono",3);
        fontSelectionList.addItem("Karrik",4);


    // group controllers into tabs
    cp5.getController("viewportScaler").moveTo("Viewport");
    cp5.getController("viewportPreset").moveTo("Viewport");
    cp5.getController("hideConsole").moveTo("Viewport");


    cp5.getController("unsplashKeyword").moveTo("default");
    cp5.getController("newImage").moveTo("default");
    cp5.getController("imageXPos").moveTo("default");
    cp5.getController("imageYPos").moveTo("default");
    cp5.getController("imageYPos").moveTo("default");
    cp5.getController("exposureDown").moveTo("default");
    cp5.getController("exposureUp").moveTo("default");


    cp5.getController("input").moveTo("Text");
    cp5.getController("textXPos").moveTo("Text");
    cp5.getController("textYPos").moveTo("Text");
    cp5.getController("textRotation").moveTo("Text");
    cp5.getController("tSize").moveTo("Text");
    cp5.getController("leading").moveTo("Text");
    cp5.getController("fontSelection").moveTo("Text");
    cp5.getController("textBoxWidthOffset").moveTo("Text");

    cp5.getController("yellowTolerance").moveTo("Output");
    cp5.getController("magentaTolerance").moveTo("Output");
    cp5.getController("cyanTolerance").moveTo("Output");
    cp5.getController("blackTolerance").moveTo("Output");
    cp5.getController("toleranceRange").moveTo("Output");
    cp5.getController("lineSpacing").moveTo("Output");
    cp5.getController("layer1").moveTo("Output");
    cp5.getController("layer2").moveTo("Output");
    cp5.getController("layer3").moveTo("Output");
    cp5.getController("layer4").moveTo("Output");
    cp5.getController("randomColors").moveTo("Output");
    cp5.getController("margin").moveTo("Output");
    cp5.getController("averageTolerance").moveTo("Output");


    cp5.getController("saveSVG").moveTo("Export");
    cp5.getController("savePNG").moveTo("Export");
    cp5.getController("outputWidth").moveTo("Export");
    cp5.getController("outputHeight").moveTo("Export");
    cp5.getController("updateBufferSize").moveTo("Export");
    cp5.getController("sizePreset").moveTo("Export");

    // Initial noiseseed settings, Get image for frame 1 on startup
    // getImage((cp5.get(Textfield.class, "unsplashKeyword").getText()));
    int randNoiseSeed = int(random(5000));
    noiseSeed(randNoiseSeed);

    // NoiseField setup
    nfCyan = new NoiseField(fi,ib,tb,cp5.getController("cyanTolerance").getArrayValue(0),cp5.getController("cyanTolerance").getArrayValue(1),.01,cp5.get(ColorWheel.class, "layer3ColorPicker").getRGB(),randNoiseSeed,margin,lineSpacing,displacmentFactor);
    nfMagenta = new NoiseField(fi,ib,tb,cp5.getController("magentaTolerance").getArrayValue(0),cp5.getController("magentaTolerance").getArrayValue(1),.01,cp5.get(ColorWheel.class, "layer2ColorPicker").getRGB(),randNoiseSeed,margin,lineSpacing,displacmentFactor);
    nfYellow = new NoiseField(fi,ib,tb,cp5.getController("yellowTolerance").getArrayValue(0),cp5.getController("yellowTolerance").getArrayValue(1),.01,cp5.get(ColorWheel.class, "layer1ColorPicker").getRGB(),randNoiseSeed,margin,lineSpacing,displacmentFactor);
    nfBlack = new NoiseField(fi,ib,tb,cp5.getController("blackTolerance").getArrayValue(0),cp5.getController("blackTolerance").getArrayValue(1),.01,cp5.get(ColorWheel.class, "layer4ColorPicker").getRGB(),randNoiseSeed,margin,lineSpacing,displacmentFactor);
    

    
}

void draw() {
    // frame 1, image layer
    background(20);
    ib.beginDraw();
    ib.push();
    ib.translate(ib.width / 2, ib.height / 2);
    ib.scale(imageScale, imageScale);
    ib.imageMode(CENTER);
    ib.background(12);
    imageForBuffer = Brightness.apply(imageForBuffer, int(exposure)); 
    ib.image(imageForBuffer, imageXPos, imageYPos);
    ib.pop();
    ib.endDraw();

    // Text, text layer (maybe also inmage layer if i get around to it)
    tb.beginDraw();
    tb.background(255);
    tb.push();
    tb.translate(tb.width / 2 + textXPos, tb.height / 2 + textYPos);
    tb.rotate(radians(textRotation));
    tb.textAlign(CENTER,CENTER);
    tb.rectMode(CENTER);
    // tb.fill(0);
    // tb.rect(0, 0, width, tSize + leading);
    tb.textFont(font, tSize);
    tb.textLeading(tSize + leading);
    // tb.fill(255);
    tb.fill(0);
    tb.text(cp5.get(Textfield.class, "input").getText(), 0, 0, tb.width-textBoxWidthOffset, tb.height);
    tb.pop();
    tb.endDraw();

    // frame 3, combined and drawn with lines
    if (record) {
        startRecord();
    }
    fi.beginDraw();
    fi.background(255);
        if(frameCount<2){
        averageTolerance();
        }
    nfYellow.loadPixelsForBuffers();
    nfYellow.update(fi,ib,tb,cp5.getController("yellowTolerance").getArrayValue(0),cp5.getController("yellowTolerance").getArrayValue(1),.01,cp5.get(ColorWheel.class, "layer1ColorPicker").getRGB(),randNoiseSeed,margin,lineSpacing,displacmentFactor);
    nfYellow.drawGreenLayer();
    
    nfMagenta.loadPixelsForBuffers();
    nfMagenta.update(fi,ib,tb,cp5.getController("magentaTolerance").getArrayValue(0),cp5.getController("magentaTolerance").getArrayValue(1),.01,cp5.get(ColorWheel.class, "layer2ColorPicker").getRGB(),randNoiseSeed,margin,lineSpacing,displacmentFactor);
    nfMagenta.drawRedLayer();
    
    nfCyan.loadPixelsForBuffers();
    nfCyan.update(fi,ib,tb,cp5.getController("cyanTolerance").getArrayValue(0),cp5.getController("cyanTolerance").getArrayValue(1),.01,cp5.get(ColorWheel.class, "layer3ColorPicker").getRGB(),randNoiseSeed,margin,lineSpacing,displacmentFactor);
    nfCyan.drawBlueLayer();
    
    nfBlack.loadPixelsForBuffers();
    nfBlack.update(fi,ib,tb,cp5.getController("blackTolerance").getArrayValue(0),cp5.getController("blackTolerance").getArrayValue(1),.01,cp5.get(ColorWheel.class, "layer4ColorPicker").getRGB(),randNoiseSeed,margin,lineSpacing,displacmentFactor);
    nfBlack.drawBlackLayer();
    
    // BROKEN
    // fi=addLabel(fi);

    fi.endDraw();
    if (record) {
        closeRecord();
    }
    // draw all three buffers to the screen (edit this to get split view or single image view)
    showBuffers();
    // draw console to screen
    // (x, y, width, height, preferredTextSize, minTextSize, linespace, padding, strokeColor, backgroundColor, textColor)
    if (showConsoleOn) {
    console.draw(0, height - 120, width, height, 12, 5, 4, 4, color(220,0), color(10,50), color(255, 255, 255,100));
    }
  
    // Print the console to the system out.
    console.print();
}

void showBuffers() {
    if (splitView) {
        push();
        imageMode(CENTER);
        image(ib, width / 4, height / 2, ib.width * viewportScaler, ib.height * viewportScaler);
        image(tb, width / 2, height / 2, tb.width * viewportScaler, tb.height * viewportScaler);
        image(fi, width - width / 4, height / 2, fi.width * viewportScaler, fi.height * viewportScaler);
        pop();
    }else if (imageView) {
        push();
        imageMode(CENTER);
        image(ib, width*.55, height / 2, ib.width * viewportScaler, ib.height * viewportScaler);
        pop();
    }else if (outputView) {
        push();
        imageMode(CENTER);
        image(fi, width*.55, height / 2, fi.width * viewportScaler, fi.height * viewportScaler);
        pop();
    }
}

// a function to make new sliders because I do that alot, thank you dgrantham
public Slider makeSlider(String name, int posX, int posY, float rangeMin, float rangeMax, float value) {
    Slider s;
    s = cp5.addSlider(name)
        .setPosition(posX, posY)
        .setWidth(100)
        .setRange(rangeMin, rangeMax)
        .setValue(value)
        .setColorBackground(uIbackground)
        .setColorForeground(uIForground)
        .setColorActive(uIActive);
    return s;
}

// retrieve image from unsplash, maybe add drag and drop at some point?
void getImage(String k) {
    cp5.getController("imageXPos").setValue(0);
    cp5.getController("imageYPos").setValue(0);
    cp5.getController("imageScale").setValue(1);
        println("Loading Image...");
    // imageForBuffer = loadImage("https://source.unsplash.com/" + imageDimensionWidth + "x" + imageDimensionHeight + "/?" + k, "jpg");
    imageForBuffer = loadImage("https://source.unsplash.com/random/?" + k, "jpg");
    // imageForBuffer = loadImage("Dino.jpg", "jpg");
    println("Image width:" +imageForBuffer.width);
    println("Image height:"+imageForBuffer.height);
        if(imageForBuffer.height > imageForBuffer.width){
        imageForBuffer.resize(ib.width, 0);
        } else if(imageForBuffer.width > imageForBuffer.height){
        imageForBuffer.resize(0, ib.height);    
        } else if(imageForBuffer.width == imageForBuffer.height){
        imageForBuffer.resize(0, ib.height);    
        }
    imageForBuffer.loadPixels();
    println("Done!");
}

// --------------------------------------button events begin
void newImage() {
        getImage((cp5.get(Textfield.class, "unsplashKeyword").getText()));
}

void saveSVG() {
    if (frameCount > 0) {
        println("Exporting SVG...");
        record = true;
    }
}

void savePNG() {
    if (frameCount > 0) {
        println("exporting...");
        fi.save("Output/Image-" + month() + "_" + day() + "_" + year() + "_" + hour() + "_" + minute() + "_" + second() + ".png");
        println("Done!"+"Image-" + month() + "_" + day() + "_" + year() + "_" + hour() + "_" + minute() + "_" + second() + ".png"+" successfully exported!");
    }
}

// color picker on/off buttons
void layer1() {
    if (frameCount > 0) {
        if (!layer1On) {
            cp5.getController("layer1ColorPicker").show();
            cp5.getController("layer2ColorPicker").hide();
            cp5.getController("layer3ColorPicker").hide();
            cp5.getController("layer4ColorPicker").hide();
            layer1On = true;
            layer2On = false;
            layer3On = false;
            layer4On = false;
        } else if (layer1On) {
            cp5.getController("layer1ColorPicker").hide();
            cp5.getController("layer2ColorPicker").hide();
            cp5.getController("layer3ColorPicker").hide();
            cp5.getController("layer4ColorPicker").hide();
            layer1On = false;
            layer2On = false;
            layer3On = false;
            layer4On = false;
        }
    }
}

void layer2() {
    if (frameCount > 0) {
        if (!layer2On) {
            cp5.getController("layer1ColorPicker").hide();
            cp5.getController("layer2ColorPicker").show();
            cp5.getController("layer3ColorPicker").hide();
            cp5.getController("layer4ColorPicker").hide();
            layer1On = false;
            layer2On = true;
            layer3On = false;
            layer4On = false;
        } else if (layer2On) {
            cp5.getController("layer1ColorPicker").hide();
            cp5.getController("layer2ColorPicker").hide();
            cp5.getController("layer3ColorPicker").hide();
            cp5.getController("layer4ColorPicker").hide();
            layer1On = false;
            layer2On = false;
            layer3On = false;
            layer4On = false;
        }
    }
}

void layer3() {
    if (frameCount > 0) {
        if (!layer3On) {
            cp5.getController("layer1ColorPicker").hide();
            cp5.getController("layer2ColorPicker").hide();
            cp5.getController("layer3ColorPicker").show();
            cp5.getController("layer4ColorPicker").hide();
            layer1On = false;
            layer2On = false;
            layer3On = true;
            layer4On = false;
        } else if (layer3On) {
            cp5.getController("layer1ColorPicker").hide();
            cp5.getController("layer2ColorPicker").hide();
            cp5.getController("layer3ColorPicker").hide();
            cp5.getController("layer4ColorPicker").hide();
            layer1On = false;
            layer2On = false;
            layer3On = false;
            layer4On = false;
        }
    }
}

void layer4() {
    if (frameCount > 0) {
        if (!layer4On) {
            cp5.getController("layer1ColorPicker").hide();
            cp5.getController("layer2ColorPicker").hide();
            cp5.getController("layer3ColorPicker").hide();
            cp5.getController("layer4ColorPicker").show();
            layer1On = false;
            layer2On = false;
            layer3On = false;
            layer4On = true;
        } else if (layer4On) {
            cp5.getController("layer1ColorPicker").hide();
            cp5.getController("layer2ColorPicker").hide();
            cp5.getController("layer3ColorPicker").hide();
            cp5.getController("layer4ColorPicker").hide();
            layer1On = false;
            layer2On = false;
            layer3On = false;
            layer4On = false;
        }
    }
}

void averageTolerance(){
    if(frameCount>0){
    println("Finding Average Threshold...");
    ib.loadPixels();
    int r = 0, g = 0, b = 0;
    int r1 = 0, g1 = 0, b1 = 0;
    for (int i=0; i<ib.pixels.length; i++) {
        color c = ib.pixels[i];
        r += c>>16&0xFF;
    }
    r /= ib.pixels.length;

    for (int i=0; i<ib.pixels.length; i++) {
        color c = ib.pixels[i];
        g += c>>8&0xFF;
    }
    g /= ib.pixels.length;

        for (int i=0; i<ib.pixels.length; i++) {
        color c = ib.pixels[i];
        b += c&0xFF;
    }
    b /= ib.pixels.length;

        for (int i=0; i<ib.pixels.length; i++) {
        color c = ib.pixels[i];
        r1 += c>>16&0xFF;
        g1 += c>>8&0xFF;
        b1 += c&0xFF;
    }
    r1 /= ib.pixels.length;
    g1 /= ib.pixels.length;
    b1 /= ib.pixels.length;
    float bla = brightness(color(r1,g1,b1));

    float averageThresholdCyan =  map(b,0,255,-5,5);
    float averageThresholdMagenta =  map(r,0,255,-5,5);
    float averageThresholdYellow =  map(g,0,255,-5,5);
    float averageThresholdBlack =  map(bla,0,255,-5,5);

    cyanToleranceRange.setLowValue(averageThresholdCyan-toleranceRange);
    yellowToleranceRange.setLowValue(averageThresholdYellow-toleranceRange);
    magentaToleranceRange.setLowValue(averageThresholdMagenta-toleranceRange);
    blackToleranceRange.setLowValue(averageThresholdBlack-toleranceRange*.5);

    cyanToleranceRange.setHighValue(averageThresholdCyan+toleranceRange);
    yellowToleranceRange.setHighValue(averageThresholdYellow+toleranceRange);
    magentaToleranceRange.setHighValue(averageThresholdMagenta+toleranceRange);
    blackToleranceRange.setHighValue(averageThresholdBlack+toleranceRange*.5);
    println("Done!");
    }
}

void randomColors() {
    if (frameCount > 0) {
        layer1CP.setRGB(color(int(random(255)), int(random(255)), int(random(255))));
        layer2CP.setRGB(color(int(random(255)), int(random(255)), int(random(255))));
        layer3CP.setRGB(color(int(random(255)), int(random(255)), int(random(255))));
        layer4CP.setRGB(color(int(random(255)), int(random(255)), int(random(255))));

    }
}

void updateBufferSize() {
    if (frameCount > 0) {
    bufferDimensions = new PVector(Integer.parseInt(cp5.get(Textfield.class, "outputWidth").getText()), Integer.parseInt(cp5.get(Textfield.class, "outputHeight").getText()));
    ib = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y),JAVA2D);
    tb = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y),JAVA2D);
    fi = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y),JAVA2D);
    fi.smooth(4);

        if(imageForBuffer.height>imageForBuffer.width){
        imageForBuffer.resize(ib.width, 0);
        } else if(imageForBuffer.width>imageForBuffer.height){
        imageForBuffer.resize(0, ib.height);    
        }else if(imageForBuffer.width==imageForBuffer.height){
        imageForBuffer.resize(0, ib.height);    
        }

    imageForBuffer.loadPixels();
    println("Changing Slider Ranges...");
    textXPosSlider.setRange(-tb.width / 2, tb.width / 2);
    textYPosSlider.setRange(-tb.height / 2, tb.height / 2);
    println("Done!");
    }
}

void fitImage(){
    if (frameCount>0) {
        cp5.getController("imageXPos").setValue(0);
        cp5.getController("imageYPos").setValue(0);
        cp5.getController("imageScale").setValue(1);    
    println("Resizing Image...");
        if(imageForBuffer.height>imageForBuffer.width){
        imageForBuffer.resize(ib.width, 0);
        } else if(imageForBuffer.width>imageForBuffer.height){
        imageForBuffer.resize(0, ib.height);    
        }else if(imageForBuffer.width==imageForBuffer.height){
        imageForBuffer.resize(0, ib.height);    
        }
    println("Done!");
    imageForBuffer.loadPixels();
    }
}

// --------------------------------------button events end


// Label for plot export, CURRENTLY BROKEN
PGraphics addLabel(PGraphics element_) {
    element_.pushMatrix();
    element_.stroke(.1);
    element_.translate(element_.width - 10, element_.height);
    element_.rotate(radians(-90));
    hf.text("P_0039_" + frameCount, 50, 0);
    element_.popMatrix();

    element_.pushMatrix();
    element_.stroke(.1);
    hf.text(month() + "/" + day() + "/" + year() + " - " + hour() + ":" + minute() + ":" + second(), 10, element_.height - 10);
    element_.popMatrix();
    return element_;
}

// SVG record actions
void startRecord() {
    if (record) {
        fi = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y), SVG, "Output/Vector-" + month() + "_" + day() + "_" + year() + "_" + hour() + "_" + minute() + "_" + second() + ".svg");
        println("Done!"+"Vector-" + month() + "_" + day() + "_" + year() + "_" + hour() + "_" + minute() + "_" + second() + ".svg"+" successfully exported!");
    }
}

void closeRecord() {
    if (record) {
        fi.dispose();
        fi = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y),JAVA2D);
        fi.smooth(8);
        record = !record;
    }
}

// drag and drop function to allow the user to drop and image in
void dropEvent(DropEvent theDropEvent) {
  println("");
  println("isFile()\t"+theDropEvent.isFile());
  println("isImage()\t"+theDropEvent.isImage());
  println("isURL()\t"+theDropEvent.isURL());
  
  // if the dropped object is an image, then 
  // load the image into our PImage.
    if(theDropEvent.isImage()) {
    println("Loading Image ...");
    imageForBuffer = theDropEvent.loadImage();
    println("Done");
  }
  println("Resizing Image...");
        if(imageForBuffer.height>imageForBuffer.width){
        imageForBuffer.resize(ib.width, 0);
        } else if(imageForBuffer.width>imageForBuffer.height){
        imageForBuffer.resize(0, ib.height);    
        }else if(imageForBuffer.width==imageForBuffer.height){
        imageForBuffer.resize(0, ib.height);    
        }
    println("Done!");
imageForBuffer.loadPixels();
}


void sizePreset(int n){
    if (frameCount>0) {
        println("Updating Buffer Size...");
            if(n== 0){
        cp5.get(Textfield.class, "outputWidth").setText("383");
        cp5.get(Textfield.class, "outputHeight").setText("575");
        viewportScalerSlider.setValue(.90);
        println("Postcard size set");
    }else if (n== 1) {
        cp5.get(Textfield.class, "outputWidth").setText("598");
        cp5.get(Textfield.class, "outputHeight").setText("842");
        viewportScalerSlider.setValue(.57);
        println("A4 size set");
    }else if (n== 2) {
        cp5.get(Textfield.class, "outputWidth").setText("842");
        cp5.get(Textfield.class, "outputHeight").setText("1191");
        viewportScalerSlider.setValue(.39);
        println("A3 size set");
    }else if (n== 3) {
        cp5.get(Textfield.class, "outputWidth").setText("842");
        cp5.get(Textfield.class, "outputHeight").setText("1225");
        viewportScalerSlider.setValue(.39);
        println("Tabloid size set");
    }else if (n== 4) {
        cp5.get(Textfield.class, "outputWidth").setText("612");
        cp5.get(Textfield.class, "outputHeight").setText("842");
        viewportScalerSlider.setValue(.57);
        println("Letter size set");
    }else if (n== 5) {
        cp5.get(Textfield.class, "outputWidth").setText("1080");
        cp5.get(Textfield.class, "outputHeight").setText("1080");
        viewportScalerSlider.setValue(.31);
        println("Instagram size set");
    }
    updateBufferSize();
    }
}

void viewportPreset(int n){
    if(n == 0){
        splitView = true;
        imageView = false;
        outputView = false;
    }else if(n == 1){
        splitView = false;
        imageView = false;
        outputView = true;
    }else if(n == 2){
        splitView = false;
        imageView = true;
        outputView = false;
    }
}

void fontSelection(int n){
    if(n == 0){
    font = createFont("fonts/Basteleur-Bold.ttf", 50);
    }else if(n == 1){
    font = createFont("fonts/Format_1452.otf", 50);
    }else if(n == 2){
    font = createFont("fonts/hngl.otf", 50);
    }else if(n == 3){
    font = createFont("fonts/IBMPlexMono-Bold.ttf", 50);
    }else if(n == 4){
    font = createFont("fonts/Karrik-Regular.ttf", 50);
    }
}

void exposureDown(){
    if(frameCount>0){
        imageForBuffer = Brightness.apply(imageForBuffer, -5); 
    }
}
void exposureUp(){
    if(frameCount>0){
        imageForBuffer = Brightness.apply(imageForBuffer, 5); 
    }
}
void contrastDown(){
    if(frameCount>0){
        imageForBuffer = Contrast.apply(imageForBuffer, -.1); 
    }
}
void contrastUp(){
    if(frameCount>0){
        imageForBuffer = Contrast.apply(imageForBuffer, .1); 
    }
}
void hideConsole(){
    if (frameCount>0 && showConsoleOn) {
        showConsoleOn= false;
        cp5.getController("hideConsole").setLabel("ShowConsole");
    }else if (frameCount>0 && showConsoleOn==false){
        showConsoleOn= true;
        cp5.getController("hideConsole").setLabel("HideConsole");
    }
}

