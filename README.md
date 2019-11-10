# SnakeAI
An AI that learns to play snake using a neural network and a genetic algorithm.

## SnakeAI
This is the main program that will train the snakes, display graphs of their progress, and load trained program files from SnakeTrainingStandalone. However, this should be used for visual purposes only; rendering graphs slows down training and Processing makes concurrent processing a pain.

Hyper-parameters can be easily changed in SnakeAI.pde.

It is coded in Processing (Java) and you will require the [Processing IDE](https://processing.org/download/) to open and run .pde files.
### Features include
Displaying the average and max score of each generation in graphical form and the neural network of the best snake:
![Image of average score graph and best neural network](https://github.com/jameshball/SnakeAI/blob/master/graphs.png)

Displaying a sample of current snakes (number of snakes shown can be changed by pressing + and - keys):
![Image of snakes](https://github.com/jameshball/SnakeAI/blob/master/snakes.png)

And also displaying helpful statistics about the snakes, such as the average score of the last generation, the number of dead snakes, the time since start, the generation number etc.

## SnakeHuman
This is essentially just Snake. It's human-playable and uses similar code to SnakeAI to control snakes. This was created before SnakeAI so I had a base-game to implement a genetic algorithm into.

## SnakeTrainingStandalone
As the name implies, this is a standalone version of SnakeAI that is used purely for training the snakes and generating files that can then be loaded into SnakeAI. It makes use of concurrent processing to train snakes far quicker than SnakeAI, but it only has a CLI. After each generation, the current program-state is saved to /data/program.json which can then be moved to SnakeAI/data/program.json and loaded into the SnakeAI program.
