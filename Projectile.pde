final class Projectile
{
  PVector position, velocity, acceleration;
  int projectileRadius;
  
  Projectile(int x, int y, float xVel, float yVel, float xAcc, float yAcc, int projectileRadius)
  {
    position = new PVector(x, y);
    velocity = new PVector(xVel, yVel);
    acceleration = new PVector(xAcc, yAcc);
    this.projectileRadius = projectileRadius;
  }
  
  void reset(int x, int y)
  {
    position.x = x;
    position.y = y;
  }
  
  void integrate()
  {
    position.add(velocity);
    velocity.add(acceleration);
    if ((position.x < 0) || (position.x > width)) velocity.x = -velocity.x;
    if ((position.y < 0) || (position.y > height)) velocity.y = -velocity.y;
  }
}
