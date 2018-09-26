import java.util.Iterator;

class ForceRegistry
{
  class ForceRegistration
  {
    public final Particle particle;
    public final ForceGenerator forceGenerator;
    ForceRegistration(Particle p, ForceGenerator fg)
    {
      particle = p;
      forceGenerator = fg;
    }
  }
  
  ArrayList<ForceRegistration> registrations = new ArrayList();
  
 
  void add(Particle p, ForceGenerator fg)
  {
    registrations.add(new ForceRegistration(p, fg));
  }
  
  void clear()
  {
    registrations.clear();
  }
 
  void updateForces()
  {
    Iterator<ForceRegistration> itr = registrations.iterator();
    while(itr.hasNext())
    {
      ForceRegistration fr = itr.next();
      fr.forceGenerator.updateForce(fr.particle);
    }
  }
}
