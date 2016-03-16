 /* @pjs preload="http://minesweeperonline.com/sprite100.gif"; */

import de.bezier.guido.*;
private static int NUM_ROWS = 16;
private static int NUM_COLS = 30;
private static int BOMBS = 99;

private static int BUTTON_SIZE = 20;

private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> bombs; //ArrayList of just the minesweeper buttons that are mined

PImage sprites;

private boolean hasLost = false;

MineBot mineBot;

void setup ()
{
    size(600, 320);//(NUM_COLS * BUTTON_SIZE, NUM_ROWS * BUTTON_SIZE);
    textAlign(CENTER,CENTER);
    
    // make the manager
    Interactive.make( this );
    
    sprites = loadImage("http://minesweeperonline.com/sprite100.gif");

    //your code to declare and initialize buttons goes here
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    for(int c = 0; c < NUM_COLS; c++)
        for(int r = 0; r < NUM_ROWS; r++)
            buttons[r][c] = new MSButton(r, c);
    
    setBombs();

    mineBot = new MineBot();
}
public void setBombs()
{
    bombs = new ArrayList<MSButton>();
    for(int bombsPlaced = 0; bombsPlaced < BOMBS;)
    {
        int bombX = (int)(Math.random() * NUM_COLS);
        int bombY = (int)(Math.random() * NUM_ROWS);
        if(!bombs.contains(buttons[bombY][bombX]))
        {
            bombs.add(buttons[bombY][bombX]);
            bombsPlaced++;
        }
    }
}

public void draw ()
{
    background( 0 );
    if(isWon())
        displayWinningMessage();
}
public boolean isWon()
{
    for(MSButton b : bombs)
        if(!b.isMarked())
            return false;
    return true;
}
public void displayLosingMessage()
{
    hasLost = true;
}
public void displayWinningMessage()
{
    //Nobody wins
}
void keyPressed() {
    if(key == ' ')
    {
        mineBot.nextMove();
    }
}

public class MSButton
{
    public int r, c; // Public because lazy
    private float x,y, width, height;
    private boolean clicked, marked;
    private int bombsAround = 0; // Set to 0 because lazy
    
    public MSButton ( int rr, int cc )
    {
        width = BUTTON_SIZE;
        height = BUTTON_SIZE;
        r = rr;
        c = cc; 
        x = c*width;
        y = r*height;
        marked = clicked = false;
        Interactive.add( this ); // register it with the manager
    }
    public boolean isMarked()
    {
        return marked;
    }
    public boolean isClicked()
    {
        return clicked;
    }
    public int getBombsAround()
    {
        return bombsAround;
    }
    // called by manager
    
    public void mousePressed () 
    {
        if(hasLost)
            return;
        if(mouseButton == LEFT)
        {
            click();
        } else if(mouseButton == RIGHT)
        {
            mark();
        }
    }

    public void click()
    {
        if(!marked && !clicked)
        {
            if(bombs.contains(this))
            {
                clicked = true;
                displayLosingMessage();
            } else {
                clicked = true;
                if(countBombs() == 0)
                {
                    clickButton(r-1,c-1);
                    clickButton(r,c-1);
                    clickButton(r+1,c-1);
                    clickButton(r+1,c);
                    clickButton(r+1,c+1);
                    clickButton(r,c+1);
                    clickButton(r-1,c+1);
                    clickButton(r-1,c);
                } else {
                    bombsAround = countBombs();
                }
            }
        }
    }

    public void mark()
    {
        if(!clicked)
        {
            marked = !marked;
        }
    }

