int rows;
int columns;
LED[][] screen;
Animator anim;
float mov = 0; //mov and similar variables should later be replaces with Amp and Frq and so on.

void setup()
{
  size(960, 520); //Development
  //size(96, 52); //LED lab
  background(0);
  columns = 96;
  rows = 52;
  screen = new LED[columns][rows];
  anim = new Animator();
}

void draw()
{
  background(0);
  generateGrid();
  anim.UpdateParameters(mov);
  mov += 0.05;
}

void generateGrid() {
  float h = height/rows;
  float w = width/columns;
  for (int y = 0; y < rows; y ++) {
    for (int x = 0; x < columns; x++) {
      int c = anim.Animate("Hue Flow", x,   y);
      //int c = Animator.Animate(animationType, x, y)
      screen[x][y] = new LED(x*w, y*h, w, h);
      screen[x][y].display(c);
    }
  }
}