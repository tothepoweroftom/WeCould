/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/83423*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/2925*@* */
/* !do not delete the line above, required for linking your tweak if you re-upload */

// sketch:  PG_SnowyForest.pde
// Original created 2009 by Esteban Hufstedler
// Tweaked v1.01 12/2012 by Gerd Platl 

/**
 'SnowyForest' create a forest with random trees in winter.
 Press mouse button or <blanc> to stop anmiation.
 <blanc> toggle animation
 <return> clear screen
 b  toggle blurring
 o  toggle scrolling
 s  save screenshot as "SnowyForest.png"
 */

color backgroundCol = color(109,153,195,120);  // lightgray
boolean paused = false;
boolean blurring = false;
boolean scroll = true;
float noiseY = 200;

boolean crazying = false;


// set sizes, counts, arrays, etc.
int w = 850;
int h = 480;
int halfW = w/2; // use for max x coordinate
int halfH = h/2; // use for max y coordinate
// color info
color skyColor = color(60, 135, 245);
color cloudColor = color(220, 250, 255);
// cloud info
float cloudSize = .01; 
float mousePos = 0;
int cloudAlpha = 40;
int numOfClouds = 100;
int cloudMovement = 32; // range of movement for cloud within its location
int cloudSharpness = 10; // number of pixels to adjust edges
// arrays to hold cloud point and position info - this is lousy OO design!
int numOfPts = 9;
int cloudBase [][][] = new int [numOfClouds][numOfPts][2]; // base coordinates
int cloudTranslate [][] = new int [numOfClouds][2]; // 

//----------------------------------------------------------
void setup()
{
  size(850 , 480);
  background(backgroundCol);
    buildCloudBases();
  buildTranslateArray();
  smooth();
  //background(skyColor);
  noFill();
  smooth();
  //frameRate(4);
}
//----------------------------------------------------------
void draw()
{
  if (paused) return;   //-->

  //-- scroll up picture 
  if (scroll)
    copy (0,0, width, height, 0, -int(mouseY*0.015), width,height);

  //-- fade screen to light gray
  if (frameCount % 5  == 0)
  {
    fill(backgroundCol, 70);
    noStroke();
    rect(0, 0, width, height);
  }
  
  if (crazying) {
  for (int i = 0; i < numOfClouds; i++) {
    cloud(i);
  }

  
  }
  //-- draw snow and tree
  drawSnow();
  mousePos = map(mouseX, 0, width, 0,850);
  (new PTree(mousePos)).draw();     // draw a random tree

  //-- blurring gives a foggy scene
  if ((frameCount % 120 == 0) && blurring) 
    filter(BLUR, 20);
}
//----------------------------------------------------------
void drawSnow()
{
  noiseY += 0.2;
  for (int xi = 0; xi<width; xi++)
  {
    float r = noise(xi*0.01, noiseY);
    stroke(127+128*r, 205);
    line (xi, height-2-r*8, xi, height-1);
  }
}
//----------------------------------------------------------
void tooglePause()
{
  paused = !paused;
  if (paused) noLoop();  // do not waste cpu time for pausing! 
  else loop();
}

void toggleCrazy(){
  if (crazying) { crazying = false; }
  else { crazying = true; }
  print(crazying);
}
//----------------------------------------------------------
void mouseClicked()
{  tooglePause(); }
//----------------------------------------------------------
void keyTyped()
{
  //println (key+"  "+int(key));
  if      (key == ' ') tooglePause(); 
  else if (key == 10) { background(backgroundCol); paused=false; } //return?
  else if (key == 'b') blurring = !blurring;
  else if (key == 'o') scroll = !scroll;
  else if (key == 's') save("SnowyForest.png");
  else if (key == 'c') toggleCrazy();
}


//----------------------------------------------------------
// basic tree properties
//----------------------------------------------------------
boolean addSnow = true;
float maxSnowTheta = HALF_PI*4/5;
float minBranchWidth = 1.5;
color snowColor1 = color(151,209,41, 222); // yellowWhite 
color snowColor2 = color (151,255,50,222); // blueWhite

//==========================================================
//  a class to create and draw a tree
//==========================================================
class PTree
{
  float x1,y1,x2,y2;        // position
  color myColor;
  float theta;
  float branchWidth;
  float branchWidth0;
  float totalBranchLength;  // length this branch can be
  int nBranchDivisions;     // the length of each line segment
  float percentBranchless;  // it grows  at least this amount before branching more
  float branchSizeFraction; // the branches are this much of the size at the split
  float dThetaGrowMax;
  float dThetaSplitMax;
  float oddsOfBranching;    // the odds of branching at a given location.
  float lengthSoFar = 0.0;  // this does the drawing/growing!
  
  //----------------------------------------------------------
  // constructor 1
  //----------------------------------------------------------
  PTree ()
  { 
    lengthSoFar = 0.0;
    create();
  }
  
