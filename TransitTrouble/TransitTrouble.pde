/*************************************
 * Transit Trouble by XYZ Affair 
 *************************************/
//NOTE: SCREEN RATIO 3:2
import java.util.ArrayDeque;
import java.util.HashSet;

ArrayList<Station> _stations = new ArrayList<Station>(); // List of active Stations
ArrayList<TrainLine> _trainlines = new ArrayList<TrainLine>(); // List of active Trainlines

ArrayDeque<Draggable> _selected = new ArrayDeque<Draggable>();
HashSet<Draggable> _hashed = new HashSet<Draggable>();
// ArrayDeque<Station> _selectedStations = new ArrayDeque<Station>();
// HashSet<Station> _hashedStations = new HashSet<Station>();
boolean _mousePressed = false; // Whether mouse has been pressed. 
boolean _mouseReleased = false;
boolean _lock; // Used if initial click didn't find anything.

// Game Map - GUI
Map map = new Map();

// =====================================
//safer to have boolean locks than to check if station is null...
boolean lockedActive = false;
boolean lockedTarget = false;
ArrayList<Draggable> activeDrags = null;
ArrayList<Station> activeStations = null;
TrainLine activeTrainLine; // Trainline first pressed
Station targetStation = null;

Train testTrain;

void setup() {
  smooth(4);
  strokeWeight(8);
  background(255, 255, 255); // White - Subject to Change
  size(900, 600); // Default Size - Subject to Change

  activeDrags = new ArrayList<Draggable>();
  activeStations = new ArrayList<Station>();
  activeTrainLine = null;
  // ==================================================
  // Debugging
  for (int i = 0; i < 1; i++) {
    genStation();
    //genStation();
  }
  _trainlines.add(new TrainLine(_stations.get(0)));
  genStation();
  _trainlines.get(0).addTerminal(_stations.get(0), _stations.get(1));

  /*
  _trainlines.get(0).connect( _stations.get(0), _stations.get(1) );
   _trainlines.get(0).addTerminal( _stations.get(0), _stations.get(1) );
   _trainlines.get(0).update();
   */
  //Connector c = new Connector(_stations.get(0), _stations.get(1));


  testTrain = new Train((Connector)_trainlines.get(0)._stationEnds.get(1).getA());

  /*
  for (Station s : _stations) {
   _trainlines.get(0).addStation(s);
   } 
   */
  // ==================================================
}

void draw() {
  background(255, 255, 255);

  map.debug(); //Debugging - Maps red dots to each grid coordinate
  ellipse(mouseX, mouseY, 60, 60); // Debugging

  for (TrainLine tl : _trainlines) {
    tl.update();
  }
  for (Station s : _stations) {
    s.update();
    textSize(16); // Debugging
    fill(0); // Debugging
    text(_stations.indexOf(s), s.getX(), s.getY()); // Debugging
  }
  testTrain.update(); // Debugging
  updateDrag(); // Dragging Mechanism
}

/*
 Deque<Draggable> _selected = null;
 HashSet<Draggable> _hashed = new HashSet<Draggable>();
 boolean _mousePressed = false; // Whether mouse has been pressed. 
 boolean _mouseReleased = false;
 boolean _lock = false;
 */


void updateDrag() {
  if (mousePressed) { // Mouse is being pressed.

    // CASE 1: Mouse was pressed before, and being held down now.  
    if (_mousePressed) 
    {
      if (_lock)
        println("MOUSE STATE: LOCKED"); // Debugging
      if (mouseListen())
        println("ADDED! " + _hashed.size()); // Debugging
    } // END CASE 1

    // CASE 2: Mouse was not previous pressed, and was just clicked.
    else 
    {
      if (mouseListen()) // Track what was just clicked.
        println("ADDED! " + _hashed.size()); // Debugging
      else
        _lock = true; // If nothing was clicked, lock the Deque.
    } // END CASE 2
  } else { // Mouse is not being pressed.
    executeSelected(); // Execute selected items.
    _lock = false; // Unlock the mouse.
    _hashed.clear(); // Clear the hashset.
    _selected.clear(); // Clear the deque of selected items.
  } // END CASE 3
}

