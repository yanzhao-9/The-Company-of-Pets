/*
Images and sound:
Import the Processing Sound library and declare variables for the room
backgrounds, person and cat poses, and the two surprise-ending images.
Declare the meow, footstep and opening-door sounds.
The files are loaded later in setup().
meowPlayed records whether the meow has played to prevent repeats.
*/
 
import processing.sound.*;

PImage roomClosed;
PImage roomOpen;

PImage personStand;
PImage personWalk;
PImage personKneel;
PImage personSit;

PImage catWalkLeft;
PImage catWalkRight;
PImage catSit;
PImage catLie;

PImage catWalkDirectly;
PImage catFace;

SoundFile meow;
SoundFile footstepSound;
SoundFile openDoorSound;
boolean meowPlayed = false;


/*
Animation states:
Give each stage a name and a fixed integer value using final int.
The state variable records the current stage, starting at WAITING_DOOR.
The program checks state to choose the images, movements and valid clicks,
and changes state when it is ready for the next stage.
*/

final int WAITING_DOOR = 0;
final int PERSON_AT_DOOR = 1;
final int PERSON_WALKING = 2;
final int WAITING_CAT = 3;
final int CAT_WALKING = 4;
final int WAITING_SOFA = 5;
final int PERSON_WALKING_TO_SOFA = 6;
final int CAT_WALKING_TO_SOFA = 7;
final int FINAL_SCENE = 8;
final int CAT_WALKING_TO_CAMERA = 9;
final int CAT_FACE_CLOSEUP = 10;

int state = WAITING_DOOR;


/*
Position, size and speed:
Set the displayed sizes, positions and movement speeds of the person and cat.
X controls horizontal position, while Y controls vertical position.
Increasing X moves right; increasing Y moves down.
W and H control the displayed width and height in pixels.
Starting and target positions determine where each movement begins and ends.
The final positions place the seated person and lying cat on the sofa.
personSpeed and catSpeed set the base movement speed in pixels per frame.
*/

float personW = 165;
float personH = 200;

float personX;
float personY;
float personSpeed = 2.5;

float personStartX = 40;
float personStartY = 135;

float personRoomX = 180;
float personRoomY = 210;

float personSofaWalkX = 510;
float personSofaWalkY = 160;

float finalPersonX = 510;
float finalPersonY = 150;

float catW = 90;
float catH = 72;

float catX;
float catY;
float catSpeed = 2.5;

float catStartX = 650;
float catStartY = 340;

float catNearPersonX = personRoomX + 110;
float catNearPersonY = catStartY;

float catSofaWalkX = 660;
float catSofaWalkY = catStartY;

float finalCatX = 620;
float finalCatY = 220;
float finalCatW = 115;
float finalCatH = 85;


/*
Surprise timing:
surpriseProgress records the cat's approach from 0 (start) to 1 (finish).
surpriseSpeed sets how much progress is added each frame.
A larger surpriseSpeed makes the approach finish sooner.
*/

float surpriseProgress = 0;
float surpriseSpeed = 0.008;


/*
Setup and asset loading:
Run once when the sketch starts.
Create an 800 x 500 window and turn off smoothing for the pixel-art style.
Position images using their top-left corner with imageMode(CORNER).
Load the background images, character poses and three sounds from data.
Set the volumes for the footsteps and opening-door sound.
Call resetAnimation() to prepare the starting stage and character positions.
*/

void setup() {
  size(800, 500);
  noSmooth();
  imageMode(CORNER);

  roomClosed = loadImage("room_closed.png");
  roomOpen = loadImage("room_open.png");

  personStand = loadImage("person_stand.png");
  personWalk = loadImage("person_walk.png");
  personKneel = loadImage("person_kneel.png");
  personSit = loadImage("person_sit.png");

  catWalkLeft = loadImage("cat_walk_left.png");
  catWalkRight = loadImage("cat_walk_right.png");
  catSit = loadImage("cat_sit.png");
  catLie = loadImage("cat_lie.png");

  catWalkDirectly = loadImage("cat_walk_directly.png");
  catFace = loadImage("cat_face.png");

  meow = new SoundFile(this, "meow.wav");

  footstepSound = new SoundFile(this, "footstep_sound.wav");
  openDoorSound = new SoundFile(this, "opendoor_sound.wav");
  footstepSound.amp(0.45);
  openDoorSound.amp(0.65);

  resetAnimation();
}


/*
Drawing and animation updates:
Run repeatedly to update and display the animation.
Check state and call the movement function needed for the current stage.
Show the closed-door background at the start and the open room afterwards.
Use switch(state) to display the character poses and prompts for each stage.
The cat waits while the person walks to the sofa, then follows
once the person is seated.
When state is CAT_FACE_CLOSEUP, display the full-screen cat face.
Use return to skip drawing the room and characters for that frame.
*/

