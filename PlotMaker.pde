import processing.svg.*;
// import de.ixdhof.hershey.*;
import controlP5.*;
ControlP5 cp5;
//  TODO
// choose pen color-done
// drag and drop img-hmmm... maybe this? http://www.sojamo.de/libraries/drop/#:~:text=sDrop%20is%20a%20processing%20library,forwarded%20to%20the%20processing%20sketch.
// change size of export with presets for different papers

PGraphics ib;
PGraphics tb;
PGraphics fi;

PImage imageForBuffer;
PFont font;

String unsplashKeyword = "";
int imageDimensionWidth = 900;
int imageDimensionHeight = 1600;
PVector bufferDimensions;

int margin = 30;
float displacmentFactor = 20;
float noiseVar;
int randNoiseSeed;

boolean record = false;
boolean layer1On = false;
boolean layer2On = false;
boolean layer3On = false;

Slider viewportScalerSlider, layer1ToleranceSlider, layer2ToleranceSlider, layer3ToleranceSlider, textXPosSlider, textYPosSlider, textRotationSlider, tSizeSlider, leadingSlider, spacingSlider, imageXPosSlider, imageYPosSlider,imageScaleSlider;
float viewportScaler, layer1Tolerance, layer2Tolerance, layer3Tolerance, textXPos, textYPos, textRotation, tSize, leading, lineSpacing, imageXPos, imageYPos,imageScale;

ColorWheel layer1CP;
float layer1ColorPicker;
ColorWheel layer2CP;
float layer2ColorPicker;
ColorWheel layer3CP;
float layer3ColorPicker;

Textfield tbInput;
Textfield unsplashKeywordInput;

void setup() {
    // size(1000, 1000);
    size(1200, 800);
    surface.setResizable(true);

    // size(753,1188);
    font = createFont("IBMPlexMono-Bold.ttf", 50);
    // smooth();

    // set up graphics buffers
    bufferDimensions = new PVector(383, 575);
    ib = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y));
    tb = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y));
    fi = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y));
    fi.smooth();

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
    cp5.addTab("Size")
        .setColorBackground(color(0, 160, 100))
        .setColorLabel(color(255))
        .setColorActive(color(255, 128, 0));
    cp5.getTab("default")
        .setColorBackground(color(0, 160, 100))
        .setColorLabel(color(255))
        .setColorActive(color(255, 128, 0))
        .setLabel("Frame 1");

    // create UI elements
    viewportScalerSlider = makeSlider("viewportScaler", 10, 30, 0, 2, .75);
    imageXPosSlider = makeSlider("imageXPos", 10, 75, -ib.width / 2, ib.width / 2, 0);
    imageYPosSlider = makeSlider("imageYPos", 10, 90, -ib.height / 2, ib.height / 2, 0);
    imageScaleSlider = makeSlider("imageScale", 10, 105, 0, 2, 1);
    layer1ToleranceSlider = makeSlider("layer1Tolerance", 10, 30, -5, 5, 0);
    layer2ToleranceSlider = makeSlider("layer2Tolerance", 10, 45, -5, 5, 0);
    layer3ToleranceSlider = makeSlider("layer3Tolerance", 10, 60, -5, 5, 0);
    tSizeSlider = makeSlider("tSize", 10, 75, 0, 140, 70);
    textXPosSlider = makeSlider("textXPos", 10, 30, -tb.width / 2, tb.width / 2, 0);
    textYPosSlider = makeSlider("textYPos", 10, 45, -tb.height / 2, tb.height / 2, 0-tSize/2);
    textRotationSlider = makeSlider("textRotation", 10, 60, -TWO_PI, TWO_PI, 0);
    leadingSlider = makeSlider("leading", 10, 90, -100, 100, 0);
    spacingSlider = cp5.addSlider("lineSpacing")
        .setPosition(10, 75)
        .setWidth(100)
        .setRange(1, 5)
        .setValue(2)
        .setNumberOfTickMarks(5);
    layer1CP = cp5.addColorWheel("layer1ColorPicker")
        .setPosition(250, 20)
        .setRGB(color(0, 0, 0))
        .moveTo("Output")
        .hide();
    layer2CP = cp5.addColorWheel("layer2ColorPicker")
        .setPosition(250, 20)
        .setRGB(color(255, 0, 0))
        .moveTo("Output")
        .hide();
    layer3CP = cp5.addColorWheel("layer3ColorPicker")
        .setPosition(250, 20)
        .setRGB(color(0, 0, 255))
        .moveTo("Output")
        .hide();
    cp5.addButton("layer1")
        .setValue(0)
        .setPosition(190, 55)
        .setSize(50, 20);
    cp5.addButton("layer2")
        .setValue(0)
        .setPosition(190, 80)
        .setSize(50, 20);
    cp5.addButton("layer3")
        .setValue(0)
        .setPosition(190, 105)
        .setSize(50, 20);
    cp5.addButton("randomColors")
        .setValue(0)
        .setPosition(190, 130)
        .setSize(70, 20);
    unsplashKeywordInput = cp5.addTextfield("unsplashKeyword")
        .setPosition(10, 30)
        .setSize(100, 20)
        .setFocus(false)
        .setColor(color(255, 0, 0));
    tbInput = cp5.addTextfield("input")
        .setPosition(200, 30)
        .setSize(100, 20)
        .setFocus(true)
        .setColor(color(255, 0, 0))
        .setText("CC");
    cp5.addButton("saveImage")
        .setValue(1)
        .setPosition(190, 30)
        .setSize(50, 20);
    println("Loading Image...");
    cp5.addButton("newImage")
        .setValue(0)
        .setPosition(120, 30)
        .setSize(50, 20);


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

    cp5.getController("saveImage").moveTo("Output");
    cp5.getController("layer1Tolerance").moveTo("Output");
    cp5.getController("layer2Tolerance").moveTo("Output");
    cp5.getController("layer3Tolerance").moveTo("Output");
    cp5.getController("lineSpacing").moveTo("Output");
    cp5.getController("layer1").moveTo("Output");
    cp5.getController("layer2").moveTo("Output");
    cp5.getController("layer3").moveTo("Output");
    cp5.getController("randomColors").moveTo("Output");


    getImage((cp5.get(Textfield.class, "unsplashKeyword").getText()));
    int randNoiseSeed = int(random(5000));
    noiseSeed(randNoiseSeed);

}

