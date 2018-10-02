import java.awt.Rectangle;
import java.awt.geom.Ellipse2D;
import ddf.minim.*;
import java.lang.Exception;
import java.lang.Math;

final int PLAYER_WIDTH_PROPORTION = 20;
final int PLAYER_HEIGHT_PROPORTION = 20;
final int OBSTACLE_WIDTH_PROPORTION = 10;
final int OBSTACLE_HEIGHT_PROPORTION = 10;
final int PLAYER_INIT_X_PROPORTION = 10;
final int PLAYER_INCREMENT_PROPORTION = 100;
final int PROJECTILE_RADIUS_PROPORTION = 50;
final int SCORE_LIMIT = 3;

Player player1, player2;
Particle projectile;
Particle[][] obstacles = new Particle[6][7];
int xStart, yStart, xEnd, yEnd, lim[], obstacleWidth, obstacleHeight, score1 = 0, score2 = 0, playerWidth, playerHeight;
int s1, s2, direction, strength, aiX, aiY, lastShot = 0, lastEnemyShot = 0; 
float angle1, angle2, shotStrength1, shotStrength2, maxStrength;
UserForce userForce, wind;
Gravity gravity;
ForceRegistry forceRegistry;
boolean movingLeft = false, movingRight = false, turn = true, lock = false, start = true, ai = true;
Minim minim;
AudioPlayer song;

void setup()
{
  fullScreen();
  fill(0);
  textSize(20);
  text("Welcome to Tank Artillery! \n You shoot by pressing the left mouse button \n The shell will go in the direction of the cursor \n The farther away the cursor is from the tank the stronger the shot \n Press Enter for playing against AI or Space for two-player game \n First to hit the enemy tank 3 times wins. GL HF", 100, 200);
  start = true;
  playerWidth = displayWidth/PLAYER_WIDTH_PROPORTION;
  playerHeight = displayHeight/PLAYER_HEIGHT_PROPORTION;
  int playerInitX = displayWidth/PLAYER_INIT_X_PROPORTION - playerWidth/2;
  int playerInitY = displayHeight - playerHeight;
  int playerIncrement = displayWidth/PLAYER_INCREMENT_PROPORTION;
  score1 = score2 = 0;
  turn = true;
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
      //forceRegistry.add(obstacles[i][j], gravity);
    }
  }
  direction = (int)random(2);
  if(direction == 0)
  {
    strength = (int)random(11);
    wind = new UserForce(new PVector((-1)*strength, 0f));
  }
  if(direction == 1)
  {
    strength = (int)random(11);
    wind = new UserForce(new PVector(strength, 0f));
  }
  aiX = (int)random(displayWidth);
  aiY = displayHeight/4;
  minim = new Minim(this);
  maxStrength = sqrt(displayWidth*displayWidth + displayHeight*displayHeight);
  noLoop();
}

