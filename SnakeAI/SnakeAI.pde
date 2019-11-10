import java.util.Arrays;
import java.util.List;
import java.util.Comparator;
import java.util.Collections;
/* Access modifiers are by default 'public' in Processing.
   Variables declared in this class cannot be private and are therefore global variables. */
final int SNAKE = 1;
final int EMPTY = 0;
final int APPLE = -1;
/* These are explicitly defined because later prototypes will require a window that is bigger than
   these dimensions to render graphs. This is just the size of the snake's render area. */
int snakeWidth = 600;
int snakeHeight = 600;
int gridX = 20;
int gridY = 20;

int playersRendered = 0;
int gen = 0;
/* These are all hyper-parameters for the neural network and genetic algorithm. */
int populationSize = 500;
int[] networkStructure = new int[] { 24, 16, 4 };
float mutationRate = 0.02;

long start;

Population pop;
Graph maxScore;
Graph avgScore;

/* The setup method is initially run and is designed for executing any non-repeated code at the start of
   program execution. */
void setup() {
  /* The following defines the size of the window and the max framerate. */
  size(1920, 1080, FX2D);
  frameRate(10000);
  
  start = millis();
  
  pop = new Population();
  maxScore = new Graph("Generation", "Max. score", color(0));
  avgScore = new Graph("Generation", "Avg. score", color(255, 0, 0));
  /* Loads the last-run program from a file. */
  pop.load("/data/program.json");
}

/* The draw method is executed every frame. This is the main functionality of the program. */
void draw() {
  background(255);
  
  /* millis() - start is the number of milliseconds since the start of the program. */
  long seconds = (millis() - start) / 1000;
  long minutes = seconds / 60;
  long hours = minutes / 60;
  long days = hours / 24;
  /* Formats the above values into DD:HH:MM:SS. */
  String time = String.format("%02d:", days) + String.format("%02d:", hours%24) 
              + String.format("%02d:", minutes%60) + String.format("%02d", seconds%60);
  
  textSize(24);
  
  if (avgScore.size() > 1) {
    /* Checks to see if the avg. score from last generation is better than the generation before it. */
    if (avgScore.get(avgScore.size() - 2) < avgScore.get(avgScore.size() - 1)) {
      fill(0, 255, 0);
    }
    else {
      fill(255, 0, 0);
    }
    
    text("Avg fitness: " + avgScore.get(avgScore.size() - 1), 20, 640);
  }
  
  fill(0);
  text("Generation: " + gen, 20, 680);
  text("Number dead: " + pop.getNumberDead(), 20, 720);
  text("Score of best: " + pop.players[0].level.score, 20, 760);
  text("Framerate: " + frameRate, 20, 800);
  text("Players rendered: " + playersRendered, 20, 840);
  text("Time since start: " + time, 20, 880);
  
  pop.update();
  pop.show();
  
  /* Shows the neural network of the best player. */
  pop.players[0].nn.show(1430, 10, 470, 950, 10);
  
  maxScore.show(700, 50, 700, 350);
  avgScore.show(700, 550, 700, 350);
  
  /* Keep playersRendered in an appropriate range. */
  if (playersRendered < 0) {
    playersRendered = 0;
  }
  else if (playersRendered > populationSize) {
    playersRendered = populationSize;
  }
}

/* keyPressed is executed whenever a key is pressed. key stores the key pressed, allowing me to change
   the playersRendered variable when the + and - keys are pressed. */
void keyPressed() {
  switch(key) {
    case '=':
      playersRendered++;
      break;
    case '-':
      playersRendered--;
      break;
  }
}
