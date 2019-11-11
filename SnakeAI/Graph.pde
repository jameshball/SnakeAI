/* The Graph class contains all graph-plotting and handling attributes and methods. */
class Graph {
  /* x-axis and y-axis labels. */
  private String xLabel;
  private String yLabel;
  
  private ArrayList<Float> data;
  private color lineColor;
  
  Graph (String xLabel, String yLabel, color lineColor) {
    this.xLabel = xLabel;
    this.yLabel = yLabel;
    this.lineColor = lineColor;
    
    data = new ArrayList<Float>();
  }
  
  /* Used to add data to the graph. */
  void add(float f) {
    data.add(f);
  }
  
  /* Returns the graph size. */
  int size() {
    return data.size();
  }
  
  /* Helpful method for returning data at a specific index. */
  float get(int index) {
    return data.get(index);
  }
  
  /* Returns the max value in the data list. */
  float max() {
    float max = Float.MIN_VALUE;
    
    for (int i = 0; i < data.size(); i++) {
      if (max < data.get(i)) {
        max = data.get(i);
      }
    }
    
    return max;
  }
  
  /* Returns the min value in the data list. */
  float min() {
    float min = Float.MAX_VALUE;
    
    for (int i = 0; i < data.size(); i++) {
      if (data.get(i) < min) {
        min = data.get(i);
      }
    }
    
    return min;
  }
  
  /* Displays the graph at the specified coordinates with the specified width and height. */
  void show(int graphX, int graphY, int graphWidth, int graphHeight) {
    /* Only show when there is enough data to plot. */
    if (size() > 1) {
      textSize(18);
      
      float min = min();
      float max = max();
      float valueRange = max - min;
      
      if (valueRange == 0) {
        /* valueRange cannot be 0, so if it is, make it an arbitrarily small number. */
        valueRange = 0.000000001;
      }
      
      fill(0);
      
      /* Draws xLabel. */
      text(xLabel, graphX + 10 - textWidth(xLabel) / 2 + graphWidth / 2, graphY + graphHeight + 50);
      
      /* Draws yLabel vertically on the side of the graph. */
      pushMatrix();
      /* Takes into account the length of the label so that it is centred in the y-axis. */
      translate(graphX - 60, graphY + (int) textWidth(yLabel) / 2 + graphHeight / 2);
      rotate(-HALF_PI);
      text(yLabel, 0, 0);
      popMatrix();
      
      /* textHeight determines the height between each value on the y-axis. */
      float textHeight = textAscent() * 2;
      /* Determines the number of labels on the y-axis. */
      float numberOfYLabels = graphHeight / textHeight;
      /* Determines the gap between y-axis labels. */
      float verticalIncrement = valueRange / numberOfYLabels;
      
      for (int i = 0; i < numberOfYLabels; i++) {
        /* Draws text showing the y-axis label at the height specified.
           -48 and 5 are arbitrary values that correctly align the text. */
        text(min + i * verticalIncrement, graphX - 48, graphY + graphHeight - i * textHeight + 5);
      }
      
      /* This calculates the increment in the x-axis labels for there to be no label overlap.
         20 is an arbitrary value that helps format the text correctly. */
      int horizontalIncrement = 1 + (int) ((textWidth(Integer.toString(gen)) + 20) * gen) / graphWidth;
      /* textWidth determines the width between each value on the x-axis. */
      float textWidth = (float) graphWidth / (size() - 1);
      
      /* Draw the label at every multiple of the increment. */
      for (int i = 0; i < size(); i += horizontalIncrement) {
        /* 10 and 25 are arbitrary values that help format the text correctly. */
        text(i, i * textWidth + graphX + 10 - textWidth(Integer.toString(i)) / 2, graphY + graphHeight + 25);
      }
      
      stroke(lineColor);
      strokeWeight(4);
      
      /* Draws line graph. */
      for (int i = 0; i < size() - 1; i++) {
        /* Defines the relative y coordinates of the line. */
        float y1 = ((data.get(i) - min) * textHeight) / verticalIncrement;
        float y2 = ((data.get(i + 1) - min) * textHeight) / verticalIncrement;
        
        /* Defines the x position of where the line is drawn from. The value 10 acts as padding. */
        float xPos = i * textWidth + graphX + 10;
        
        /* Draws the line. */
        line(xPos, graphY + graphHeight - y1, xPos + textWidth, graphY + graphHeight - y2);
      }
    }
  }
}
