final int PLAYER_WIDTH_PROPORTION = 20;
final int PLAYER_HEIGHT_PROPORTION = 20;
final int PLAYER_INIT_X_PROPORTION = 10;
final int PLAYER_INCREMENT_PROPORTION = 50;
final int PROJECTILE_RADIUS_PROPORTION = 50;


Player player1, player2;
Projectile projectile;
PVector gravity;
boolean movingLeft = false, movingRight = false, turn = true;

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
  gravity = new PVector(0f, 0f);
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
    projectile = new Projectile(player1.getX(), player2.get(y), 
}


void mouseReleased()
{
  turn = !turn;
}
