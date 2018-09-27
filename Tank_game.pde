import java.awt.Rectangle;
import java.awt.geom.Ellipse2D;

final int PLAYER_WIDTH_PROPORTION = 20;
final int PLAYER_HEIGHT_PROPORTION = 20;
final int OBSTACLE_WIDTH_PROPORTION = 10;
final int OBSTACLE_HEIGHT_PROPORTION = 10;
final int PLAYER_INIT_X_PROPORTION = 10;
final int PLAYER_INCREMENT_PROPORTION = 100;
final int PROJECTILE_RADIUS_PROPORTION = 50;

Player player1, player2;
Particle projectile;
Particle[][] obstacles = new Particle[6][7];
int xStart, yStart, xEnd, yEnd, lim[], obstacleWidth, obstacleHeight;
UserForce userForce, wind;
Gravity gravity;
ForceRegistry forceRegistry;
boolean movingLeft = false, movingRight = false, turn = true;

void setup()
{
  fullScreen();
  int playerWidth = displayWidth/PLAYER_WIDTH_PROPORTION;
  int playerHeight = displayHeight/PLAYER_HEIGHT_PROPORTION;
  int playerInitX = displayWidth/PLAYER_INIT_X_PROPORTION - playerWidth/2;
  int playerInitY = displayHeight - playerHeight;
  int playerIncrement = displayWidth/PLAYER_INCREMENT_PROPORTION;
  lim = new int[6];
  obstacleWidth = displayWidth/OBSTACLE_WIDTH_PROPORTION;
  obstacleHeight = displayHeight/OBSTACLE_HEIGHT_PROPORTION;
  player1 = new Player(playerInitX, playerInitY, playerWidth, playerHeight, playerIncrement);
  player2 = new Player(displayWidth - playerInitX, playerInitY, playerWidth, playerHeight, playerIncrement);
  gravity = new Gravity(new PVector(0f, .1f));
  userForce = new UserForce(new PVector(0f, 0f));
  wind = new UserForce(new PVector(0f, 0f));
  forceRegistry = new ForceRegistry();
  projectile = new Particle(0, 0, 0f, 0f, 0.02f);
  projectile.visible = false;
  for(int i = 0; i < 6; ++i)
  {
    int x = displayWidth/2 - 3*obstacleWidth + i*obstacleWidth;
    lim[i] = (int)random(7);
    for(int j = 0; j < lim[i]; ++j)
    {
      int y = displayHeight-j*obstacleHeight;
      obstacles[i][j] = new Particle(x, y, 0f, 0f, 0.02f);
    }
  }
  //forceRegistry.add(projectile, gravity);
  //forceRegistry.add(projectile, userForce);
}

void draw()
{
  background(211, 211, 211);
  if(movingLeft)
    if(turn)
      player1.moveLeft(obstacles, lim, 6, obstacleWidth, obstacleHeight);
    else
      player2.moveLeft(obstacles, lim, 6, obstacleWidth, obstacleHeight);
  else
    if(movingRight)
      if(turn)
        player1.moveRight(obstacles, lim, 6, obstacleWidth, obstacleHeight);
      else
        player2.moveRight(obstacles, lim, 6, obstacleWidth, obstacleHeight);
  player1.draw();
  player2.draw();
  forceRegistry.updateForces();
  projectile.integrate();
  PVector position = projectile.position;
  if(position.x < 0 || position.x > displayWidth || position.y > displayHeight)
    projectile.visible = false;
  int radius = displayWidth/PROJECTILE_RADIUS_PROPORTION;
  for(int i = 0; i < 6; ++i)
    for(int j = 0; j < lim[i]; ++j)
    {
      Particle p = obstacles[i][j];
      if(p.visible && projectile.visible && collisionRectEllipse((int)p.position.x, (int)p.position.y, obstacleWidth, obstacleHeight, (int)projectile.position.x, (int)projectile.position.y, radius, radius))
      {
        p.visible = false;
        projectile.visible = false;
      }
    }
  fill(255);
  if(projectile.visible)
    ellipse(position.x, position.y, radius, radius);
  fill(0);
  for(int i = 0; i < 6; ++i)
    for(int j = 0; j < lim[i]; ++j)
      if(obstacles[i][j].visible)
        rect(obstacles[i][j].position.x, obstacles[i][j].position.y, obstacleWidth, obstacleHeight);
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
  turn = !turn;
}

boolean collisionRectRect(int x1, int y1, int w1, int h1, int x2, int y2, int h2, int w2)
{
  Rectangle r1 = new Rectangle(x1, y1, w1, h1);
  Rectangle r2 = new Rectangle(x2, y2, w2, h2);
  return r1.intersects(r2);
}

boolean collisionRectEllipse(int x1, int y1, int w, int h, int x2, int y2, int r1, int r2)
{
  Rectangle r = new Rectangle(x1, y1, w, h);
  Ellipse2D e = new Ellipse2D.Float(x2, y2, r1, r2);
  return e.intersects(r);
}