void draw() {
    // frame one, image layer
    background(0);
    ib.beginDraw();
    ib.push();
    ib.translate(ib.width/2,ib.height/2);
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
    // tb.text("AD2", tb.width/2,tb.height/2);
    tb.pop();
    tb.endDraw();
    tb.loadPixels();

    // frame 3, combined and drawn with lines
    if (record) {
        startRecord();
    }
    fi.beginDraw();
    fi.background(255);
    drawLines(fi, layer1Tolerance, layer2Tolerance, layer3Tolerance, .007);
    fi.endDraw();
    if (record) {
        closeRecord();
    }
    // draw all three buffers to the screen (edit this to get split view or single image view)
    showBuffers();

}

void showBuffers() {
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
void getImage(String k) {
      if (frameCount > 0) 
    println("Loading Image...");
    imageForBuffer = loadImage("https://source.unsplash.com/" + imageDimensionWidth + "x" + imageDimensionHeight + "/?" + k, "jpg");
    // imageForBuffer = loadImage("Dino.jpg", "jpg");
    imageForBuffer.resize(ib.width, 0);
    imageForBuffer.loadPixels();
    println("Done!");  

}

// --------------------------------------button events begin
void newImage() {
      if (frameCount > 0) {
    getImage((cp5.get(Textfield.class, "unsplashKeyword").getText()));
  }
}

void saveImage() {
      if (frameCount > 0) {
    record = true;
  }
}

void layer1() {
      if (frameCount > 0) {
    if (!layer1On) {
        cp5.getController("layer1ColorPicker").show();
        cp5.getController("layer2ColorPicker").hide();
        cp5.getController("layer3ColorPicker").hide();
        layer1On = true;
        layer2On = false;
        layer3On = false;
    } else if (layer1On) {
        cp5.getController("layer1ColorPicker").hide();
        cp5.getController("layer2ColorPicker").hide();
        cp5.getController("layer3ColorPicker").hide();
        layer1On = false;
        layer2On = false;
        layer3On = false;
    }  }

}
void layer2() {
      if (frameCount > 0) {
    if (!layer2On) {
        cp5.getController("layer1ColorPicker").hide();
        cp5.getController("layer2ColorPicker").show();
        cp5.getController("layer3ColorPicker").hide();
        layer2On = true;
        layer3On = false;
        layer1On = false;
    } else if (layer2On) {
        cp5.getController("layer1ColorPicker").hide();
        cp5.getController("layer2ColorPicker").hide();
        cp5.getController("layer3ColorPicker").hide();
        layer1On = false;
        layer2On = false;
        layer3On = false;
    }  }

}
void layer3() {
      if (frameCount > 0) {
    if (!layer3On) {
        cp5.getController("layer1ColorPicker").hide();
        cp5.getController("layer2ColorPicker").hide();
        cp5.getController("layer3ColorPicker").show();
        layer3On = true;
        layer1On = false;
        layer2On = false;
    } else if (layer3On) {
        cp5.getController("layer1ColorPicker").hide();
        cp5.getController("layer2ColorPicker").hide();
        cp5.getController("layer3ColorPicker").hide();
        layer1On = false;
        layer2On = false;
        layer3On = false;
    }  
    }
}

void randomColors() {
      if (frameCount > 0) {
              layer1CP.setRGB(color(int(random(255)), int(random(255)), int(random(255))));
              layer2CP.setRGB(color(int(random(255)), int(random(255)), int(random(255))));
              layer3CP.setRGB(color(int(random(255)), int(random(255)), int(random(255))));

    }
}
// --------------------------------------button events end

// the meat and potatoes of the line drawing in frame 3, TODO: still uses get() and is slow, maybe change to pixel array index
void drawLines(PGraphics element_, float layer1Tolerance_, float layer2Tolerance_, float layer3Tolerance_, float noiseScalar_) {
    fi.blendMode(BLEND);
    element_.noFill();
    element_.push();
    element_.strokeWeight(.5);

    // layer 1
    noiseSeed(randNoiseSeed);

    for (int y = margin; y < element_.height - margin; y += lineSpacing) {
        element_.stroke(cp5.get(ColorWheel.class, "layer1ColorPicker").getRGB());
        element_.beginShape();
        for (int x = margin; x < element_.width - margin; x += lineSpacing) {
            noiseVar = map(noise((x) * noiseScalar_, (y) * noiseScalar_), 0, 1, -displacmentFactor * .5, displacmentFactor * .5);
            color c = ib.get(int(x + noiseVar), int(y + noiseVar));
            float r = map(red(c), 0, 255, -5, 5);
            color c2 = tb.get(int(x + noiseVar), int(y + noiseVar));
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
    noiseSeed(randNoiseSeed + 10);
    element_.strokeWeight(.5);
    for (int y = margin; y < element_.height - margin; y += lineSpacing) {
        element_.stroke(cp5.get(ColorWheel.class, "layer2ColorPicker").getRGB());
        element_.beginShape();
        for (int x = margin; x < element_.width - margin; x += lineSpacing) {
            noiseVar = map(noise((x) * noiseScalar_, (y) * noiseScalar_), 0, 1, -displacmentFactor * .5, displacmentFactor * .5);
            color c = ib.get(int(x + noiseVar), int(y + noiseVar));
            float b = map(blue(c), 0, 255, -5, 5);
            color c2 = tb.get(int(x + noiseVar), int(y + noiseVar));
            float bri = brightness(c2);
            if (b < layer2Tolerance_ * 1.25 && bri > 0 && x + noiseVar < element_.width - margin && x + noiseVar > margin && y + noiseVar < element_.height - margin && y + noiseVar > margin) {
                element_.curveVertex(x + noiseVar, y + noiseVar + b);
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
    noiseSeed(randNoiseSeed + 20);
    element_.strokeWeight(.5);
    for (int y = margin; y < element_.height - margin; y += lineSpacing) {
        element_.stroke(cp5.get(ColorWheel.class, "layer3ColorPicker").getRGB());
        element_.beginShape();
        for (int x = margin; x < element_.width - margin; x += lineSpacing) {
            noiseVar = map(noise((x) * noiseScalar_, (y) * noiseScalar_), 0, 1, -displacmentFactor * .5, displacmentFactor * .5);
            color c = ib.get(int(x + noiseVar), int(y + noiseVar));
            float g = map(green(c), 0, 255, -5, 5);
            color c2 = tb.get(int(x + noiseVar), int(y + noiseVar));
            float bri = brightness(c2);
            if (g < layer3Tolerance_ * 1.5 && bri > 0 && x + noiseVar < element_.width - margin && x + noiseVar > margin && y + noiseVar < element_.height - margin && y + noiseVar > margin) {
                element_.curveVertex(x + noiseVar, y + noiseVar + g);
            } else {
                element_.endShape();
                element_.beginShape();
            }
        }
        element_.endShape();
    }
    element_.pop();
}

void keyPressed() {
    if (key == 'q') {
        closeRecord();
        fi.dispose();
        exit();
    }
}

// SVG record actions
void startRecord() {
    if (record) {
        fi = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y), SVG, "Output-" + month() + "_" + day() + "_" + year() + "_" + hour() + "_" + minute() + "_" + second() + "-####.svg");
    }
}

void closeRecord() {
    if (record) {
        fi.dispose();
        fi = createGraphics(int(bufferDimensions.x), int(bufferDimensions.y));
        fi.smooth();
        record = !record;
    }
}
