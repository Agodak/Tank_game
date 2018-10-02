final class Particle
{
  public PVector position, velocity;
  public boolean visible;
  private PVector forceAccumulator;
  private static final float DAMPING = .995f;
  private float invMass;
  
  public float getMass()
  {
    return 1/invMass;
  }
  
  Particle(int x, int y, float xVel, float yVel, float invM)
  {
    position = new PVector(x, y);
    velocity = new PVector(xVel, yVel);
    forceAccumulator = new PVector(0, 0);
    invMass = invM;
    this.visible = true;
  }
  
  void addForce(PVector force)
  {
    forceAccumulator.add(force);
  }
  
  void integrate()
  {
    if(invMass <= 0f)
      return;
    position.add(velocity);
    PVector resultingAcceleration = forceAccumulator.get();
    resultingAcceleration.mult(invMass);
    velocity.add(resultingAcceleration);
    velocity.mult(DAMPING);
    //if ((position.x < 0) || (position.x > width)) velocity.x = -velocity.x;
    //if ((position.y < 0) || (position.y > height)) velocity.y = -velocity.y;
    forceAccumulator.x = 0;
    forceAccumulator.y = 0;
  }
}
