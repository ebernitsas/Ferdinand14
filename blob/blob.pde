/*  Copyright (C) 2014  Adam Green (https://github.com/adamgreen)

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
*/
import processing.video.*;

final int       videoWidth = 640;
final int       videoHeight = 360;
final int       highlightDelay = 2000; // milliseconds       

int             g_fontHeight;
int             g_fontWidth;
BlobConstraints g_constraints;
Capture         g_video;
PImage          g_snapshot;
PImage          g_savedImage;
PFont           g_font;
int             g_highlightStartTime;
Button          g_hueMinus;
Button          g_huePlus;
Button          g_saturationMinus;
Button          g_saturationPlus;
Button          g_brightnessMinus;
Button          g_brightnessPlus;
Button          g_thresholdMinus;
Button          g_thresholdPlus;
BlobDetector    g_detector;
FloodFill       g_floodFill;
float           g_fillThreshold = 5.0f;

void setup() 
{
  g_font = loadFont("Monaco-14.vlw");
  textFont(g_font);
  g_fontHeight = int(textAscent() + textDescent() + 0.5f);
  g_fontWidth = int(textWidth(' ') + 0.5f);
  
  size(videoWidth * 2, videoHeight + 5 * g_fontHeight);

  String cameraName = null;
  try
  {
    ConfigFile configFile = new ConfigFile(System.getenv("USER") + ".config");
    if (configFile != null)
    {
      cameraName = configFile.getString("blob.camera");
      IntVector hsb = configFile.getIntVector("blob.hsb");
      IntVector thresholds = configFile.getIntVector("blob.thresholds");
      g_constraints = new BlobConstraints(hsb.x, hsb.y, hsb.z, thresholds.x, thresholds.y, thresholds.z);
    }
  }
  catch (Exception e)
  {
    cameraName = null;
    g_constraints = new BlobConstraints(0, 0, 0, 0, 0, 0);
  }
  
  if (cameraName == null)
  {
    String[] cameras = Capture.list();
    if (cameras.length == 0)
    {
      println("There are no cameras available for capture.");
    } else 
    {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) 
      {
        println(cameras[i]);
      }
    }
    exit();
    return;
  }

  g_video = new Capture(this, cameraName);
  if (g_video == null)
    println("Failed to create video object.");
  g_video.start();
  
  g_snapshot = createImage(videoWidth, videoHeight, RGB);
  g_snapshot.loadPixels();
  
  g_hueMinus = new Button(20 + g_fontWidth * 8, videoHeight + int(g_fontHeight * 0.5), g_fontWidth, g_fontHeight, color(204), color(255), color(0));
  g_huePlus = new Button(20 + g_fontWidth * 14, videoHeight + int(g_fontHeight * 0.5), g_fontWidth, g_fontHeight, color(204), color(255), color(0));
  g_saturationMinus = new Button(20 + g_fontWidth * 8, videoHeight + int(g_fontHeight * 0.5) + g_fontHeight, g_fontWidth, g_fontHeight, color(204), color(255), color(0));
  g_saturationPlus = new Button(20 + g_fontWidth * 14, videoHeight + int(g_fontHeight * 0.5) + g_fontHeight, g_fontWidth, g_fontHeight, color(204), color(255), color(0));
  g_brightnessMinus = new Button(20 + g_fontWidth * 8, videoHeight + int(g_fontHeight * 0.5) + g_fontHeight * 2, g_fontWidth, g_fontHeight, color(204), color(255), color(0));
  g_brightnessPlus = new Button(20 + g_fontWidth * 14, videoHeight + int(g_fontHeight * 0.5) + g_fontHeight * 2, g_fontWidth, g_fontHeight, color(204), color(255), color(0));
  g_thresholdMinus = new Button(20 + g_fontWidth * 8, videoHeight + int(g_fontHeight * 0.5) + g_fontHeight * 3, g_fontWidth, g_fontHeight, color(204), color(255), color(0));
  g_thresholdPlus = new Button(20 + g_fontWidth * 17, videoHeight + int(g_fontHeight * 0.5) + g_fontHeight * 3, g_fontWidth, g_fontHeight, color(204), color(255), color(0));
  
  g_detector = new BlobDetector(g_constraints);
  g_floodFill = new FloodFill();
}