void executeSelected() {
  Draggable firstClick = _selected.poll();
  Station release = null; // Station where it was released.
  for (Station s : _stations) {
    if (s.isNear()) {
      release = s;
      break;
    }
  }
  // println("STATION: " + release); // Debugging
  if (release == null) {
    ; // Nothing
  } else {
    // If Terminal
    if (firstClick instanceof Terminal) {
      Terminal tmp = (Terminal)firstClick;
      if (tmp.getStation() != release) { // Doesn't loop into itself
        tmp.getTrainLine().addTerminal(tmp.getStation(), release);
        println("EXECUTE: JOIN!"); // Debugging
      }
    }
    
    // If Connector
    if (firstClick instanceof Connector) {
      Connector tmp = (Connector)firstClick;
      tmp.getTrainLine().addStation(tmp.getStart(),
                                    tmp.getEnd(),
                                    release,
                                    tmp);
      println("EXECUTE: CRY!"); // Debugging
    }

    println("EXECUTED"); // Debugging
  }
}

boolean mouseListen() {
  for (TrainLine tl : _trainlines) { // Looks through all the TrainLines
    // Procedure: Check Draggable
    //            Try hashing if near mouse
    //            If hash success, add it to list of selected
    //            Otherwise, keep checking

    // Terminals
    for (Terminal t : tl.getTerminals()) {
      if (t.isNear())
        if (_hashed.add(t)) {
          _selected.add(t); 
          return true;
        }
    }

    // Pairs -- Connectors
    for (Pair p : tl.getStationEnds()) {
      Draggable A = p.getA();
      Draggable B = p.getB();
      if (A != null && A.isNear())
        if (_hashed.add(A)) {
          _selected.add(A);
          return true;
        }
      if (B != null && B.isNear())
        if (_hashed.add(B)) {
          _selected.add(B);
          return true;
        }
    }
  }
  return false; // Nothing Detected
}

// ==================================================
// Helper Methods
// ==================================================
void keyPressed() {
  println("LMAO");
  genStation();
  // _trainlines.get(0).addTerminal(_trainlines.get(0).getStation(0), _stations.get(_stations.size() - 1)); // Debugging
}

void mousePressed() {
  _mousePressed = true;
  println("MOUSE STATE : PRESSED"); // Debugging
}

void mouseReleased() {
  _mousePressed = false;
  println("MOUSE STATE : UNPRESSED"); // Debugging
}

void genStation() {
  ///1s for padding...
  int pad = 2;
  int newStationX = pad + map.minX + int(random(map.maxX - map.minX - 2 * pad));
  int newStationY = pad + map.minY + int(random(map.maxY - map.minY - 2 * pad));
  int ctr = 0;
  while (map.slots[newStationX][newStationY]) {
    if (ctr == 1000) {
      grow();
    }
    newStationX = pad + map.minX + int(random(map.maxX - map.minX - 2 * pad));
    newStationY = pad + map.minY + int(random(map.maxY - map.minY - 2 * pad));
    ctr++;
  }
  _stations.add(new Station(map.transform(newStationX, newStationY)));
  // print(_stations.get(_stations.size() - 1)._x + " " + _stations.get(_stations.size() - 1)._y + "\n");
  // voids station and everything immediately next to it as spots for future stations...
  for (int i = newStationX - 2; i < newStationX + 3; i++) {
    for (int j = newStationY - 2; j < newStationY + 3; j++) {
      map.slots[i][j] = true;
    }
  }

  if ((map.maxX - map.minX) * (map.maxY - map.minY) / _stations.size()  < 20) {
    grow();
  }
}

void grow() {
  map.grow();    
  for (Station s : _stations) {
    s.recalc(map.transform(s.getGridX(), s.getGridY()));
  }
  for (TrainLine tl : _trainlines) {
    tl.recalc();
  }
}