    public void draw () 
    {    
        if(!hasLost)
        {
            if (marked)
                image(sprites.get(16, 39, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            else if( clicked && bombs.contains(this) ) 
                image(sprites.get(32, 39, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            else if(clicked)
                drawClicked();
            else 
                image(sprites.get(0, 39, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
        } else {
            if(marked)
            {
                if(isBomb(r, c))
                    image(sprites.get(16, 39, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
                else
                    image(sprites.get(48, 39, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            } else if(isBomb(r,c))
            {
                if(clicked)
                    image(sprites.get(32, 39, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
                else 
                    image(sprites.get(64, 39, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            }
            else if(clicked)
                drawClicked();
            else 
                image(sprites.get(0, 39, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
        } 
    }

    public void drawClicked()
    {
        switch (bombsAround) {
        case 0:
            image(sprites.get(0, 23, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            break;
        case 1:
            image(sprites.get(16, 23, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            break;
        case 2:
            image(sprites.get(32, 23, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            break;
        case 3:
            image(sprites.get(48, 23, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            break;
        case 4:
            image(sprites.get(64, 23, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            break;
        case 5:
            image(sprites.get(80, 23, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            break;
        case 6:
            image(sprites.get(96, 23, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            break;
        case 7:
            image(sprites.get(112, 23, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            break;
        case 8:
            image(sprites.get(128, 23, 16, 16), x, y, BUTTON_SIZE, BUTTON_SIZE);
            break;
        
        }
    }

    public boolean isValid(int r, int c)
    {
        return !(r < 0 || r >= NUM_ROWS || c < 0 || c >= NUM_COLS);
    }
    public int countBombs()
    {
        int numBombs = 0;
        numBombs += isBomb(r-1,c-1) ? 1 : 0;
        numBombs += isBomb(r,c-1) ? 1 : 0;
        numBombs += isBomb(r+1,c-1) ? 1 : 0;
        numBombs += isBomb(r+1,c) ? 1 : 0;
        numBombs += isBomb(r+1,c+1) ? 1 : 0;
        numBombs += isBomb(r,c+1) ? 1 : 0;
        numBombs += isBomb(r-1,c+1) ? 1 : 0;
        numBombs += isBomb(r-1,c) ? 1 : 0;
        return numBombs;
    }
    public boolean isBomb(int r, int c)
    {
        if(!isValid(r, c))
            return false;
        return bombs.contains(buttons[r][c]);
    }
    public void clickButton(int r, int c)
    {
        if(!isValid(r, c))
            return;
        buttons[r][c].click();
    }
}

class MineBot {
    ArrayList<MSButton>[] incompleteSpaces = new ArrayList[9];

    private int totalClicks = 0;
    private int minesLeft = BOMBS;

    private int lastClickX = -1;
    private int lastClickY = -1;

    public MineBot()
    {
        for(int i = 0; i < incompleteSpaces.length; i++)
        {
            incompleteSpaces[i] = new ArrayList<MSButton>();
        }
    }

    public void nextMove()
    {
        System.out.println("MineBot.nextMove");
        if(hasLost)
        {
            System.out.println("Oh no... I guess we died");
        }

        int clickX = -1;
        int clickY = -1;
        
        if(lastClickY == -1) // First click
        { 
            clickX = (int)(Math.random() * NUM_COLS);
            clickY = (int)(Math.random() * NUM_ROWS);
            
        } else {
            if(!incompleteSpaces[1].isEmpty())
            {
                for(MSButton b : incompleteSpaces[1])
                {
                    if(unclickedAndUnmarkedAroundSpace(b) == 1)
                    {
                        //Click that last square
                    }
                }
            } else if(!incompleteSpaces[2].isEmpty())
            {

            } else if(!incompleteSpaces[3].isEmpty())
            {

            } else if(!incompleteSpaces[4].isEmpty())
            {

            } else if(!incompleteSpaces[5].isEmpty())
            {

            } else if(!incompleteSpaces[6].isEmpty())
            {

            } else if(!incompleteSpaces[7].isEmpty())
            {

            } else if(!incompleteSpaces[7].isEmpty())
            {

            } else {
                //Uh... idk... this shouldn't happen unless you win
            }
        }

        buttons[clickY][clickX].click();

        if(unclickedAndUnmarkedAroundSpace(buttons[clickY][clickX]) > 0)
        {
            System.out.println("unclicked/unmarked: " + unclickedAndUnmarkedAroundSpace(buttons[clickY][clickX]));
            incompleteSpaces[buttons[clickY][clickX].getBombsAround()].add(buttons[clickY][clickX]);
        }

        lastClickX = clickX;
        lastClickY = clickY;
    }

    private boolean isValid(int r, int c)
    {
        return !(r < 0 || r >= NUM_ROWS || c < 0 || c >= NUM_COLS);
    }
    private boolean isUnclicked(int r, int c)
    {
        if(!isValid(r, c))
            return false;
        return !buttons[r][c].isClicked();
    }
    private int unclickedAroundSpace(MSButton b)
    {
        int r = b.r;
        int c = b.c;
        int unclickedBombs = 0;
        unclickedBombs += isUnclicked(r-1,c-1) ? 1 : 0;
        unclickedBombs += isUnclicked(r,c-1) ? 1 : 0;
        unclickedBombs += isUnclicked(r+1,c-1) ? 1 : 0;
        unclickedBombs += isUnclicked(r+1,c) ? 1 : 0;
        unclickedBombs += isUnclicked(r+1,c+1) ? 1 : 0;
        unclickedBombs += isUnclicked(r,c+1) ? 1 : 0;
        unclickedBombs += isUnclicked(r-1,c+1) ? 1 : 0;
        unclickedBombs += isUnclicked(r-1,c) ? 1 : 0;
        return unclickedBombs;
    }
    private boolean isUnclickedAndUnmaked(int r, int c)
    {
        if(!isValid(r, c))
            return false;
        return !(buttons[r][c].isClicked() || buttons[r][c].isMarked());
    }
    private int unclickedAndUnmarkedAroundSpace(MSButton b)
    {
        int r = b.r;
        int c = b.c;
        int unclickedBombs = 0;
        unclickedBombs += isUnclicked(r-1,c-1) ? 1 : 0;
        unclickedBombs += isUnclicked(r,c-1) ? 1 : 0;
        unclickedBombs += isUnclicked(r+1,c-1) ? 1 : 0;
        unclickedBombs += isUnclicked(r+1,c) ? 1 : 0;
        unclickedBombs += isUnclicked(r+1,c+1) ? 1 : 0;
        unclickedBombs += isUnclicked(r,c+1) ? 1 : 0;
        unclickedBombs += isUnclicked(r-1,c+1) ? 1 : 0;
        unclickedBombs += isUnclicked(r-1,c) ? 1 : 0;
        return unclickedBombs;
    }
}