void draw() 
{
  if (!g_video.available())
    return;
  
  background(0, 0, 0);

  if (g_savedImage != null && millis() - g_highlightStartTime >= highlightDelay)
  {
    g_snapshot = g_savedImage;
    g_savedImage = null;
  }
  
  g_video.read();
  image(g_snapshot, videoWidth, 0, g_snapshot.width, g_snapshot.height);
  
  int textX = 20;
  int line = 1;
  fill(255);
  text("H: " + g_constraints.hue, textX, videoHeight + (g_fontHeight / 2) + (line++ * g_fontHeight));
  text("S: " + g_constraints.saturation, textX, videoHeight + (g_fontHeight / 2) + (line++ * g_fontHeight));
  text("B: " + g_constraints.brightness, textX, videoHeight + (g_fontHeight / 2) + (line++ * g_fontHeight));
  
  textX += g_fontWidth * 10;
  line = 1;
  text(g_constraints.hueThreshold, textX, videoHeight + (g_fontHeight / 2) + (line++ * g_fontHeight));
  text(g_constraints.saturationThreshold, textX, videoHeight + (g_fontHeight / 2) + (line++ * g_fontHeight));
  text(g_constraints.brightnessThreshold, textX, videoHeight + (g_fontHeight / 2) + (line++ * g_fontHeight));
  text(nf(g_fillThreshold, 3, 2), textX, videoHeight + (g_fontHeight / 2) + (line++ * g_fontHeight));
  
  g_hueMinus.update();
  g_huePlus.update();
  g_saturationMinus.update();
  g_saturationPlus.update();
  g_brightnessMinus.update();
  g_brightnessPlus.update();
  g_thresholdMinus.update();
  g_thresholdPlus.update();

  g_hueMinus.display();
  g_huePlus.display();
  g_saturationMinus.display();
  g_saturationPlus.display();
  g_brightnessMinus.display();
  g_brightnessPlus.display();
  g_thresholdMinus.display();
  g_thresholdPlus.display();
  
  if (g_hueMinus.isPressed())
    g_constraints.hueThreshold = max(0, g_constraints.hueThreshold - 1);
  if (g_huePlus.isPressed())
    g_constraints.hueThreshold = min(255, g_constraints.hueThreshold + 1);
  if (g_saturationMinus.isPressed())
    g_constraints.saturationThreshold = max(0, g_constraints.saturationThreshold - 1);
  if (g_saturationPlus.isPressed())
    g_constraints.saturationThreshold = min(255, g_constraints.saturationThreshold + 1);
  if (g_brightnessMinus.isPressed())
    g_constraints.brightnessThreshold = max(0, g_constraints.brightnessThreshold - 1);
  if (g_brightnessPlus.isPressed())
    g_constraints.brightnessThreshold = min(255, g_constraints.brightnessThreshold + 1);
  if (g_thresholdMinus.isPressed())
    g_fillThreshold = max(0.0f, g_fillThreshold - 0.25f);
  if (g_thresholdPlus.isPressed())
    g_fillThreshold = min(255.0f, g_fillThreshold + 0.25f);
  
  if (mouseX >= g_video.width && mouseY < g_video.height)
  {
    stroke(255, 255, 0);    
    line(g_video.width, mouseY, width - 1, mouseY);
    line(mouseX, 0, mouseX, g_snapshot.height - 1);
    
    int imageX = mouseX - g_video.width;
    int imageY = mouseY;
    int pixelValue = g_snapshot.pixels[imageY * g_snapshot.width + imageX];
    textX += g_fontWidth * 10;
    line = 1;
    text(int(hue(pixelValue)), textX, videoHeight + (g_fontHeight / 2) + (line++ * g_fontHeight));
    text(int(saturation(pixelValue)), textX, videoHeight + (g_fontHeight / 2) + (line++ * g_fontHeight));
    text(int(brightness(pixelValue)), textX, videoHeight + (g_fontHeight / 2) + (line++ * g_fontHeight));
    
    if (mousePressed && g_savedImage == null)
    {
      FillResults results = g_floodFill.findColorThresholds(g_snapshot, imageX, imageY, g_fillThreshold, color(255, 255, 0));
      g_constraints = results.constraints;
      g_savedImage = g_snapshot;
      g_highlightStartTime = millis();
      g_snapshot = results.highlightedImage;
    }
    
    fill(pixelValue);
    noStroke();
    rect(20 + g_fontWidth * 18, videoHeight + g_fontHeight * 1.5, g_fontWidth, g_fontHeight);
  }
  
  g_detector.setConstraints(g_constraints);
  g_detector.update(g_video);
  Blob blob = g_detector.getBlob();
  if (blob.valid)
    drawBlob(blob);
  else
    image(g_video, 0, 0, g_video.width, g_video.height);
}

void drawBlob(Blob blob)
{
  PImage copy = createImage(g_video.width, g_video.height, RGB);
  copy.copy(g_video, 0, 0, g_video.width, g_video.height, 0, 0, copy.width, copy.height);
  copy.loadPixels();
  
  int src = 0;
  for (int y = blob.minY ; y <= blob.maxY ; y++)
  {
    for (int x = blob.minX ; x <= blob.maxX ; x++)
    {
      if (blob.pixels[src++])
        copy.pixels[y * g_video.width + x] = color(255, 255, 0);
    }
  }
  copy.updatePixels();
  image(copy, 0, 0, copy.width, copy.height);

  stroke(255, 255, 0);
  noFill();
  rect(blob.minX, blob.minY, blob.maxX - blob.minX, blob.maxY - blob.minY);
}

void keyPressed()
{
  switch (Character.toLowerCase(key))
  {
  case ' ':
    g_snapshot.copy(g_video, 0, 0, g_video.width, g_video.height, 0, 0, g_snapshot.width, g_snapshot.height);
    g_snapshot.loadPixels();
    break;
  }
}

void mousePressed()
{
  g_hueMinus.press();
  g_huePlus.press();
  g_saturationMinus.press();
  g_saturationPlus.press();
  g_brightnessMinus.press();
  g_brightnessPlus.press();
  g_thresholdMinus.press();
  g_thresholdPlus.press();
}

void mouseReleased()
{
  g_hueMinus.release();
  g_huePlus.release();
  g_saturationMinus.release();
  g_saturationPlus.release();
  g_brightnessMinus.release();
  g_brightnessPlus.release();
  g_thresholdMinus.release();
  g_thresholdPlus.release();
}

