final class Player
{
  PVector position;
  int playerWidth, playerHeight;
  int moveIncrement;
  
  Player(int x, int y, int playerWidth, int playerHeight, int moveIncrement)
  {
    position = new PVector(x, y);
    this.playerWidth = playerWidth;
    this.playerHeight = playerHeight;
    this.moveIncrement = moveIncrement;
  }
  
  int getX()
  {
    return (int)position.x;
  }
  
  int getY()
  {
    return (int)position.y;
  }
  
  void draw()
  {
    fill(255);
    rect(position.x, position.y, playerWidth, playerHeight);
  }
  
  void moveLeft(Particle[][] obstacles, int lim[], int x, int obstacleWidth, int obstacleHeight)
  {
    boolean b = true;
    for(int i = 0; i < x; ++i)
      for(int j = 0; j < lim[i]; ++j)
      {
        Particle p = obstacles[i][j];
        if(p.position.x < position.x)
          if(p.visible && collisionRectRect((int)position.x, (int)position.y, playerWidth, playerHeight, (int)p.position.x, (int)p.position.y, obstacleWidth, obstacleHeight))
            b = false;
      }
    if(b)
      position.x -= moveIncrement;
    if(position.x < 0)
      position.x = 0;
  }
  
  void moveRight(Particle[][] obstacles, int lim[], int x, int obstacleWidth, int obstacleHeight)
  {
    boolean b = true;
    for(int i = 0; i < x; ++i)
      for(int j = 0; j < lim[i]; ++j)
      {
        Particle p = obstacles[i][j];
        if(p.position.x > position.x)
          if(p.visible && collisionRectRect((int)position.x, (int)position.y, playerWidth, playerHeight, (int)p.position.x, (int)p.position.y, obstacleWidth, obstacleHeight))
            b = false;
      }
    if(b)
      position.x += moveIncrement;
    if(position.x > displayWidth)
      position.x = displayWidth - playerWidth;
  }
  
  boolean collisionRectRect(int x1, int y1, int w1, int h1, int x2, int y2, int w2, int h2)
  {
    Rectangle r1 = new Rectangle(x1, y1, w1, h1);
    Rectangle r2 = new Rectangle(x2, y2, w2, h2);
    return r1.intersects(r2);
  }
}
