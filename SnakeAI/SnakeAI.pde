import java.util.*;

int snakeWidth = 600;
int snakeHeight = 600;
int playersRendered = 10;
int gen = 0;
boolean hideGraphs = false;
boolean hideVision = false;
boolean lowerFramerate = false;
int popSize = 500;
Population pop;
boolean won = false;
PFont graph;
PFont text;
PFont bold;
int start;

void setup() {
  size(1920, 1080, FX2D);
  frameRate(144);
  smooth();
  
  start = millis();
  
  graph = createFont("/data/Roboto-Regular.ttf", 18, true);
  text = createFont("/data/Roboto-Regular.ttf", 26, true);
  bold = createFont("/data/Roboto-Bold.ttf", 30, true);
  
  pop = new Population(500, new int[] { 24, 16, 4 });
  pop.maxFitnessGraph = new Graph(700, 50, "Generation", "Max. Fitness" , 700, 350, 4, new int[] { 0, 0, 0 });
  pop.avgFitnessGraph = new Graph(700, 550, "Generation", "Avg. Fitness" , 700, 350, 4, new int[] { 255, 0, 0 });
  //pop.loadProgram("/data/program.json");
}

void draw() {
  background(255);
  
  pop.update();
  pop.show();
  
  if (pop.isAllDead()) {
    pop.naturalSelection();
  }
  
  if (!hideGraphs) {
    pop.maxFitnessGraph.show();
    pop.avgFitnessGraph.show();
    pop.nnGraph.show(1430, 10);
  }
  
  
  if (pop.avgFitnessGraph.size() > 0) {
    if (pop.avgFitnessGraph.size() > 1 && pop.avgFitnessGraph.get(pop.avgFitnessGraph.size() - 2).data < pop.avgFitnessGraph.get(pop.avgFitnessGraph.size() - 1).data) {
      fill(0, 255, 0);
    }
    else {
      fill(255, 0, 0);
    }
    textFont(bold);
    text("Avg fitness: " + pop.avgFitnessGraph.get(pop.avgFitnessGraph.size() - 1).data, 20, 640);
  }
  
  int timer = millis() - start;
  
  int seconds = (int) (timer / 1000) % 60 ;
  int minutes = (int) ((timer / (1000*60)) % 60);
  int hours   = (int) ((timer / (1000*60*60)) % 24);
  
  textFont(text);
  fill(0);
  text("Players rendered: " + playersRendered, 20, 680);
  text("Number dead: " + pop.getNumberDead(), 20, 720);
  text("Framerate: " + frameRate, 20, 760);
  text("Time since start: " + String.format("%02d", hours) + ":" + String.format("%02d", minutes) + ":" + String.format("%02d", seconds), 20, 800);
  text("Score of best: " + pop.players[0].level.score, 20, 840);
  
  if (pop.players[0].level.score >= 399) {
    won = true;
  }
  
  if (won) {
    text("Won!!", 20, 880);
  }
  
  if (playersRendered < 0) {
    playersRendered = 0;
  }
  else if (playersRendered > popSize) {
    playersRendered = popSize;
  }
}

void keyTyped() {
  switch(key) {
    case 'g':
      hideGraphs = toggle(hideGraphs);
      println("test");
      break;
    case '=':
      playersRendered++;
      break;
    case '-':
      playersRendered--;
      break;
    case 'f':
      lowerFramerate = toggle(lowerFramerate);
      break;
  }
}

boolean toggle(boolean bln) {
  if (bln) {
    return false;
  }
  
  return true;
}