void draw()
{
  //Interface printing
  if(!start)
    background(211, 211, 211);
  textSize(displayWidth/137);
  text("P1 Score = " + score1, displayWidth/160, displayHeight/18);
  text("P2 Score = " + score2, displayWidth - displayWidth/12, displayHeight/18);
  textSize(displayWidth/64);
  if(turn)
    text("Player 1's Turn", displayWidth/2 - displayWidth/20, displayHeight/18);
  else
    text("Player 2's Turn", displayWidth/2  - displayWidth/20, displayHeight/18);
  textSize(displayWidth/80);
  if(direction == 0)
    text("Wind direction: Left", displayWidth/2  - displayWidth/20, displayHeight/12);
  else
    text("Wind direction: Right", displayWidth/2  - displayWidth/20, displayHeight/12);
  text("Wind strength = " + strength + "/10", displayWidth/2 - displayWidth/20, displayHeight/9);
  if(turn && !lock)
  {
    angle1 = atan2(mouseX - player1.getX(), displayHeight - mouseY)*180/3.14;
    shotStrength1 = sqrt((mouseX - player1.getX())*(mouseX - player1.getX()) + (mouseY - player1.getY())*(mouseY - player1.getY()))/maxStrength*100;
  }
  if(!turn && !ai && !lock)
  {
    angle2 = atan2(displayWidth - mouseX - displayWidth + player2.getX(), displayHeight - mouseY)*180/3.14; 
    shotStrength2 = sqrt((mouseX - player2.getX())*(mouseX - player2.getX()) + (mouseY - player2.getY())*(mouseY - player2.getY()))/maxStrength*100;
  }
  textSize(displayWidth/137);
  text("Angle: " + angle1, displayWidth/160, displayHeight/12);
  text("Strength: " + shotStrength1 + "%", displayWidth/160, displayHeight/9);
  text("Angle: " + angle2, displayWidth - displayWidth/12, displayHeight/12);
  text("Strength: " + shotStrength2 + "%", displayWidth - displayWidth/12, displayHeight/9);  
  
  //Player movement
  if(movingLeft)
    if(turn)
      player1.moveLeft(obstacles, lim, 6, obstacleWidth, obstacleHeight);
    else
    {
      if(!ai)
        player2.moveLeft(obstacles, lim, 6, obstacleWidth, obstacleHeight);
    }
  else
    if(movingRight)
      if(turn)
        player1.moveRight(obstacles, lim, 6, obstacleWidth, obstacleHeight);
      else
      {
        if(!ai)
          player2.moveRight(obstacles, lim, 6, obstacleWidth, obstacleHeight);
      }
  player1.draw();
  player2.draw();
  
  
  forceRegistry.updateForces();
  projectile.integrate();
  PVector position = projectile.position;
  int radius = displayWidth/PROJECTILE_RADIUS_PROPORTION;
  
  //Projectile - obstacle collisions
  for(int i = 0; i < 6; ++i)
    for(int j = 0; j < lim[i]; ++j)
    {
      Particle p = obstacles[i][j];
      if(p.visible && projectile.visible && collisionRectEllipse((int)p.position.x, (int)p.position.y, obstacleWidth, obstacleHeight, (int)projectile.position.x, (int)projectile.position.y, radius, radius))
      {
        p.visible = false;
        if(!turn)
          lastEnemyShot = (int)position.x;
        else
          lastShot = (int)position.x;
        String filePath = dataPath("sfx_exp_short_soft1.wav");
        try
        {
          song = minim.loadFile(filePath);
          song.play();
        }
        catch (Exception e)
        {
          minim = new Minim(this);
        }       
        projectile.visible = false;
      }
    }
    
  //Projectile - player2 collisions
  s2 = second();
  if(projectile.visible && (s2 - s1 >= 2) && collisionRectEllipse(player1.getX(), player1.getY(), playerWidth, playerHeight, (int)projectile.position.x, (int)projectile.position.y, radius, radius))
  {
    if(!turn)
      lastEnemyShot = (int)position.x;
    else
      lastShot = (int)position.x;   
    projectile.visible = false;
    String filePath = dataPath("sfx_damage_hit1.wav");
    try
    {
      song = minim.loadFile(filePath);
      song.play();
    }
    catch (Exception e)
    {
      minim = new Minim(this);
    }
    ++score2;
    if(score2 == SCORE_LIMIT)
    {
      textSize(displayWidth/10);
      text("Player 2 wins \n", displayWidth/4, displayHeight/2);
      textSize(displayWidth/40);
      text("Press Enter to start a game against AI or Space for a two-player game", displayWidth/10, displayHeight/2 + displayWidth/15);
      filePath = dataPath("sfx_sounds_fanfare1.wav");
      try
      {
        song = minim.loadFile(filePath);
        song.play();
      }
      catch (Exception e)
      {
        minim = new Minim(this);
      }
      noLoop();
    }
  }
  
  //Projectile - player1 collisions
  if(projectile.visible && (s2 - s1 >= 2) && collisionRectEllipse(player2.getX(), player2.getY(), playerWidth, playerHeight, (int)projectile.position.x, (int)projectile.position.y, radius, radius)) 
  {
    if(!turn)
      lastEnemyShot = (int)position.x;
    else
      lastShot = (int)position.x; 
    projectile.visible = false;
    String filePath = dataPath("sfx_damage_hit1.wav");
    try
    {
      song = minim.loadFile(filePath);
      song.play();
    }
    catch (Exception e)
    {
      minim = new Minim(this);
    }
    ++score1;
    if(score1 == SCORE_LIMIT)
    {
      textSize(displayWidth/10);
      text("Player 1 wins \n", displayWidth/4, displayHeight/2);
      textSize(displayWidth/40);
      text("Press Enter to start a game against AI or Space for a two-player game", displayWidth/10, displayHeight/2 + displayWidth/15);
      filePath = dataPath("sfx_sounds_fanfare1.wav");
      try
      {
        song = minim.loadFile(filePath);
        song.play();
      }
      catch (Exception e)
      {
        minim = new Minim(this);
      }
      noLoop();
    }
  }
  
  //Projectile out-of-bounds checking
  if(position.x < 0 || position.x > displayWidth || position.y > displayHeight)
  {
    if(!turn)
      lastEnemyShot = (int)position.x;
    else
      lastShot = (int)position.x;
    projectile.visible = false;
  }
  
  //Projectile and obstacle drawing
  fill(255);
  if(projectile.visible)
    ellipse(position.x, position.y, radius, radius);
  fill(0);
  for(int i = 0; i < 6; ++i)
    for(int j = 0; j < lim[i]; ++j)
      if(obstacles[i][j].visible)
      {
        obstacles[i][j].integrate();
        rect(obstacles[i][j].position.x, obstacles[i][j].position.y, obstacleWidth, obstacleHeight);
      }
      
  //Wind refreshing
  if(!projectile.visible && lock)
  {
    direction = (int)random(2);
    if(direction == 0)
    {
      strength = (int)random(11);
      wind = new UserForce(new PVector((-1)*strength, 0f));
    }
    if(direction == 1)
    {
      strength = (int)random(11);
      wind = new UserForce(new PVector(strength, 0f));
    }    
  }
  
  if(!projectile.visible)
      lock = false;
  userForce.set(0f, 0f);
  
  //AI turn if apllicable
  if(ai && !turn && !lock)
  {
    xStart = player2.getX();
    yStart = player2.getY();
    projectile = new Particle(xStart, yStart, 0f, 0f, 0.015f);
    s1 = second();
    int windAdjustment;
    if(direction == 0)
      windAdjustment = 5;
    else
      windAdjustment = -5;
    if(abs(player2.getX() - lastEnemyShot) < playerWidth*2)
      if(lastEnemyShot > player2.getX())
      {
        player2.moveLeft(obstacles, lim, 6, obstacleWidth, obstacleHeight);
        player2.moveLeft(obstacles, lim, 6, obstacleWidth, obstacleHeight);
        player2.moveLeft(obstacles, lim, 6, obstacleWidth, obstacleHeight);
        player2.moveLeft(obstacles, lim, 6, obstacleWidth, obstacleHeight);
      }
      else
      {
        player2.moveRight(obstacles, lim, 6, obstacleWidth, obstacleHeight);
        player2.moveRight(obstacles, lim, 6, obstacleWidth, obstacleHeight);
        player2.moveRight(obstacles, lim, 6, obstacleWidth, obstacleHeight);
        player2.moveRight(obstacles, lim, 6, obstacleWidth, obstacleHeight);
      }
    aiX += (player1.getX() - lastShot)/2 + windAdjustment*strength;
    //aiY -= (player1.getX() - lastShot.x); //+ windAdjustment*strength;
    xEnd = aiX;
    yEnd = aiY;
    userForce.set(xEnd - xStart, yEnd - yStart);
    forceRegistry.add(projectile, gravity);
    forceRegistry.add(projectile, userForce);
    forceRegistry.add(projectile, wind);
    String filePath = dataPath("sfx_weapon_singleshot1.wav");
    try
    {
      song = minim.loadFile(filePath);
      song.play();
    }
    catch (Exception e)
    {
      minim = new Minim(this);
    }
    turn = !turn;
    lock = true;
  }
}