void draw() {
  if (state == PERSON_WALKING) {
    movePersonIntoRoom();

  } else if (state == CAT_WALKING) {
    moveCatToPerson();

  } else if (state == PERSON_WALKING_TO_SOFA) {
    movePersonToSofa();

  } else if (state == CAT_WALKING_TO_SOFA) {
    moveCatToSofa();

  } else if (state == CAT_WALKING_TO_CAMERA) {
    updateSurprise();
  }

  if (state == CAT_FACE_CLOSEUP) {
    drawCatFace();
    return;
  }

  if (state == WAITING_DOOR) {
    image(roomClosed, 0, 0, width, height);
  } else {
    image(roomOpen, 0, 0, width, height);
  }

  switch (state) {

  case WAITING_DOOR:
    image(catSit, catX, catY, catW, catH);
    drawPrompt("Click the door");
    break;

  case PERSON_AT_DOOR:
    image(catSit, catX, catY, catW, catH);
    image(personStand, personX, personY, personW, personH);
    drawPrompt("Click the person");
    break;

  case PERSON_WALKING:
    image(catSit, catX, catY, catW, catH);
    image(personWalk, personX, personY, personW, personH);
    break;

  case WAITING_CAT:
    image(catSit, catX, catY, catW, catH);
    drawKneelingPerson();
    drawPrompt("Click the cat");
    break;

  case CAT_WALKING:
    image(catWalkLeft, catX, catY, catW, catH);
    drawKneelingPerson();
    break;

  case WAITING_SOFA:
    image(catSit, catX, catY, catW, catH);
    drawKneelingPerson();
    drawPrompt("Click the sofa");
    break;

  case PERSON_WALKING_TO_SOFA:
    image(catSit, catX, catY, catW, catH);

    if (personY != personSofaWalkY) {
      image(personStand, personX, personY, personW, personH);
    } else {
      image(personWalk, personX, personY, personW, personH);
    }
    break;

  case CAT_WALKING_TO_SOFA:
    drawSeatedPerson();
    image(catWalkRight, catX, catY, catW, catH);
    break;

  case FINAL_SCENE:
    drawSeatedPerson();
    image(catLie, finalCatX, finalCatY, finalCatW, finalCatH);
    drawPrompt("Click the cat for a surprise!");
    break;

  case CAT_WALKING_TO_CAMERA:
    drawSeatedPerson();
    drawCatApproach();
    break;
  }
}


/*
Mouse interaction:
Check the current state and use insideRectangle() to detect
whether the viewer clicked the correct object.
Change state to trigger the next action.
Play the door sound when the door opens.
Start the footstep loop when the person begins walking into
the room or towards the sofa.
Before starting the surprise, check that both ending images are loaded.
Then reset surpriseProgress to 0 and switch to CAT_WALKING_TO_CAMERA.
*/

void mousePressed() {
  if (
    state == WAITING_DOOR &&
    insideRectangle(mouseX, mouseY, 20, 45, 170, 280)
  ) {
    openDoorSound.play();
    state = PERSON_AT_DOOR;

  } else if (
    state == PERSON_AT_DOOR &&
    insideRectangle(
      mouseX, mouseY,
      personX, personY,
      personW, personH
    )
  ) {
    state = PERSON_WALKING;
    footstepSound.loop();

  } else if (
    state == WAITING_CAT &&
    insideRectangle(
      mouseX, mouseY,
      catX, catY,
      catW, catH
    )
  ) {
    state = CAT_WALKING;

  } else if (
    state == WAITING_SOFA &&
    insideRectangle(mouseX, mouseY, 460, 170, 340, 180)
  ) {
    state = PERSON_WALKING_TO_SOFA;
    footstepSound.loop();

  } else if (
    state == FINAL_SCENE &&
    insideRectangle(
      mouseX, mouseY,
      finalCatX, finalCatY,
      finalCatW, finalCatH
    )
  ) {
    if (catWalkDirectly == null || catFace == null) {
      println("Check cat_walk_directly.png and cat_face.png in data.");
      return;
    }

    surpriseProgress = 0;
    state = CAT_WALKING_TO_CAMERA;
  }
}


/*
Character movement:
These four functions update positions when called from draw().
Use moveTowards() to move coordinates to their targets without overshooting.
The person enters the room and waits for the viewer to click the cat.
The cat moves left towards the person and meows once shortly before arrival.
meowPlayed prevents the meow from restarting in later frames.
To reach the sofa, the person first changes Y, then moves right along X.
Stop the footsteps when the person reaches either destination.
The cat follows after the person is seated.
Change state on arrival to continue the sequence or wait for a click.
*/

void movePersonIntoRoom() {
  personX = moveTowards(personX, personRoomX, personSpeed);
  personY = moveTowards(personY, personRoomY, personSpeed * 0.5);

  if (personX == personRoomX && personY == personRoomY) {
    footstepSound.stop();
    state = WAITING_CAT;
  }
}

void moveCatToPerson() {
  catX = moveTowards(catX, catNearPersonX, catSpeed);
  catY = catNearPersonY;

  if (catX <= catNearPersonX + 40 && !meowPlayed) {
    meow.play();
    meowPlayed = true;
  }

  if (catX == catNearPersonX) {
    state = WAITING_SOFA;
  }
}

