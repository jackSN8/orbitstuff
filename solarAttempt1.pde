////visualization of planertary orbits, small tester
///planets are not to scale in radius, but orbits are correct

ArrayList<Body> planets = new ArrayList<Body>();

Body mercury;
Body venus;
Body earth;
Body mars;
Body jupiter;

//Transfer tran;

earthProgradeTransfer ePT;

float timeSpeed = 1;

float visScaleFactor = 2*pow(10,9);

float G = 6.67*pow(10,-11);
float solarMass = 2*pow(10,30);

float t=0;
float y=0;




/////////////////////Read this next coding sesh
////need to impliment argument of periapsis & then longitude of ascending node,
////arg of periapsis needs long of ascending node. Actual position from some defined equator is long of ascending node + argument of periapsis + true anomaly
////




void setup()
{
  size(1200,800);
  
  //apoap,periap,long asc node,arg periap,initial anomaly,(mass?) color
  
  //, G is in metres, dumby
  //mercury = new Body(69.8*pow(10,6),46*pow(10,6),29,330*pow(10,21),color(140,140,100));
  //venus = new Body(108.9*pow(10,6),107.48*pow(10,6),54.8,4867*pow(10,21),color(255,174,66));
  //earth = new Body(152*pow(10,6),147*pow(10,6),85.9,5974*pow(10,21),color(0,0,220));
  //mars = new Body(249*pow(10,6),206.7*pow(10,6),286.2,642*pow(10,21),color(220,0,20));
  
  
  planets.add(new Body("Mercury",69.8*pow(10,9),46*pow(10,9),48.39344771804957,2.89883*10,2.996055621749458*100,color(140,140,100)));
  planets.add(new Body("Venus",108.9*pow(10,9),107.48*pow(10,9),76.82252084759426,5.4884*10,3.107799941746339*100,color(255,174,66)));
  planets.add(new Body("Earth",152*pow(10,9),147*pow(10,9),34.44935790286960,1.19156692*100,3.570593122720978*100,color(0,0,220)));
  planets.add(new Body("Mars",249*pow(10,9),206.7*pow(10,9),49.70472381171602,2.86156*10,1.711890087010959*100,color(220,0,20)));
  planets.add(new Body("Jupiter",816*pow(10,9),740.6*pow(10,9),0,0,273,color(255,255,237)));
  
  //tran = new Transfer(5,5,5,5,5);
  ePT = new earthProgradeTransfer(0,4000);
}

void draw()
{
  //visScaleFactor = map(mouseX,0,width,6*pow(10,9),0.3*pow(10,9));
  background(5);
  for(int i=0; i<planets.size(); i++)
  {
    Body b = planets.get(i);
    b.display();
  }
  fill(200,200,0);
  circle(width/2,height/2,20);
  
  text("real seconds: " + t,width-170,20); 
  t+=(1/frameRate);
  text("earth years  : " + y,width-170,50);
  y=planets.get(2).anomaly/TWO_PI;
  //text("earth vel  : " + velFromOrb(new PVector(0,0),4),width-170,80);
  
 // tran.update();
  ePT.update();
}


//Scales real apogee value from km to pixels based on zoom
float reScale(float inp)
{
  return inp/visScaleFactor;
}
  




///calculates velocity of earth random debug shit remove later

float velFromOrb(PVector tposition, int tsrc)
  {
    PVector pos = PVector.add(earth.planetVec,earth.center);
    //Velocity is always tangent to edge of ellipse
    float velMagSqr = G*solarMass*((2/(earth.rad))-(1/earth.ap));
    return sqrt(velMagSqr);
  }