void keyPressed()
{
  if(key == CODED && !lock)
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
  if(key == CODED && !lock);
    switch(keyCode)
    {
      case LEFT:
        movingLeft = false;
        break;
      case RIGHT:
        movingRight = false;
        break;
      case ENTER:
        print("bump2");
        ai = true;
        start = false;
        loop();
        break;
      case ' ':
        ai = false;
        start = false;
        loop();
        break;
    }
}

//Shooting
void mousePressed()
{
  if(!looping)
  {
    setup();
    return;
  }
  if(!lock && (!ai || (ai && turn)))
  {
    if(turn)
    {
      xStart = player1.getX();
      yStart = player1.getY();
      projectile = new Particle(xStart, yStart, 0f, 0f, 0.015f);
      s1 = second();
    }
    else
    {
      xStart = player2.getX();
      yStart = player2.getY();
      projectile = new Particle(xStart, yStart, 0f, 0f, 0.015f);
      s1 = second();
    }
    xEnd = mouseX;
    yEnd = mouseY;
    userForce.set(xEnd - xStart, yEnd - yStart);
    forceRegistry.add(projectile, gravity);
    forceRegistry.add(projectile, userForce);
    forceRegistry.add(projectile, wind);
    String filePath = dataPath("sfx_weapon_singleshot1.wav");
    try
    {
      song = minim.loadFile(filePath);
      song.play();
    }
    catch (Exception e)
    {
      minim = new Minim(this);
    }
    turn = !turn;
    lock = true;
  }
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
