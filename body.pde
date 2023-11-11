class Body
{

  color bColor;
  
  float ap;
  float pe;
  
  float argPeri;
  float longAscNode;
  
  String name;
  
  float mass = 6*pow(10,24);//mass set to Earths initially
  
  float soiRadius = 925*pow(10,6);//radius of sphere of influence of gravitional body
  //using patched conics. this is set to Earths, tb changed to what the actual value is
  
  
  PVector center;
  PVector ellipseDimensions;//width & height
  float minorAxis;
  float majorAxis;
  float orbitPeriod;
  float ecc;
  
  float anomaly = 0;
  
  PVector planetVec;///Vector pointing from center of ellipse to planet,
  //if you add center, the vector points from Sun to planet, somewhat dumb again
  float rad;//distance from sun
  float angMom;//angular momentum  
  
  Body(String tName, float Tap, float Tpe,float tLongAscNode, float TargPeri,float iAnomaly, color col)
  {
    name = tName;
    
    //ap = reScale(Tap);
    //pe = reScale(Tpe);
    ap = Tap;
    pe = Tpe;
    bColor = col;
    argPeri=TargPeri;
    longAscNode = tLongAscNode;
    calculateKepler();    
    anomaly = radians(iAnomaly);
    
    majorAxis=(ap+pe)/2;
    minorAxis=sqrt(ap*pe);
    angMom = minorAxis*sqrt(G*solarMass/majorAxis);//w/o mass of own object
    calculateKepler();  
  }
  
  void display()
  {
     planetVec = pointOnOrbit(anomaly);
     rad = PVector.add(planetVec,center).mag();
     drawOrbitEllipse();
     anomaly += timeSpeed*(angMom*pow(10,5))/pow(rad,2);
     //anomaly +=-pow(10,14)*PI/(pow(unScale(rad),2));
     
  }
  
  
  //draws an ellipse from the width, height, center & arg of periapsis
  void drawOrbitEllipse()
  {
    push();
    translate(width/2,height/2); 
    rotate(radians(argPeri+longAscNode));
    stroke(bColor,255);
    strokeWeight(1);
    fill(0,0,0,0);
    ellipse(reScale(center.x),reScale(center.y),reScale(majorAxis*2),reScale(minorAxis*2));    
    stroke(255);
    fill(bColor);
    circle(reScale(center.x+planetVec.x),reScale(center.y+planetVec.y),5);
    pop();
  }
  
  ///Returns a point on orbit from true anomaly & orbital paremeters
  
  
  //////////////////////////////hopefuly fixed?
  /////////////////Notable mistake -- this formula gives the correct position if tAnom is the eccentric anomaly of the object, not true
  /////////////////May fix this, but may be a pain in ass to fix, this bug is why movement is odd, espicially of mercury (not lack of relativity implimation)
  //////////////////////////////hopefully fixed?
  
  PVector pointOnOrbit(float tAnom)
  {
    //Convert true anomaly to eccentric anomaly
    
    float eAnom = 2*atan(sqrt((1-ecc)/(1+ecc))*tan(tAnom/2));
    
    float x = majorAxis*cos(eAnom);
    float y = minorAxis*sin(eAnom);
    PVector pos = new PVector(x,y);
    return pos;
  }  
  
  //takes apogee and perigee and gives center, width & height
  void calculateKepler()
  {
    ellipseDimensions = new PVector(ap+pe,2*sqrt(ap*pe));
    center = new PVector((ap+pe)/2-pe,0); 
    //Orbital period is equal to period of circular orbit with radius of semi-major axis
    orbitPeriod = (2*PI*sqrt(pow(majorAxis,3)/(solarMass*G)))/(86400*365);
    ecc = sqrt(1-pow((minorAxis/majorAxis),2));
  }
    
  

  float unScale(float inp)
  {
    return inp*visScaleFactor;
  }
  
}
