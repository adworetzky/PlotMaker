class NoiseField { 

    PGraphics outputElement;
    PGraphics imageLayerElement;
    PGraphics textLayerElement;
    float layerLowTolerance;
    float layerHighTolerance;
    float noiseScalar;
    color strokeColor;
    int randNoiseSeed;
    int margin;
    float lineSpacing;
    float displacmentFactor;



  NoiseField (PGraphics outputElement_,PGraphics imageLayerElement_,PGraphics textLayerElement_, float layerLowTolerance_,float layerHighTolerance_, float noiseScalar_, color strokeColor_, int randNoiseSeed_, int margin_, float lineSpacing_,float displacmentFactor_) {  
    outputElement=outputElement_;
    imageLayerElement=imageLayerElement_;
    textLayerElement= textLayerElement_;
    layerLowTolerance=layerLowTolerance_;
    layerHighTolerance=layerHighTolerance_;
    noiseScalar=noiseScalar_;
    strokeColor = strokeColor_;
    randNoiseSeed = randNoiseSeed_;
    margin = margin_;
    lineSpacing = lineSpacing_;
    displacmentFactor = displacmentFactor_;
  } 

void update(PGraphics outputElement_,PGraphics imageLayerElement_,PGraphics textLayerElement_, float layerLowTolerance_,float layerHighTolerance_, float noiseScalar_, color strokeColor_, int randNoiseSeed_, int margin_, float lineSpacing_,float displacmentFactor_){
    outputElement=outputElement_;
    imageLayerElement=imageLayerElement_;
    textLayerElement= textLayerElement_;
    layerLowTolerance=layerLowTolerance_;
    layerHighTolerance=layerHighTolerance_;
    noiseScalar=noiseScalar_;
    strokeColor = strokeColor_;
    randNoiseSeed = randNoiseSeed_;
    margin = margin_;
    lineSpacing = lineSpacing_;
    displacmentFactor = displacmentFactor_;
}

void loadPixelsForBuffers(){
    imageLayerElement.loadPixels();
    textLayerElement.loadPixels();
}

float getAverageBrightness() {
  imageLayerElement.loadPixels();
  int r = 0, g = 0, b = 0;
  for (int i=0; i<imageLayerElement.pixels.length; i++) {
    color c = imageLayerElement.pixels[i];
    r += c>>16&0xFF;
    g += c>>8&0xFF;
    b += c&0xFF;
  }
  r /= imageLayerElement.pixels.length;
  g /= imageLayerElement.pixels.length;
  b /= imageLayerElement.pixels.length;
  return map(brightness(color(r, g, b)),0,255,-5,5);
}

void drawRedLayer() {
    //  outputElement.blendMode(SUBTRACT);
    outputElement.noFill();
    outputElement.push();
    outputElement.strokeWeight(.7);
    noiseSeed(randNoiseSeed);
    noiseDetail(10, .5);
    for (int y = margin; y < outputElement.height - margin; y += lineSpacing) {
        outputElement.stroke(strokeColor);
        outputElement.beginShape();
        for (int x = margin; x < outputElement.width - margin; x += lineSpacing) {
            float noiseVar = map(noise((x) * noiseScalar, (y) * noiseScalar), 0, 1, -displacmentFactor * .5, displacmentFactor * .5);
            int imageLayerIndex = x+int(noiseVar) + ((y+int(noiseVar))*imageLayerElement.width);
            int textLayerIndex = x+int(noiseVar) + ((y+int(noiseVar))*imageLayerElement.width);
            float r = map(red(imageLayerElement.pixels[imageLayerIndex]),0,255,-5,5);
            color c2 = color(red(textLayerElement.pixels[textLayerIndex]),green(textLayerElement.pixels[textLayerIndex]),blue(textLayerElement.pixels[textLayerIndex]));
            float bri = brightness(c2);
            if (r < layerHighTolerance && r > layerLowTolerance && bri > 0 && x + noiseVar < outputElement.width - margin && x + noiseVar > margin && y + noiseVar < outputElement.height - margin && y + noiseVar > margin) {
                outputElement.curveVertex(x + noiseVar, y + noiseVar + r);
            } else {
                outputElement.endShape();
                outputElement.beginShape();
            }
        }
        outputElement.endShape();
    }
     outputElement.pop();
}

void drawBlueLayer() {
    outputElement.blendMode(BLEND);
    outputElement.noFill();
    outputElement.push();
    outputElement.strokeWeight(.7);
    noiseSeed(randNoiseSeed);
    noiseDetail(10, .51);
    for (int y = margin; y < outputElement.height - margin; y += lineSpacing) {
        outputElement.stroke(strokeColor);
        outputElement.beginShape();
        for (int x = margin; x < outputElement.width - margin; x += lineSpacing) {
            float noiseVar = map(noise((x) * noiseScalar, (y) * noiseScalar), 0, 1, -displacmentFactor * .5, displacmentFactor * .5);
            int imageLayerIndex = x+int(noiseVar) + ((y+int(noiseVar))*imageLayerElement.width);
            int textLayerIndex = x+int(noiseVar) + ((y+int(noiseVar))*imageLayerElement.width);
            float b = map(blue(imageLayerElement.pixels[imageLayerIndex]),0,255,-5,5);
            color c2 = color(red(textLayerElement.pixels[textLayerIndex]),green(textLayerElement.pixels[textLayerIndex]),blue(textLayerElement.pixels[textLayerIndex]));
            float bri = brightness(c2);
            if (b < layerHighTolerance && b > layerLowTolerance && bri > 0 && x + noiseVar < outputElement.width - margin && x + noiseVar > margin && y + noiseVar < outputElement.height - margin && y + noiseVar > margin) {
                outputElement.curveVertex(x + noiseVar, y + noiseVar + b);
            } else {
                outputElement.endShape();
                outputElement.beginShape();
            }
        }
        outputElement.endShape();
    }
     outputElement.pop();
}

void drawGreenLayer() {
    // outputElement_.blendMode(BLEND);
    outputElement.noFill();
    outputElement.push();
    outputElement.strokeWeight(.7);
    noiseSeed(randNoiseSeed);
    noiseDetail(10, .52);
    for (int y = margin; y < outputElement.height - margin; y += lineSpacing) {
        outputElement.stroke(strokeColor);
        outputElement.beginShape();
        for (int x = margin; x < outputElement.width - margin; x += lineSpacing) {
            float noiseVar = map(noise((x) * noiseScalar, (y) * noiseScalar), 0, 1, -displacmentFactor * .5, displacmentFactor * .5);
            int imageLayerIndex = x+int(noiseVar) + ((y+int(noiseVar))*imageLayerElement.width);
            int textLayerIndex = x+int(noiseVar) + ((y+int(noiseVar))*imageLayerElement.width);
            float g = map(green(imageLayerElement.pixels[imageLayerIndex]),0,255,-5,5);
            color c2 = color(red(textLayerElement.pixels[textLayerIndex]),green(textLayerElement.pixels[textLayerIndex]),blue(textLayerElement.pixels[textLayerIndex]));
            float bri = brightness(c2);
            if (g < layerHighTolerance && g > layerLowTolerance &&  bri > 0 && x + noiseVar < outputElement.width - margin && x + noiseVar > margin && y + noiseVar < outputElement.height - margin && y + noiseVar > margin) {
                outputElement.curveVertex(x + noiseVar, y + noiseVar + g);
            } else {
                outputElement.endShape();
                outputElement.beginShape();
            }
        }
        outputElement.endShape();
    }
     outputElement.pop();
}

void drawBlackLayer() {
    // outputElement_.blendMode(BLEND);
    outputElement.noFill();
    outputElement.push();
    outputElement.strokeWeight(.7);
    noiseSeed(randNoiseSeed);
    noiseDetail(10, .53);
    for (int y = margin; y < outputElement.height - margin; y += lineSpacing) {
        outputElement.stroke(strokeColor);
        outputElement.beginShape();
        for (int x = margin; x < outputElement.width - margin; x += lineSpacing) {
            float noiseVar = map(noise((x) * noiseScalar, (y) * noiseScalar), 0, 1, -displacmentFactor * .5, displacmentFactor * .5);
            int imageLayerIndex = x+int(noiseVar) + ((y+int(noiseVar))*imageLayerElement.width);
            int textLayerIndex = x+int(noiseVar) + ((y+int(noiseVar))*imageLayerElement.width);
            color bla = color(red(imageLayerElement.pixels[imageLayerIndex]),green(imageLayerElement.pixels[imageLayerIndex]),blue(imageLayerElement.pixels[imageLayerIndex]));
            float blaBrightness = map(brightness(bla),0,255,-5,5);
            color c2 = color(red(textLayerElement.pixels[textLayerIndex]),green(textLayerElement.pixels[textLayerIndex]),blue(textLayerElement.pixels[textLayerIndex]));
            float bri = brightness(c2);
            if (blaBrightness < layerHighTolerance && blaBrightness > layerLowTolerance &&  bri > 0 && x + noiseVar < outputElement.width - margin && x + noiseVar > margin && y + noiseVar < outputElement.height - margin && y + noiseVar > margin) {
                outputElement.curveVertex(x + noiseVar, y + noiseVar + blaBrightness);
            } else {
                outputElement.endShape();
                outputElement.beginShape();
            }
        }
        outputElement.endShape();
    }
     outputElement.pop();
}

}