    PTree (float xi)
  { 
    lengthSoFar = 0.0;
    create(xi);
  }
  //----------------------------------------------------------
  // constructor 2:  create a new random tree
  //----------------------------------------------------------
  PTree (float xi, float yi, color treeColor, 
         float thetaI, float branchWidth0I,
         float totalBranchLengthI, int nBranchDivisionsI, 
         float percentBranchlessI, float branchSizeFractionI, 
         float dThetaGrowMaxI, float dThetaSplitMaxI,
         float oddsOfBranchingI)
  {
    create (xi, yi, treeColor, 
          thetaI,  branchWidth0I,
          totalBranchLengthI,  nBranchDivisionsI, 
          percentBranchlessI,  branchSizeFractionI, 
          dThetaGrowMaxI,  dThetaSplitMaxI,
          oddsOfBranchingI);
  }
  //----------------------------------------------------------
  // create a new random tree
  //----------------------------------------------------------
  void create()
  { 
    create (random(width), height-8, color(random(0,60))
           , -HALF_PI, 10, 100
           , 30, 0.3
           , 0.5, PI/15
           , PI/6, 0.3); 
  }
  
    void create(float xi)
  { 
    create (xi + random(500), height-8, color(random(0,60))
           , -HALF_PI, 10, 300
           , 30, 0.3
           , 0.5, PI/15
           , PI/6, 0.3); 
  }
  //----------------------------------------------------------
  // create a new random tree
  //----------------------------------------------------------
  void create (float xi, float yi, color treeColor, 
         float thetaI, float branchWidth0I,
         float totalBranchLengthI, int nBranchDivisionsI, 
         float percentBranchlessI, float branchSizeFractionI, 
         float dThetaGrowMaxI, float dThetaSplitMaxI,
         float oddsOfBranchingI)
  {
    x1 = x2 = xi;
    y1 = y2 = yi;
    myColor = treeColor;
    theta = thetaI;
    branchWidth0 = branchWidth0I;
    branchWidth = branchWidth0;
    totalBranchLength =totalBranchLengthI;
    nBranchDivisions =nBranchDivisionsI;
    percentBranchless = percentBranchlessI;
    branchSizeFraction = branchSizeFractionI;
    dThetaGrowMax = dThetaGrowMaxI;
    dThetaSplitMax = dThetaSplitMaxI;
    oddsOfBranching = oddsOfBranchingI;
  }

  //----------------------------------------------------------
  // draw the tree
  //----------------------------------------------------------
  void draw()
  {
    if (branchWidth < minBranchWidth)  //stop growing if it's too thin to render
      lengthSoFar = totalBranchLength;
    while(lengthSoFar < totalBranchLength)
    {
      branchWidth = branchWidth0*(1-lengthSoFar/totalBranchLength);
      // do I need to split?
      if(lengthSoFar/totalBranchLength > percentBranchless) // if i can branch
      { 
        if(random(0,1) < oddsOfBranching)  // and i randomly choose to
        { stroke(myColor);
          // make a new branch there!
          PTree tree = new PTree(x1, y1, myColor
                      , theta+randomSign()*dThetaSplitMax, branchWidth
                      , totalBranchLength*branchSizeFraction, nBranchDivisions
                      , percentBranchless, branchSizeFraction
                      , dThetaGrowMax, dThetaSplitMax
                      , oddsOfBranching);
          tree.draw();
        }
      }

      //change directions, grow forward 
      float nextSectionLength = totalBranchLength/nBranchDivisions;
      lengthSoFar += nextSectionLength;
      theta += randomSign()*random(0,dThetaGrowMax);
      x2 = x1 + nextSectionLength*cos(theta);
      y2 = y1 + nextSectionLength*sin(theta);
      // scale thickness by the distance it's traveled.
      strokeWeight(abs(branchWidth));
      stroke(myColor);
      line(x1,y1,x2,y2);
      if(addSnow)
      {
        //initially, just a line on the upper half
        stroke(snowColor1);   

        float dx =0;
        float dy =0;
        float overlapScaling = 1.2;
        if(theta < -PI/2)
        {
          if(abs(PI+theta) < maxSnowTheta)
          {
            stroke(snowColor2);
            float snowThickness = constrain(abs(branchWidth)/2*(1-abs(theta+PI)/HALF_PI),0,abs(branchWidth)/2);
            if(snowThickness>0){
              strokeWeight(snowThickness);
              dx = (abs(branchWidth)-snowThickness)/2*cos(theta+PI/2)*overlapScaling;
              dy = (abs(branchWidth)-snowThickness)/2*sin(theta+PI/2)*overlapScaling;
              line(x1+dx-abs(branchWidth)*cos(theta)/4
                  ,y1+dy-abs(branchWidth)*sin(theta)/4
                  ,x2+dx
                  ,y2+dy);
            }
          }
        }
        if(theta > -PI/2)
        {
          if(abs(theta) < maxSnowTheta)
          {
            stroke(255,120);
            float snowThickness = constrain(abs(branchWidth)/2*(1-abs(theta)/HALF_PI),0,abs(branchWidth)/2);
            if(snowThickness > 0)
            {
              strokeWeight(snowThickness);
              dx = (abs(branchWidth)-snowThickness)/2*cos(theta-PI/2)*overlapScaling;
              dy = (abs(branchWidth)-snowThickness)/2*sin(theta-PI/2)*overlapScaling;
              line(x1+dx-abs(branchWidth)*cos(theta)/4
                  ,y1+dy-abs(branchWidth)*sin(theta)/4
                  ,x2+dx
                  ,y2+dy);
            }
          }
        }
      }
      x1 = x2;
      y1 = y2;
    }
  }
}
//----------------------------------------------------------
int randomSign(){ //returns +1 or -1
  float num = random(-1,1);
  if(num==0)
    return -1;
  else
    return (int)(num/abs(num));
}


