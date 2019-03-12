class Graph {
  int posx;
  int posy;
  int graphWidth;
  int graphHeight;
  int weight;
  String xlabel;
  String ylabel;
  ArrayList<Datapoint>[] data;
  color[] colors;
  float lineWidth;
  float valueRange;
  float lineHeight;
  int scaleCount;
  int widthShowingRate;
  int heightShowingRate;
  float max;
  float min;
  
  Graph (int inputx, int inputy, String inputxlabel, String inputylabel, int inputWidth, int inputHeight, int inputWeight, int lineNo) {
    posx = inputx;
    posy = inputy;
    graphWidth = inputWidth;
    graphHeight = inputHeight;
    weight = inputWeight;
    xlabel = inputxlabel;
    ylabel = inputylabel;
    data = (ArrayList<Datapoint>[]) new ArrayList<?>[lineNo];
    for (int i = 0; i < lineNo; i++) {
      data[i] = new ArrayList<Datapoint>();
    }
    colors = new color[lineNo];
  }
  
  Graph (int inputx, int inputy, String inputxlabel, String inputylabel, int inputWidth, int inputHeight, int inputWeight, int[] c) {
    posx = inputx;
    posy = inputy;
    graphWidth = inputWidth;
    graphHeight = inputHeight;
    weight = inputWeight;
    xlabel = inputxlabel;
    ylabel = inputylabel;
    data = (ArrayList<Datapoint>[]) new ArrayList<?>[1];
    data[0] = new ArrayList<Datapoint>();
    colors = new color[] { color(c[0], c[1], c[2]) };
  }
  
  void addData(int graphIndex, Datapoint point) {
    data[graphIndex].add(point);
  }
  
  void addData(Datapoint point) {
    data[0].add(point);
  }
  
  int size(int graphIndex) {
    return data[graphIndex].size();
  }
  
  int size() {
    return data[0].size();
  }
  
  Datapoint get(int graphIndex, int dataIndex) {
    return data[graphIndex].get(dataIndex);
  }
  
  Datapoint get(int dataIndex) {
    return data[0].get(dataIndex);
  }
  
  void setColor (int graphIndex, color c) {
    colors[graphIndex] = c;
  }
  
  void setColor (color c) {
    colors[0] = c;
  }
  
  void show() {
    ArrayList<Datapoint>[] tData = clone(data);
    
    if (size() > 1) {
      lineWidth = (float)graphWidth/(size()-1);
      min = getMin(tData);
      max = getMax(tData);
      valueRange = max - min;
      lineHeight = 0.0;
      
      scaleCount = 1;
      
      while (valueRange < 1 && valueRange != 0.0) {
        int scaleAmount = 10;
        
        tData = scale(tData, scaleAmount);
        scaleCount *= scaleAmount;
        
        min = getMin(tData);
        max = getMax(tData);
        valueRange = max - min;
      }
      
      if (valueRange != 0) {
        lineHeight = ((float)graphHeight / valueRange);
      }
      
      widthShowingRate = showingRate(size(), graphWidth, false) + 1;
      heightShowingRate = showingRate(valueRange + 1, graphHeight, true);
      strokeWeight(weight);
      smooth();
      
      
      textSize(18);
      fill(0);
      
      text(xlabel, posx + 10 - textWidth(xlabel) / 2 + graphWidth / 2, posy + graphHeight + 50);
      
      String newylabel = ylabel;
      
      if (scaleCount != 1) {
        newylabel = ylabel + " (coded x" + scaleCount + ")";
      }
      
      int x = posx - 70;
      int y = posy - (int)textWidth(newylabel) / 2 + graphHeight / 2;
      
      pushMatrix();
      translate(x,y);
      rotate(HALF_PI);
      translate(-x,-y);
      text(newylabel, x,y);
      popMatrix();
      
      if ((int)tData[0].get(size() - 1).data == tData[0].get(size() - 1).data) {
        if (heightShowingRate == 0) {
          for (int i = 0; i < valueRange + 1; i++) {
            text((int)(min + i), posx - 40, posy + graphHeight - i*lineHeight + 5);
          }
        }
        else {
          for (int i = 0; i < valueRange + 1; i += heightShowingRate) {
            text((int)(min + i), posx - 40, posy + graphHeight - i*lineHeight + 5);
          }
        }
      }
      else {
        if (heightShowingRate == 0) {
          for (float i = 0; i < valueRange + 0.2; i = i + 0.2) {
            i = Precision.round(i, 2);
            text(min + i, posx - 48, posy + graphHeight - i*lineHeight + 5);
          }
        }
        else {
          for (float i = 0; i < valueRange + 0.2; i += heightShowingRate) {
            text(min + i, posx - 48, posy + graphHeight - i*lineHeight + 5);
          }
        }
      }
        
      for (int i = 0; i < tData.length; i++) {
        stroke(colors[i]);
        for (int j = 0; j < tData[i].size() - 1; j++) {
          if (!tData[i].get(j).isEmpty) {
            float value1 = tData[i].get(j).data - min;
            float value2 = tData[i].get(j + 1).data - min;
            
            line(j*lineWidth + posx + 10, posy + graphHeight - (lineHeight * value1), (j+1)*lineWidth + posx + 10, posy + graphHeight - (lineHeight * value2));
          }
        }
      }
      
      if (widthShowingRate == 0) {
        for (int i = 0; i < tData[0].size(); i++) {
          String text = Integer.toString((int)(gen - tData[0].size() + i));
          text(text, i*lineWidth + posx + 10 - textWidth(text) / 2, posy + graphHeight + 25);
        }
      }
      else {
        for (int i = 0; i < tData[0].size(); i += widthShowingRate) {
          String text = Integer.toString((int)(gen - tData[0].size() + i));
          text(text, i*lineWidth + posx + 10 - textWidth(text) / 2, posy + graphHeight + 20);
        }
      }
      
      strokeWeight(1);
    }
  }
  
  Float getMax(ArrayList<Datapoint>[] list) {
    Datapoint max = new Datapoint(true);
    
    for (int i = 0; i < list.length; i++) {
      for (int j = 0; j < list[i].size(); j++) {
        if (!list[i].get(j).isEmpty) {
          if (max.isEmpty) {
            max.data = list[i].get(j).data;
            max.isEmpty = false;
          }
          else if (list[i].get(j).data > max.data) {
            max.data = list[i].get(j).data;
          }
        }
      }
    }
    
    return max.data;
  }
  
  Float getMin(ArrayList<Datapoint>[] list) {
    Datapoint min = new Datapoint(true);
    
    for (int i = 0; i < list.length; i++) {
      for (int j = 0; j < list[i].size(); j++) {
        if (!list[i].get(j).isEmpty) {
          if (min.isEmpty) {
            min.data = list[i].get(j).data;
            min.isEmpty = false;
          }
          else if (list[i].get(j).data < min.data) {
            min.data = list[i].get(j).data;
          }
        }
      }
    }
    
    return min.data;
  }

  
  int showingRate(float val, int dimension, boolean isVertical) {
    float rate;
    
    if (isVertical) {
      rate = dimension / 30;
    }
    else {
      rate = dimension / 20;
    }
    
    return (int)Math.pow(2, (Math.log(val/rate)/Math.log(2)) + 1);
  }
  
  ArrayList<Datapoint>[] scale (ArrayList<Datapoint>[] data, int scale) {
    for (int i = 0; i < data.length; i++) {
      ArrayList<Datapoint> scaledList = new ArrayList<Datapoint>();
      
      for (int j = 0; j < data[i].size(); j++) {
        scaledList.add(new Datapoint(data[i].get(j).data * scale, false));
      }
      
      data[i] =  scaledList;
    }
    
    return data;
  }
  
  ArrayList<Datapoint>[] clone (ArrayList<Datapoint>[] arr) {
    ArrayList<Datapoint>[] clonedArr = (ArrayList<Datapoint>[]) new ArrayList<?>[arr.length];
    
    for (int i = 0; i < arr.length; i++) {
      ArrayList<Datapoint> list = new ArrayList<Datapoint>();
      
      for (int j = 0; j < arr[i].size(); j++) {
        list.add(new Datapoint(arr[i].get(j).data, false));
      }
      
      clonedArr[i] = list;
    }
    
    return clonedArr;
  }
}
