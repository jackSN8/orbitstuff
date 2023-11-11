class Transfer
{
  float TEJ;//Time (of) ejection
  float TOF;//Time Of Flight
  int SRC;//Source object, 1 Mercury, 2 Venus, 3 Earth etc
  int TGT;//Target object
  
  float transferPEA;//Periapsis of transfer orbit, should be same as radius at time of departure of source object
  float transferAPO;//Apoapsis of transfer orbit -- could be anything but must be atleast radius of target object at time of arrival
  float transferAnomaly;//How many degrees round the sun you execute the ejection burn
  float transferDV;//lets calculate this!
  
  ///Prob need to impliment quite a serious physics engine
  
  
  //Possibilities -- from TEJ position, check certain DV values of purely prograde burn
  //(increments of 50, then 200 after 10000 to 20000?), and pick closest approach out of that set
  
  ///Must have function find vector velocity from position in a planets orbit, then convert that to an orbit
  
  
  
  
  
  Transfer(int tRef,int tSrc,int tTgt,float tTej,float tTof)
  {
    TEJ = tTej;
    TOF = tTof;
    SRC = tSrc;
    TGT = tTgt;
  }
  
  void update()
  {
    
    PVector sourceVel = velFromOrb(new PVector(0,0), 4);
    generateProgradeTraj(sourceVel);
    //Velocity of source planet around the sun, code is very limited so this is quite likely to be only earth
    text("earth vel  : " + sourceVel.mag(),width-170,80);
  }
  
  void generateProgradeTraj(PVector currentVel)
  {
    //Calculate the post burn velocity vector
    float dV = map(mouseX,0,width,-10000,10000);
    PVector normalizedPrograde = new PVector(currentVel.x,currentVel.y,currentVel.z).normalize();
    
    PVector finalVel = alterTraj(7.5*pow(10,3),dV,currentVel);
    
    
    //PVector finalVel = PVector.mult(normalizedPrograde,(currentVel.mag()+dV));
    ///Then generate a new trajectory from the position, and this new velocity vector
    ///Periapsis should be the same,
    //New semi-major axis can be calculated, rGM/(2GM-rv^2)
    float majorAxis = (earth.rad*G*solarMass)/(2*G*solarMass-earth.rad*finalVel.magSq());
    
    
    float pe = earth.pe;
    float ap = 2*majorAxis-earth.pe;
    float minorAxis=sqrt(ap*pe);  
    
    text("Delta V : " + dV ,width-170,110);
    
    
    
    //this code visualizses the new transfer orbit, should prob be moved to dif function
    PVector ellipseDimensions = new PVector(ap+pe,2*sqrt(ap*pe));    
    PVector center = new PVector((ap+pe)/2-pe,0); 
    push();
    translate(width/2,height/2); 
    rotate(earth.anomaly-PI/2);
    stroke(255);
    strokeWeight(1);
    fill(0,0,0,0);
    ellipse(reScale(center.x),reScale(center.y),reScale(majorAxis*2),reScale(minorAxis*2));    
    stroke(255);
    pop();
     
     
  }
  
  
  
  
  //Very limited function to calculate velocity via vis-viva equation based on position
  //only works on designated source bodies (1 mercury, 2 venus etc)
  
  ////dumber stuff
  //dumbass me needs to find a non absurd if statement thing to get proper data from any planert,
  //for now only earth
  PVector velFromOrb(PVector tposition, int tsrc)
  {        
    float argPeri = earth.argPeri;
    PVector pos = new PVector(reScale(earth.center.x+earth.planetVec.x),reScale(earth.center.y+earth.planetVec.y));
    //Velocity is always tangent to edge of ellipse,
    //which is gradient vector of ellipse, partial of each is 2x/(a^2)
    PVector progradeUnit = new PVector(pos.x,pos.y); //Finds the prograde unit vector, which is tanget to the edge of the ellipse
    progradeUnit = progradeUnit.rotate(PI/2).normalize();
    float velMagSqr = G*solarMass*((2/(earth.rad))-(1/earth.ap));
    PVector vel = PVector.mult(progradeUnit,sqrt(velMagSqr));
       
    
    ////some code to visualize the tangent vector, not needed
    //push();
    //translate(width/2,height/2); 
    //rotate(radians(argPeri));
    //stroke(255);
    //strokeWeight(5);
    //line(pos.x,pos.y,pos.x+progradeUnit.x*100,pos.y+progradeUnit.y*100);
    //line(0,0,pos.x,pos.y);
    //strokeWeight(1);
    //pop();
    
    
    return vel;
  }
  
  //takes in input vector and returns vector after escaping the SOI of Earth -- velocity decreases as earths gravity pulls you back
  PVector alterTraj(float orbVel, float dV, PVector sourceVel)
  {
    ///needs to calculate specific energy of hyperbolic trajectory, if trajectory is not hyperbolic, should return vector identical to source planet's orbit
    ///then from specific energy, calculate velocity at edge of sphere of influence. lets hope direction is roughly prograde around sun because that 
    ///direction is what I will choose
    
    if(dV<3500)//placeholder espace velocity threshold, relative to v@LEO, currently just checks if velocity is above a threshold around escape velocity
    {
      return sourceVel;
    }
    PVector sourceVelClone = sourceVel.copy();
    float escapeVel = orbVel+dV;
    float vSOI = sqrt(G*earth.mass*2/earth.soiRadius+2*((-G*earth.mass)/(6600*pow(10,3))+pow(escapeVel,2)/2));
    //6600*10^3 is radius of low earth orbit, to be changable in future
    
    //then calculate speed around sun
    float refSpeed = sourceVel.mag()+vSOI;        
    
    text("VSoi : " + refSpeed ,width-170,130);
    
    
    
    return sourceVelClone.normalize().mult(refSpeed);
  }
  
  
}
