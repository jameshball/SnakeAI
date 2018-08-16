import java.util.*;

int snakeWidth = 400;
int snakeHeight = 400;
int playersRendered = 10;
int gen = 0;
boolean hideGraphs = false;
boolean hideVision = false;
boolean lowerFramerate = false;
int popSize = 500;
Population pop;

Level level = new Level(20, 20);

void setup() {
  size(1700, 800, P2D);
  frameRate(1000);
  
  pop = new Population(popSize, new int[] { 24, 16, 4 });
  pop.maxFitnessGraph = new Graph(500, 50, "Generation", "Max. Fitness" , 670, 275, 4, new int[] { 0, 0, 0 });
  pop.avgFitnessGraph = new Graph(500, 450, "Generation", "Avg. Fitness" , 670, 275, 4, new int[] { 255, 0, 0 });
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
    pop.nnGraph.show(1200, 0);
  }
  
  textSize(20);
  
  if (pop.avgFitnessGraph.size() > 0) {
    if (pop.avgFitnessGraph.size() > 1 && pop.avgFitnessGraph.get(pop.avgFitnessGraph.size() - 2).data < pop.avgFitnessGraph.get(pop.avgFitnessGraph.size() - 1).data) {
      fill(0, 255, 0);
    }
    else {
      fill(255, 0, 0);
    }
    text("Avg fitness: " + pop.avgFitnessGraph.get(pop.avgFitnessGraph.size() - 1).data, 550, 20);
  }
  
  fill(0);
  text("Framerate: " + frameRate, 180, 420);
  text("Frames: " + frameCount, 180, 450);
  text("No. dead: " + pop.getNumberDead(), 20, 420);
  text("Plrs rndrd: " + playersRendered, 20, 450);
  
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
