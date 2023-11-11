class earthProgradeTransfer
{
  //this class should take time to eject and dv, and create, and store a set of orbital paremeters,
  //and keplerian elliptical paremeters 
  
  //Ejection eleements
  float TEJ;
  float dV;
  
  //Calculated ejection elements
  float ejectionAnomaly;//True anomaly of Earth at time of ejection burn
  float ejectionRad;//Radius of Earth's orbit around sun at time of ejection burn, easy calculation from ejectionAnomaly
  float ejectionOrbit = 200*pow(10,3);//radius of spacecrafts orbit around Earth during ejection,
  
  
  
  //orbital elements
  float ap;
  float pe;
  float argPeri;//argument of periapsis, here just how far around from x=0 the periapsis is in radians
  float orbitPeriod;
  float ecc;//eccentricity
  
  //keplerian elements
  PVector center;//how offset the ellipse center is from the sun
  float majorAxis;
  float minorAxis;
  
  //TEJ in years, dV in m/s
  earthProgradeTransfer(float tTEJ, float tdV)
  {
    ejectionAnomaly = timeToAnomaly(tTEJ);
    dV = tdV;
    
  }
  
  void update()
  {

    ejectionRad = planets.get(2).pointOnOrbit(ejectionAnomaly).mag();   
    PVector earthVel = velFromOrb(ejectionAnomaly);
    generateKepler(alterTraj(7500,4000,earthVel).mag());
    text("DV of Transfer is "+dV,width-170,80);
    text("Distance to nearest planet "+distanceNearestPlanet(0.5  ),width-270,110);
  }
  
  
  //Finds distance to nearest planet at a specific time of arrival
  
  float distanceNearestPlanet(float time)
  {
    //Finds position of spacecraft
    ///First need to find eccentric anomaly from time
    float timeSinceEject = time-TEJ;
    float spaceCraftMeanAnomaly = TWO_PI*(timeSinceEject/orbitPeriod);
    
    //Uses newton raphsom to iterate to find eccentric anomaly
    float spaceCraftEccentricAnomaly = solveKeplersEquation(spaceCraftMeanAnomaly,ecc,pow(10,-6));
    
    PVector craftPos = pointOnOrbit(spaceCraftEccentricAnomaly);
    
    float nearestDistSq = pow(10,40);
    for(int i=0; i<planets.size(); i++)
    {
      Body b = planets.get(i);
      //Need to find position of planet at timeOfArrival
      ///Find mean anomaly of that planet
      float bodyMeanAnomaly = TWO_PI*(time%b.orbitPeriod);
      //Uses newton raphsom to iterate to find eccentric anomaly
      float bodyEccentricAnomaly = solveKeplersEquation(bodyMeanAnomaly,b.ecc,pow(10,-6));
      PVector radVec = pointOnOrbit(bodyEccentricAnomaly);
      float distanceSq = PVector.sub(radVec,craftPos).magSq();
      if(distanceSq<nearestDistSq)
      {
        nearestDistSq = distanceSq;
      }
     }
    return sqrt(nearestDistSq);
  }
  
  
  //M is mean anomaly, e is eccentricity, 
  public float solveKeplersEquation(float M, float e, float tolerance) 
  {
        float E = M;  // Initial guess
        float delta = 1.0;

        while (Math.abs(delta) > tolerance) {
            float f = E - e * (float)Math.sin(E) - M;
            float fPrime = 1 - e * (float)Math.cos(E);
            delta = f / fPrime;
            E -= delta;
        }

        return E;
    }
  
  
  
  ///Returns a point on orbit from eccentric anomaly & orbital paremeters
  PVector pointOnOrbit(float tAnom)
  {
    float x = majorAxis*cos(tAnom);
    float y = minorAxis*sin(tAnom);
    PVector pos = new PVector(x,y);
    return pos;
  }      
      
  
//returns velocity vector of earth relative to sun at specified true anomaly
  PVector velFromOrb(float anomaly)
  {           
    float argPeri = planets.get(2).argPeri;
    PVector radVec = new PVector(planets.get(2).majorAxis*cos(anomaly),planets.get(2).minorAxis*sin(anomaly));
    
    PVector pos = new PVector(reScale(planets.get(2).center.x+radVec.x),reScale(planets.get(2).center.y+radVec.y));
    //Velocity is always tangent to edge of ellipse,
    //which is gradient vector of ellipse, partial of each is 2x/(a^2)
    PVector progradeUnit = new PVector(pos.x,pos.y); //Finds the prograde unit vector, which is tanget to the edge of the ellipse
    progradeUnit = progradeUnit.rotate(PI/2).normalize();
    float velMagSqr = G*solarMass*((2/(ejectionRad))-(1/planets.get(2).ap));
    PVector vel = PVector.mult(progradeUnit,sqrt(velMagSqr));
    return vel;
  }
    
   //returns vector of velocity of spacecraft after ejecting from Earth, relative to sun   
   //Orbvel is velocity around Earth, placeholder is 7500m/s, dV is dV, sourceVel is currentVector of planetary orbit
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
    float vSOI = sqrt(G*planets.get(2).mass*2/planets.get(2).soiRadius+2*((-G*planets.get(2).mass)/(6600*pow(10,3))+pow(escapeVel,2)/2));
    //6600*10^3 is radius of low earth orbit, to be changable in future
    
    //then calculate speed around sun
    float refSpeed = sourceVel.mag()+vSOI;           
    
    return sourceVelClone.normalize().mult(refSpeed);
  }
  
  //generates keplerian elements for orbit after ejection velocity has been calculated
  void generateKepler(float ejectionVelocity)
  {
    ///Then generate a new trajectory from the position, and this new velocity vector
    ///Periapsis should be the same,
    //New semi-major axis can be calculated, rGM/(2GM-rv^2)
    
    majorAxis = (ejectionRad*G*solarMass)/(2*G*solarMass-ejectionRad*pow(ejectionVelocity,2));    
    pe = planets.get(2).pe;
    ap = 2*majorAxis-planets.get(2).pe;
    minorAxis=sqrt(ap*pe);  
    
    //Orbital period is equal to period of circular orbit with radius of semi-major axis
    orbitPeriod = (2*PI*sqrt(pow(majorAxis,3)/(solarMass*G)))/(86400*365);
    ecc = sqrt(1-pow((minorAxis/majorAxis),2));
    
    center = new PVector((ap+pe)/2-pe,0); 
    push();
    translate(width/2,height/2); 
    rotate(ejectionAnomaly);
    stroke(0,0,255);
    strokeWeight(1);
    fill(0,0,0,0);
    ellipse(reScale(center.x),reScale(center.y),reScale(majorAxis*2),reScale(minorAxis*2));    
    stroke(255);
    pop();   
  }
  
  //converts TEJ to anomaly
  float timeToAnomaly(float TEJ)
  {
    float anomaly = TEJ*(TWO_PI)+planets.get(2).argPeri;
    return anomaly;
  }
  
  
}