/* 
  this method is to create random points to put in
  an array that will be used as the base of a cloud
  the points are then used for the transparent redraws   
*/

void buildCloudBases () {
  for (int i = 0; i < numOfClouds; i++) {
    // north point
    cloudBase [i][0][0] = halfW;
    cloudBase [i][0][1] = (int) random((0 + cloudSharpness),(halfH));
    // northeast point
    cloudBase [i][1][0] = (int) random((halfW), (w - cloudSharpness));
    cloudBase [i][1][1] = (int) random((0 + cloudSharpness), (halfH));
    // east point
    cloudBase [i][2][0] = (int) random((halfW), (w - cloudSharpness)); 
    cloudBase [i][2][1] = halfH;
    // southeast point
    cloudBase [i][3][0] = (int) random((halfW), (w - cloudSharpness));
    cloudBase [i][3][1] = (int) random((halfH), (h - cloudSharpness));
    // south point
    cloudBase [i][4][0] = halfW;
    cloudBase [i][4][1] = (int) random((halfH), (h - cloudSharpness));
    // southwest point
    cloudBase [i][5][0] = (int) random((0 + cloudSharpness), (halfW));
    cloudBase [i][5][1] = (int) random((halfH), (h - cloudSharpness));
    // west point
    cloudBase [i][6][0] = (int) random((0 + cloudSharpness), (halfW));
    cloudBase [i][6][1] = halfH;
    // northwest point
    cloudBase [i][7][0] = (int) random((0 + cloudSharpness), (halfW));
    cloudBase [i][7][1] = (int) random((0 + cloudSharpness), (halfH));
    // close point
    cloudBase [i][8][0] = halfW;
    cloudBase [i][8][1] = (int) random((0 + cloudSharpness),(halfH));    
  }
  // now reduce by cloud size
  for (int i = 0; i < numOfClouds; i++) {
    for (int j = 0; j < numOfPts; j++) {
      cloudBase [i][j][0] = (int) (cloudBase [i][j][0] * cloudSize);
      cloudBase [i][j][1] = (int) (cloudBase [i][j][1] * cloudSize);
    }   
  }
}
 
/*
  this method is to create random points to use
  for translation of a cloud position
*/

void buildTranslateArray () {
  for (int i = 0; i < numOfClouds; i++) {
    cloudTranslate [i][0] = (int) random(0, w);
    cloudTranslate [i][1] = (int) random(0, h);    
  }
}
/* 
  method for cloud making
*/

void cloud (int cloudNum) {
  // clouds will appear or disappear based on random control
  if ((int) random(0, 2) == 0) {
      fill(skyColor, cloudAlpha);
  } else {
    fill(cloudColor, cloudAlpha);
  }
  noStroke();
  smooth();
  pushMatrix();
  if (cloudTranslate [cloudNum][0] > w) {
    cloudTranslate [cloudNum][0] = 0 - cloudSharpness;
  }
  if (cloudTranslate [cloudNum][1] > h) {
    cloudTranslate [cloudNum][1] = 0 - cloudSharpness;
  }
  translate(
    cloudTranslate [cloudNum][0] += (int) random(-cloudMovement, cloudMovement),
    cloudTranslate [cloudNum][1] += (int) random(-cloudMovement, cloudMovement));
  beginShape();
  for (int i = 0; i < numOfPts; i++) {
    curveVertex(
      random(cloudBase [cloudNum][i][0] - cloudSharpness, cloudBase [cloudNum][i][0] + cloudSharpness),
      random(cloudBase [cloudNum][i][1] - cloudSharpness, cloudBase [cloudNum][i][1] + cloudSharpness));
  }
  endShape();
  popMatrix();
}

