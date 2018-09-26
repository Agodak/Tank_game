final int PLAYER_WIDTH_PROPORTION = 20;
final int PLAYER_HEIGHT_PROPORTION = 20;
final int PLAYER_INIT_X_PROPORTION = 10;
final int PLAYER_INCREMENT_PROPORTION = 50;
final int PROJECTILE_RADIUS_PROPORTION = 50;

Player player1, player2;
Particle projectile;
int xStart, yStart, xEnd, yEnd;
UserForce userForce;
Gravity gravity;
ForceRegistry forceRegistry;
boolean movingLeft = false, movingRight = false, turn = true, visible = false;

void setup()
{
  fullScreen();
  int playerWidth = displayWidth/PLAYER_WIDTH_PROPORTION;
  int playerHeight = displayHeight/PLAYER_HEIGHT_PROPORTION;
  int playerInitX = displayWidth/PLAYER_INIT_X_PROPORTION - playerWidth/2;
  int playerInitY = displayHeight - playerHeight;
  int playerIncrement = displayWidth/PLAYER_INCREMENT_PROPORTION;
  player1 = new Player(playerInitX, playerInitY, playerWidth, playerHeight, playerIncrement);
  player2 = new Player(displayWidth - playerInitX, playerInitY, playerWidth, playerHeight, playerIncrement);
  gravity = new Gravity(new PVector(0f, .1f));
  userForce = new UserForce(new PVector(0f, 0f));
  forceRegistry = new ForceRegistry();
  projectile = new Particle(0, 0, 0f, 0f, 0.02f);
  //forceRegistry.add(projectile, gravity);
  //forceRegistry.add(projectile, userForce);
}

void draw()
{
  background(211, 211, 211);
  if(movingLeft)
    if(turn)
      player1.moveLeft();
    else
      player2.moveLeft();
  else
    if(movingRight)
      if(turn)
        player1.moveRight();
      else
        player2.moveRight();
  player1.draw();
  player2.draw();
  forceRegistry.updateForces();
  projectile.integrate();
  PVector position = projectile.position;
  if(position.x < 0 || position.x > displayWidth || position.y > displayHeight)
  {
    visible = false;
    forceRegistry.clear();
  }
  
  int radius = displayWidth/PROJECTILE_RADIUS_PROPORTION;
  fill(255);
  if(visible)
    ellipse(position.x, position.y, radius, radius);
  userForce.set(0f, 0f);
}

void keyPressed()
{
  if(key == CODED)
    switch(keyCode)
    {
      case LEFT:
        movingLeft = true;
        break;
      case RIGHT:
        movingRight = true;
        break;
    }
}

void keyReleased()
{
  if(key == CODED);
    switch(keyCode)
    {
      case LEFT:
        movingLeft = false;
        break;
      case RIGHT:
        movingRight = false;
        break;
    }
}

void mousePressed()
{
  if(turn)
  {
    xStart = player1.getX();
    yStart = player1.getY();
    projectile = new Particle(xStart, yStart, 0f, 0f, 0.015f);
  }
  else
  {
    xStart = player2.getX();
    yStart = player2.getY();
    projectile = new Particle(xStart, yStart, 0f, 0f, 0.015f);
  }
  xEnd = mouseX;
  yEnd = mouseY;
  userForce.set(xEnd - xStart, yEnd - yStart);
  forceRegistry.add(projectile, gravity);
  forceRegistry.add(projectile, userForce);
  visible = true;
  turn = !turn;
}
