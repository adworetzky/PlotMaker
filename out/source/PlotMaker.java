import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.svg.*; 
import de.ixdhof.hershey.*; 
import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class PlotMaker extends PApplet {

// PlotMaker mk.II By Adam Dworetzky
// A program to help make line draw adaptations of images and text with added noise for variation
// Includes color options, export sizing, different font choices, and some other things!
// Use, add to, break, and fix however you would like. The only thing I ask is that you make cool stuff




ControlP5 cp5;

//  TODO
// change layer color-DONE
// drag and drop img-hmmm... maybe this? 
// http://www.sojamo.de/libraries/drop/#:~:text=sDrop%20is%20a%20processing%20library,forwarded%20to%20the%20processing%20sketch.
// change size of export(done) with presets for different papers(not done)
// Font Selection (have to figure out drop down menus in cp5)
// Dual Images, like double exposure (stretch but cool)

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

Slider viewportScalerSlider, yellowLayerToleranceSlider, magentaLayerToleranceSlider, cyanLayerToleranceSlider,blackLayerToleranceSlider, textXPosSlider, textYPosSlider, textRotationSlider, tSizeSlider, leadingSlider, spacingSlider, imageXPosSlider, imageYPosSlider, imageScaleSlider, marginSlider;
float viewportScaler, yellowLayerTolerance, magentaLayerTolerance, cyanLayerTolerance,blackLayerTolerance, textXPos, textYPos, textRotation, tSize, leading, lineSpacing, imageXPos, imageYPos, imageScale;

ColorWheel layer1CP;
float layer1ColorPicker;
ColorWheel layer2CP;
float layer2ColorPicker;
ColorWheel layer3CP;
float layer3ColorPicker;
ColorWheel layer4CP;
float layer4ColorPicker;

Textfield tbInput;
Textfield unsplashKeywordInput;
Textfield outputHeightInput;
Textfield outputWidthInput;

public void setup() {
    // size(1000, 1000);
    
    surface.setResizable(true);

    // size(753,1188);
    // font = createFont("fonts/IBMPlexMono-Bold.ttf", 50);
    // font = createFont("fonts/hngl.otf", 50);
    font = createFont("fonts/Basteleur-Bold.ttf", 50);
    // font = createFont("fonts/Karrik-Regular.ttf", 50);
    // font = createFont("fonts/Format_1452.otf", 50);
    

    // set up graphics buffers
    bufferDimensions = new PVector(383, 575);
    ib = createGraphics(PApplet.parseInt(bufferDimensions.x), PApplet.parseInt(bufferDimensions.y));
    tb = createGraphics(PApplet.parseInt(bufferDimensions.x), PApplet.parseInt(bufferDimensions.y));
    fi = createGraphics(PApplet.parseInt(bufferDimensions.x), PApplet.parseInt(bufferDimensions.y));
    fi.smooth();

    // Hershey Font label set up
    hf = new HersheyFont(this, "futural.jhf");
    hf.textSize(5);

    // set up UI
    cp5 = new ControlP5(this);

    // create tabs
    cp5.addTab("Frame 2")
        .setColorBackground(color(0, 160, 100))
        .setColorLabel(color(255))
        .setColorActive(color(255, 128, 0));
    cp5.addTab("Output")
        .setColorBackground(color(0, 160, 100))
        .setColorLabel(color(255))
        .setColorActive(color(255, 128, 0));
    cp5.addTab("Viewport")
        .setColorBackground(color(0, 160, 100))
        .setColorLabel(color(255))
        .setColorActive(color(255, 128, 0));
    cp5.addTab("Export")
        .setColorBackground(color(0, 160, 100))
        .setColorLabel(color(255))
        .setColorActive(color(255, 128, 0));
    cp5.getTab("default")
        .setColorBackground(color(0, 160, 100))
        .setColorLabel(color(255))
        .setColorActive(color(255, 128, 0))
        .setLabel("Frame 1");

    // create UI elements
    viewportScalerSlider = makeSlider("viewportScaler", 10, 30, 0, 2, .75f);
    imageXPosSlider = makeSlider("imageXPos", 10, 75, -ib.width / 2, ib.width / 2, 0);
    imageYPosSlider = makeSlider("imageYPos", 10, 90, -ib.height / 2, ib.height / 2, 0);
    imageScaleSlider = makeSlider("imageScale", 10, 105, 0, 2, 1);
    yellowLayerToleranceSlider = makeSlider("yellowLayerTolerance", 10, 30, -5, 5, 0);
    magentaLayerToleranceSlider = makeSlider("magentaLayerTolerance", 10, 45, -5, 5, 0);
    cyanLayerToleranceSlider = makeSlider("cyanLayerTolerance", 10, 60, -5, 5, 0);
    blackLayerToleranceSlider = makeSlider("blackLayerTolerance", 10, 75, -5, 5, 0);
    tSizeSlider = makeSlider("tSize", 10, 75, 0, 500, 70);
    textXPosSlider = makeSlider("textXPos", 10, 30, -tb.width / 2, tb.width / 2, 0);
    textYPosSlider = makeSlider("textYPos", 10, 45, -tb.height / 2, tb.height / 2, 0 - tSize / 2);
    textRotationSlider = makeSlider("textRotation", 10, 60, -TWO_PI, TWO_PI, 0);
    leadingSlider = makeSlider("leading", 10, 90, -100, 100, 0);
    marginSlider = makeSlider("margin", 10, 105, -20, 100, 30);
    spacingSlider = cp5.addSlider("lineSpacing")
        .setPosition(10, 90)
        .setWidth(100)
        .setRange(1, 5)
        .setValue(2)
        .setNumberOfTickMarks(5);
    layer1CP = cp5.addColorWheel("layer1ColorPicker")
        .setPosition(290, 20)
        .setRGB(color(255, 255, 0))
        .moveTo("Output")
        .hide();
    layer2CP = cp5.addColorWheel("layer2ColorPicker")
        .setPosition(290, 20)
        .setRGB(color(255, 0, 255))
        .moveTo("Output")
        .hide();
    layer3CP = cp5.addColorWheel("layer3ColorPicker")
        .setPosition(290, 20)
        .setRGB(color(0, 255, 255))
        .moveTo("Output")
        .hide();
    layer4CP = cp5.addColorWheel("layer4ColorPicker")
        .setPosition(290, 20)
        .setRGB(color(0, 0, 0))
        .moveTo("Output")
        .hide();
    cp5.addButton("layer1")
        .setValue(0)
        .setPosition(240, 30)
        .setSize(50, 20);
    cp5.addButton("layer2")
        .setValue(0)
        .setPosition(240, 55)
        .setSize(50, 20);
    cp5.addButton("layer3")
        .setValue(0)
        .setPosition(240, 80)
        .setSize(50, 20);
    cp5.addButton("layer4")
        .setValue(0)
        .setPosition(240, 105)
        .setSize(50, 20);
    cp5.addButton("randomColors")
        .setValue(0)
        .setPosition(240, 130)
        .setSize(70, 20);
    unsplashKeywordInput = cp5.addTextfield("unsplashKeyword")
        .setPosition(10, 30)
        .setSize(100, 20)
        .setFocus(false)
        .setAutoClear(false)
        .setColor(color(255, 0, 0));
    tbInput = cp5.addTextfield("input")
        .setPosition(200, 30)
        .setSize(100, 20)
        .setFocus(true)
        .setAutoClear(false)
        .setColor(color(255, 0, 0))
        .setText("test");
    outputWidthInput = cp5.addTextfield("outputWidth")
        .setPosition(10, 30)
        .setSize(100, 20)
        .setFocus(false)
        .setAutoClear(false)
        .setColor(color(255, 0, 0))
        .setText("383");
    outputHeightInput = cp5.addTextfield("outputHeight")
        .setPosition(10, 65)
        .setSize(100, 20)
        .setFocus(false)
        .setAutoClear(false)
        .setColor(color(255, 0, 0))
        .setText("575");
    cp5.addButton("saveImage")
        .setValue(1)
        .setPosition(190, 30)
        .setSize(50, 20);
    println("Loading Image...");
    cp5.addButton("newImage")
        .setValue(0)
        .setPosition(120, 30)
        .setSize(50, 20);
    cp5.addButton("updateBufferSize")
        .setValue(0)
        .setPosition(10, 100)
        .setSize(80, 20);


    // group controllers into tabs
    cp5.getController("viewportScaler").moveTo("Viewport");

    cp5.getController("unsplashKeyword").moveTo("default");
    cp5.getController("newImage").moveTo("default");
    cp5.getController("imageXPos").moveTo("default");
    cp5.getController("imageYPos").moveTo("default");
    cp5.getController("imageYPos").moveTo("default");

    cp5.getController("input").moveTo("Frame 2");
    cp5.getController("textXPos").moveTo("Frame 2");
    cp5.getController("textYPos").moveTo("Frame 2");
    cp5.getController("textRotation").moveTo("Frame 2");
    cp5.getController("tSize").moveTo("Frame 2");
    cp5.getController("leading").moveTo("Frame 2");

    cp5.getController("yellowLayerTolerance").moveTo("Output");
    cp5.getController("magentaLayerTolerance").moveTo("Output");
    cp5.getController("cyanLayerTolerance").moveTo("Output");
    cp5.getController("blackLayerTolerance").moveTo("Output");
    cp5.getController("lineSpacing").moveTo("Output");
    cp5.getController("layer1").moveTo("Output");
    cp5.getController("layer2").moveTo("Output");
    cp5.getController("layer3").moveTo("Output");
    cp5.getController("layer4").moveTo("Output");
    cp5.getController("randomColors").moveTo("Output");
    cp5.getController("margin").moveTo("Output");


    cp5.getController("saveImage").moveTo("Export");
    cp5.getController("outputWidth").moveTo("Export");
    cp5.getController("outputHeight").moveTo("Export");
    cp5.getController("updateBufferSize").moveTo("Export");

    // Initial noiseseed settings, Get image for frame 1 on startup
    getImage((cp5.get(Textfield.class, "unsplashKeyword").getText()));
    int randNoiseSeed = PApplet.parseInt(random(5000));
    noiseSeed(randNoiseSeed);

}

public void draw() {
    // frame one, image layer
    background(0);
    ib.beginDraw();
    ib.push();
    ib.translate(ib.width / 2, ib.height / 2);
    ib.scale(imageScale, imageScale);
    ib.imageMode(CENTER);
    ib.background(20);
    ib.image(imageForBuffer, imageXPos, imageYPos);
    ib.pop();
    ib.endDraw();
    ib.loadPixels();

    // frame 2, text layer (maybe also inmage layer if i get around to it)
    tb.beginDraw();
    tb.background(255);
    tb.push();
    tb.textFont(font, tSize);
    tb.textAlign(CENTER);
    tb.textLeading(tSize + leading);
    tb.fill(0);
    tb.translate(tb.width / 2 + textXPos, tb.height / 2 + textYPos);
    tb.rotate(textRotation);
    tb.text(cp5.get(Textfield.class, "input").getText(), -tb.width / 2, 0, tb.width, tb.height);
    tb.pop();
    tb.endDraw();
    tb.loadPixels();

    // frame 3, combined and drawn with lines
    if (record) {
        startRecord();
    }
    fi.beginDraw();
    fi.background(255);
    drawLines(fi, yellowLayerTolerance, magentaLayerTolerance, cyanLayerTolerance, blackLayerTolerance, .007f);

    // BROKEN
    // addLabel(fi);

    fi.endDraw();
    if (record) {
        closeRecord();
    }
    // draw all three buffers to the screen (edit this to get split view or single image view)
    showBuffers();
}

public void showBuffers() {
    push();
    imageMode(CENTER);
    image(ib, width / 4, height / 2, ib.width * viewportScaler, ib.height * viewportScaler);
    image(tb, width / 2, height / 2, tb.width * viewportScaler, tb.height * viewportScaler);
    image(fi, width - width / 4, height / 2, fi.width * viewportScaler, fi.height * viewportScaler);
    pop();
}

// a function to make new sliders because I do that alot, thank you dgrantham
public Slider makeSlider(String name, int posX, int posY, float rangeMin, float rangeMax, float value) {
    Slider s;
    s = cp5.addSlider(name)
        .setPosition(posX, posY)
        .setWidth(100)
        .setRange(rangeMin, rangeMax)
        .setValue(value);
    return s;
}

// retrieve image from unsplash, maybe add drag and drop at some point?
public void getImage(String k) {
    cp5.getController("imageXPos").setValue(0);
    cp5.getController("imageYPos").setValue(0);
    cp5.getController("imageScale").setValue(1);

    if (frameCount > 0)
        println("Loading Image...");
    // imageForBuffer = loadImage("https://source.unsplash.com/" + imageDimensionWidth + "x" + imageDimensionHeight + "/?" + k, "jpg");
    imageForBuffer = loadImage("https://source.unsplash.com/random/?" + k, "jpg");
    // imageForBuffer = loadImage("Dino.jpg", "jpg");
    if(imageForBuffer.height>imageForBuffer.width){
    imageForBuffer.resize(ib.width, 0);
    } else if(imageForBuffer.width>imageForBuffer.height){
    imageForBuffer.resize(0, ib.height);    
    }
    imageForBuffer.loadPixels();
    println("Done!");
}

// --------------------------------------button events begin
public void newImage() {
    if (frameCount > 0) {
        getImage((cp5.get(Textfield.class, "unsplashKeyword").getText()));
    }
}

public void saveImage() {
    if (frameCount > 0) {
        record = true;
    }
}

public void layer1() {
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

public void layer2() {
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

public void layer3() {
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

public void layer4() {
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

public void randomColors() {
    if (frameCount > 0) {
        layer1CP.setRGB(color(PApplet.parseInt(random(255)), PApplet.parseInt(random(255)), PApplet.parseInt(random(255))));
        layer2CP.setRGB(color(PApplet.parseInt(random(255)), PApplet.parseInt(random(255)), PApplet.parseInt(random(255))));
        layer3CP.setRGB(color(PApplet.parseInt(random(255)), PApplet.parseInt(random(255)), PApplet.parseInt(random(255))));

    }
}

public void updateBufferSize() {
    if (frameCount > 0) {
    bufferDimensions = new PVector(Integer.parseInt(cp5.get(Textfield.class, "outputWidth").getText()), Integer.parseInt(cp5.get(Textfield.class, "outputHeight").getText()));
    ib = createGraphics(PApplet.parseInt(bufferDimensions.x), PApplet.parseInt(bufferDimensions.y));
    tb = createGraphics(PApplet.parseInt(bufferDimensions.x), PApplet.parseInt(bufferDimensions.y));
    fi = createGraphics(PApplet.parseInt(bufferDimensions.x), PApplet.parseInt(bufferDimensions.y));
    fi.smooth();

    imageForBuffer.resize(ib.width, 0);
    imageForBuffer.loadPixels();
    }
}

// --------------------------------------button events end

// the meat and potatoes of the line drawing in frame 3, TODO: still uses get() and is slow, maybe change to pixel array index
public void drawLines(PGraphics element_, float layer1Tolerance_, float layer2Tolerance_, float layer3Tolerance_,float layer4Tolerance_, float noiseScalar_) {
    fi.blendMode(BLEND);
    element_.noFill();

    // layer 1
    element_.push();
    element_.strokeWeight(.5f);
    noiseSeed(randNoiseSeed);
    noiseDetail(10, .4f);
    for (int y = margin; y < element_.height - margin; y += lineSpacing) {
        element_.stroke(cp5.get(ColorWheel.class, "layer1ColorPicker").getRGB());
        element_.beginShape();
        for (int x = margin; x < element_.width - margin; x += lineSpacing) {
            noiseVar = map(noise((x) * noiseScalar_, (y) * noiseScalar_), 0, 1, -displacmentFactor * .5f, displacmentFactor * .5f);
            int c = ib.get(PApplet.parseInt(x + noiseVar), PApplet.parseInt(y + noiseVar));
            float r = map(red(c), 0, 255, -5, 5);
            int c2 = tb.get(PApplet.parseInt(x + noiseVar), PApplet.parseInt(y + noiseVar));
            float bri = brightness(c2);
            if (r < layer1Tolerance_ && bri > 0 && x + noiseVar < element_.width - margin && x + noiseVar > margin && y + noiseVar < element_.height - margin && y + noiseVar > margin) {
                element_.curveVertex(x + noiseVar, y + noiseVar + r);
            } else {
                element_.endShape();
                element_.beginShape();
            }
        }
        element_.endShape();
    }
    element_.pop();


    // layer 2
    element_.push();
    noiseDetail(10, .55f);
    noiseSeed(randNoiseSeed);
    element_.strokeWeight(.5f);
    for (int y = margin; y < element_.height - margin; y += lineSpacing) {
        element_.stroke(cp5.get(ColorWheel.class, "layer2ColorPicker").getRGB());
        element_.beginShape();
        for (int x = margin; x < element_.width - margin; x += lineSpacing) {
            noiseVar = map(noise((x) * noiseScalar_, (y) * noiseScalar_), 0, 1, -displacmentFactor * .55f, displacmentFactor * .55f);
            int c = ib.get(PApplet.parseInt(x + noiseVar), PApplet.parseInt(y + noiseVar));
            float b = map(blue(c), 0, 255, -5, 5);
            int c2 = tb.get(PApplet.parseInt(x + noiseVar), PApplet.parseInt(y + noiseVar));
            float bri = brightness(c2);
            if (b < layer2Tolerance_ && bri > 0 && x + noiseVar < element_.width - margin && x + noiseVar > margin && y + noiseVar < element_.height - margin && y + noiseVar > margin) {
                element_.curveVertex(x + noiseVar, y + noiseVar + b);cp5.getController("imageYPos").setValue(0);
            } else {
                element_.endShape();
                element_.beginShape();
            }
        }
        element_.endShape();
    }
    element_.pop();

    // layer 3
    element_.push();
    noiseDetail(10, .6f);
    noiseSeed(randNoiseSeed);
    element_.strokeWeight(.5f);
    for (int y = margin; y < element_.height - margin; y += lineSpacing) {
        element_.stroke(cp5.get(ColorWheel.class, "layer3ColorPicker").getRGB());
        element_.beginShape();
        for (int x = margin; x < element_.width - margin; x += lineSpacing) {
            noiseVar = map(noise((x) * noiseScalar_, (y) * noiseScalar_), 0, 1, -displacmentFactor * .6f, displacmentFactor * .6f);
            int c = ib.get(PApplet.parseInt(x + noiseVar), PApplet.parseInt(y + noiseVar));
            float g = map(green(c), 0, 255, -5, 5);
            int c2 = tb.get(PApplet.parseInt(x + noiseVar), PApplet.parseInt(y + noiseVar));
            float bri = brightness(c2);
            if (g < layer3Tolerance_ && bri > 0 && x + noiseVar < element_.width - margin && x + noiseVar > margin && y + noiseVar < element_.height - margin && y + noiseVar > margin) {
                element_.curveVertex(x + noiseVar, y + noiseVar + g);
            } else {
                element_.endShape();
                element_.beginShape();
            }
        }
        element_.endShape();
    }

    element_.pop();
        element_.push();
    noiseDetail(10, .6f);
    noiseSeed(randNoiseSeed);
    element_.strokeWeight(.5f);
    for (int y = margin; y < element_.height - margin; y += lineSpacing) {
        element_.stroke(cp5.get(ColorWheel.class, "layer4ColorPicker").getRGB());
        element_.beginShape();
        for (int x = margin; x < element_.width - margin; x += lineSpacing) {
            noiseVar = map(noise((x) * noiseScalar_, (y) * noiseScalar_), 0, 1, -displacmentFactor * .6f, displacmentFactor * .6f);
            int c = ib.get(PApplet.parseInt(x + noiseVar), PApplet.parseInt(y + noiseVar));
            float bl = map(brightness(c), 0, 255, -5, 5);
            int c2 = tb.get(PApplet.parseInt(x + noiseVar), PApplet.parseInt(y + noiseVar));
            float bri = brightness(c2);
            if (bl < layer4Tolerance_ && bri > 0 && x + noiseVar < element_.width - margin && x + noiseVar > margin && y + noiseVar < element_.height - margin && y + noiseVar > margin) {
                element_.curveVertex(x + noiseVar, y + noiseVar + bl);
            } else {
                element_.endShape();
                element_.beginShape();
            }
        }
        element_.endShape();
    }
    element_.pop();
}

// Label for plot export, CURRENTLY BROKEN DON'T KNOW WHY
public void addLabel(PGraphics element_) {
    element_.pushMatrix();
    element_.stroke(.1f);
    element_.translate(element_.width - 10, element_.height);
    element_.rotate(radians(-90));
    hf.text("P_0039_" + frameCount, 50, 0);
    element_.popMatrix();

    element_.pushMatrix();
    element_.stroke(.1f);
    hf.text(month() + "/" + day() + "/" + year() + " - " + hour() + ":" + minute() + ":" + second(), 10, element_.height - 10);
    element_.popMatrix();

    shape(hf.getShape("PROCESSING"));
}

public void keyPressed() {
    if (key == 'q') {
        closeRecord();
        fi.dispose();
        exit();
    }
}

// SVG record actions
public void startRecord() {
    if (record) {
        fi = createGraphics(PApplet.parseInt(bufferDimensions.x), PApplet.parseInt(bufferDimensions.y), SVG, "Output-" + month() + "_" + day() + "_" + year() + "_" + hour() + "_" + minute() + "_" + second() + "-####.svg");
    }
}

public void closeRecord() {
    if (record) {
        fi.dispose();
        fi = createGraphics(PApplet.parseInt(bufferDimensions.x), PApplet.parseInt(bufferDimensions.y));
        fi.smooth();
        record = !record;
    }
}
  public void settings() {  size(1200, 800);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PlotMaker" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
