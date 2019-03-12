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

void setup() {
  size(1920, 1080, P2D);
  frameRate(1000);
  
  pop = new Population(popSize, new int[] { 24, 16, 4 });
  pop.maxFitnessGraph = new Graph(700, 50, "Generation", "Max. Fitness" , 700, 350, 4, new int[] { 0, 0, 0 });
  pop.avgFitnessGraph = new Graph(700, 550, "Generation", "Avg. Fitness" , 700, 350, 4, new int[] { 255, 0, 0 });
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
    pop.nnGraph.show(1430, 20);
  }
  
  textSize(26);
  
  if (pop.avgFitnessGraph.size() > 0) {
    if (pop.avgFitnessGraph.size() > 1 && pop.avgFitnessGraph.get(pop.avgFitnessGraph.size() - 2).data < pop.avgFitnessGraph.get(pop.avgFitnessGraph.size() - 1).data) {
      fill(0, 255, 0);
    }
    else {
      fill(255, 0, 0);
    }
    text("Avg fitness: " + pop.avgFitnessGraph.get(pop.avgFitnessGraph.size() - 1).data, 750, 20);
  }
  
  fill(0);
  text("Players rendered: " + playersRendered, 20, 640);
  text("Number dead: " + pop.getNumberDead(), 20, 680);
  text("Framerate: " + frameRate, 20, 720);
  text("Frames: " + frameCount, 20, 760);
  text("Score of best: " + pop.players[0].level.score, 20, 800);
  
  if (pop.players[0].level.score >= 399) {
    won = true;
  }
  
  if (won) {
    text("Won!!", 20, 870);
  }
  
  if (playersRendered < 0) {
    playersRendered = 0;
  }
  else if (playersRendered > popSize) {
    playersRendered = popSize;
  }
}

void keyPressed() {
  switch(key) {
    case 'g':
      hideGraphs = toggle(hideGraphs);
      break;
    case '=':
      playersRendered++;
      break;
    case '-':
      playersRendered--;
      break;
    case 's':
      pop.saveBestPlayer();
      break;
    case 'l':
      pop.replaceAllNN("/data/nn.json");
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