void movePersonToSofa() {
  if (personY != personSofaWalkY) {
    personY = moveTowards(
      personY,
      personSofaWalkY,
      personSpeed
    );
    return;
  }

  personX = moveTowards(
    personX,
    personSofaWalkX,
    personSpeed
  );

  if (personX == personSofaWalkX) {
    footstepSound.stop();
    state = CAT_WALKING_TO_SOFA;
  }
}

void moveCatToSofa() {
  catX = moveTowards(catX, catSofaWalkX, catSpeed);
  catY = catSofaWalkY;

  if (catX == catSofaWalkX) {
    state = FINAL_SCENE;
  }
}


/*
Character poses:
Display the kneeling person with a small offset from personX and personY.
Display the seated person at finalPersonX and finalPersonY.
Both poses use personW and personH for their displayed size.
*/

void drawKneelingPerson() {
  image(
    personKneel,
    personX - 5, personY + 5,
    personW, personH
  );
}

void drawSeatedPerson() {
  image(
    personSit,
    finalPersonX, finalPersonY,
    personW, personH
  );
}


/*
Surprise ending:
Increase surpriseProgress each frame and switch to the cat face at 1.
For the approach, keep the walking cat's width fixed and preserve its proportions.
Use bezierPoint() with two overlapping control points to calculate a curved path
from the sofa towards the centre foreground.
centreX and bottomY locate the image by its horizontal centre and bottom edge.
For the close-up, use the larger window-to-image scale ratio to fill the window.
Centre the face and preserve its proportions; any excess lies outside the window.
*/

void updateSurprise() {
  surpriseProgress = min(1, surpriseProgress + surpriseSpeed);

  if (surpriseProgress >= 1) {
    state = CAT_FACE_CLOSEUP;
  }
}

void drawCatApproach() {
 
  float displayW = finalCatW;
  float displayH = displayW *
    catWalkDirectly.height / (float) catWalkDirectly.width;

  float startX = finalCatX + finalCatW * 0.5;
  float startY = finalCatY + finalCatH;

  float controlX = width * 0.72;
  float controlY = height * 0.78;

  float endX = width * 0.5;
  float endY = height - 40;

  float t = surpriseProgress;

  float centreX = bezierPoint(
    startX, controlX, controlX, endX, t
  );

  float bottomY = bezierPoint(
    startY, controlY, controlY, endY, t
  );

  image(
    catWalkDirectly,
    centreX - displayW * 0.5,
    bottomY - displayH,
    displayW,
    displayH
  );
}

void drawCatFace() {
  background(255, 245, 230);

  float faceScale = max(
    width / (float) catFace.width,
    height / (float) catFace.height
  );

  float displayW = catFace.width * faceScale;
  float displayH = catFace.height * faceScale;

  image(
    catFace,
    (width - displayW) * 0.5,
    (height - displayH) * 0.5,
    displayW,
    displayH
   );

  // Show the restart instruction on top of the cat image.
  // keyPressed() handles R/r and calls resetAnimation().
  drawPrompt("Press R to restart");
}


/*
Movement helper:
Move a coordinate towards its target by movementAmount on each call.
Use min() or max() to stop exactly at the target without passing it.
Return the target unchanged when the coordinate has already arrived.
*/

float moveTowards(
  float currentValue,
  float targetValue,
  float movementAmount
) {
  if (currentValue < targetValue) {
    return min(currentValue + movementAmount, targetValue);
  }

  if (currentValue > targetValue) {
    return max(currentValue - movementAmount, targetValue);
  }

  return targetValue;
}


/*
Click-area helper:
Return true when a point is inside the rectangle, including its edges.
Compare the point with the rectangle's left, right, top and bottom edges.
mousePressed() uses this function to check clicks on scene objects.
*/

boolean insideRectangle(
  float pointX,
  float pointY,
  float rectangleX,
  float rectangleY,
  float rectangleW,
  float rectangleH
) {
  return
    pointX >= rectangleX &&
    pointX <= rectangleX + rectangleW &&
    pointY >= rectangleY &&
    pointY <= rectangleY + rectangleH;
}


/*
On-screen prompts:
Draw a rounded white box near the top of the window.
Display the supplied message as centred dark text to guide the next click.
*/

void drawPrompt(String message) {
  rectMode(CORNER);
  noStroke();

  fill(255, 245);
  rect(245, 18, 310, 44, 8);

  fill(55);
  textAlign(CENTER, CENTER);
  textSize(18);
  text(message, 400, 40);
}


/*
Reset and keyboard control:
Stop all three sounds and clear meowPlayed and surpriseProgress.
Restore WAITING_DOOR and the starting positions of the person and cat.
keyPressed() calls resetAnimation() when R or r is pressed,
allowing the viewer to restart from any stage.
*/

void resetAnimation() {
  meow.stop();
  footstepSound.stop();
  openDoorSound.stop();
  meowPlayed = false;
  surpriseProgress = 0;

  state = WAITING_DOOR;

  personX = personStartX;
  personY = personStartY;

  catX = catStartX;
  catY = catStartY;
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    resetAnimation();
  }
}
