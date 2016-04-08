/* @pjs font="Balto-Thin.otf; */

PFont pizzaFont;

PGraphics pizza;

color backC = color(255);
color typeC = color(0);

int fontSize=135;

int num = 10000; //how many particles we'll have in the system. More particles = slower sketch.

Particle[] particle = new Particle[num]; //Initialise array of particles of length "num"

ArrayList<Integer> inventoryX;
ArrayList<Integer> inventoryY;

String alphabetLow="a b c d e f g h i j k l m n o p q r s t u v w x y z";

String numbers="1 2 3 4 5 6 7 8 9 0\n! @ # $ % ^ & * , .";

String alphabetUp="A B C D E F G H I J \nK L M N O P Q R S \nT U V W X Y Z";

boolean runOnce=true;

//------------------------ SETUP ---------------------------------------

void setup() {
  size(1280, 700);
  frameRate(24);
  smooth();  //turn on anti-aliasing
  noStroke();
  background(0);

  pizza = createGraphics(width, height);
  pizzaFont = loadFont("Balto-Thin.otf"); // part of the alt font creation


  //fill particle array with new Particle objects
  for (int i=0; i<particle.length; i++) {
    particle[i] = new Particle(new PVector(random(0, width), random(0, height)), 2, 10, 3);
  }

  inventoryX=new ArrayList();
  inventoryY=new ArrayList();
}

//------------------------ DRAW ----------------------------------------

void draw() {

  pizza.beginDraw();
  pizza.background(backC);
  pizza.noStroke();
  pizza.fill(typeC);
  pizza.textAlign(CENTER, CENTER);
  pizza.textSize(fontSize);
  pizza.textFont(pizzaFont,fontSize);
  pizza.text(numbers, pizza.width-width+100, pizza.height-(height+100),width-200,height-50); //slight offset from center on the Y to make it feel more centered vertically
  pizza.endDraw();

  //draw trails, trail length can be altered by making alpha value in fill() lower
  fill(0, 55);
  rect(0, 0, width, height);

  if (runOnce) {
    pushMatrix();

    for (int i = 0; i<width; i+=2) {
      for (int j = 0; j<height; j+=2) {
        color checkColor = pizza.get(i, j);
        if (checkColor == typeC) {
          inventoryX.add(i);
          inventoryY.add(j);
        }
      }
    }
    popMatrix();
    runOnce=false;
  }

  for (int p=0; p<inventoryX.size(); p++) {
    particle[p].run(inventoryX.get(p), inventoryY.get(p));
  }
}



//------------------------ OBJECT --------------------------------------

class Particle {
  /*
    PVector is a class in Processing that makes it easier to store
   values, and make calculations based on these values. It can make
   applying forces to objects much easier and more efficient!
   */
  PVector loc; //location vector
  PVector vel; //velocity vector
  PVector acc; //acceleration vector
  int sz;  //size of particle
  float gravity;  //gravity variable
  float mass;  //mass variable
  float velocityLimit = 1;  //the maximum velocity a particle can travel at
  float d;  //distance variable between particle and the target co-ordinates

  //CONSTRUCTOR
  Particle(PVector _loc, int _sz, float _gravity, float _mass) {
    loc = _loc.get();  //when calling loc, return current location of the selected particle
    vel = new PVector(0, 0);  //set vel and acc vectors to 0 as default
    acc = new PVector(0, 0);
    sz = _sz;
    gravity = _gravity;
    mass = _mass;
  }


  //method to render the particle. control how it looks here!
  void display() {
    ellipseMode(CENTER);
    fill(255, 255-d, 255, 100-d/2);
    ellipse(loc.x, loc.y, sz, sz);
  }

  //math for attraction and repulsion forces
  //tx and ty are the co-ordinates attraction/repulsion will be applied to
  void forces(float tx, float ty) {
    PVector targetLoc = new PVector(tx, ty);  //creating new vector for attractive/repulsive x and y values
    PVector dir = PVector.sub(loc, targetLoc);  //calculate the direction between a particle and targetLoc
    d = dir.mag();  //calculate how far away the particle is from targetLoc
    dir.normalize();  //convert the measurement to a unit vector

    //calculate the strength of the force by factoring in a gravitational constant and the mass of a particle
    //multiply by distance^2
    float force = (gravity*mass) / (d*d);

if(mousePressed){
      dir.mult(1);
    velocityLimit=2.4;
}else{
    //attraction and direction
    dir.mult(-1);
    velocityLimit=2.4;
}
    //apply directional vector
    applyForce(dir);
  }

  //method to apply a force vector to the particle
  void applyForce(PVector force) {
    force.div(mass);
    acc.add(force);
  }

  //method to update the location of the particle, and keep its velocity within a set limit
  void update() {
    vel.add(acc);
    vel.limit(velocityLimit);
    loc.add(vel);
    acc.mult(0);
  }

  //main method that combines all previous methods, and takes two arguments
  //tx and ty are inherited from forces(), and set the attractive/repulsive co-ords
  void run(float tx, float ty) {
    forces(tx, ty);
    display();
    update();
  }
}