public final class Gravity extends ForceGenerator
{
  private PVector gravity;
  
  Gravity(PVector gravity)
  {
    this.gravity = gravity;
  }
  
  void updateForce(Particle particle)
  {
    PVector resultingForce = gravity.get();
    resultingForce.mult(particle.getMass());
    particle.addForce(resultingForce);
  }
}
