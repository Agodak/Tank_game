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
  
  void moveLeft()
  {
    position.x -= moveIncrement;
    if(position.x < 0)
      position.x = 0;
  }
  
  void moveRight()
  {
    position.x += moveIncrement;
    if(position.x > displayWidth - playerWidth)
      position.x = displayWidth - playerWidth;
  }
}
