Piece  board[][];
Clicked clicked;
boolean move_maked, player , GAMEEND;
int blackPiecesLeft,whitePiecesLeft;

PImage Q;

void setup(){
  GAMEEND=false;
  Q = loadImage("queen.png");
  blackPiecesLeft=12;
  whitePiecesLeft=12;
  size(800,800);
  stroke(255);
  strokeWeight(5);
  board=new Piece[8][8];
  move_maked=false;
  player=true;
  clicked=new Clicked();
  for(int i=0;i<8;++i) for(int j=0;j<8;++j) board[i][j]=new Piece();
  for(int i=0;i<8;++i) for(int j=0;j<3;++j) if((i+j)%2==1)  board[i][j]=new Piece(true);
  for(int i=0;i<8;++i) for(int j=5;j<8;++j) if((i+j)%2==1)  board[i][j]=new Piece(false);
}

void draw(){
  print();
}

void print(){
  noStroke();
  //stroke(player?color(230):color(20));
   for(int i=0;i<8;++i) for(int j=0;j<8;++j) {
     fill(((i+j)%2==0)?color(255):color(0));
     rect(map(i,0,8,0,width),map(j,0,8,0,height),width/8,height/8);  //cala plansza
     
     if(! board[i][j].dead){
       fill(board[i][j].Owner?color(230):color(20));
       stroke(255); 
       ellipse(map(i,0,8,0,width) +width/16 ,map(j,0,8,0,height)+height/16,width/12,height/12);  //zywe pionki
       if(board[i][j].Q) image(Q, map(i,0,8,0,width)  ,map(j,0,8,0,height),width/8,height/8);//bonus od damy
       noStroke();
       //stroke(player?color(230):color(20));
     }
   }  
   
   
   if (clicked.pointed!=null) {
     noFill();
     stroke(0,255,0);
     ellipse(map(clicked.x,0,8,0,width) +width/16 ,map(clicked.y,0,8,0,height)+height/16,width/12,height/12); //zielony krag
   }
   
   
   
   noFill();
   stroke(player?color(230):color(20));
   strokeWeight(15);
   rect(0,0,width,height);  //bajery. otoczka koloru aktualnego gracza.
   strokeWeight(5);
   
   
}

void makeMove(){
  int y=(int)map(mouseY, 0,height, 0, 8);   
  int x=(int)map(mouseX, 0,width , 0, 8); 
  if((x+y)%2==1){
    if(! board[x][y].dead ){
      if(clicked.pointed==null && board[x][y].Owner==player) clicked=new Clicked(x,y,board[x][y]);
    }
    else if(clicked.pointed!=null){
      if(clicked.pointed.Q){//krolowa
        if(abs(clicked.x-x)==abs(clicked.y-y)){ //linia agonalna?
        
          int alive_counter=0; //ilu na drodze?
          int ex=-1,ey=-1;
          int j,i;
          for(i = (clicked.x<x) ? clicked.x+1 : clicked.x-1 , j = (clicked.y<y) ? clicked.y+1 : clicked.y-1 ; i!=x ; ){
            
            if(!board[i][j].dead && board[i][j].Owner!=player){
              ex=i;
              ey=j;
              alive_counter++;
            }
            if(j<y) j++; else j--;
            if(i<x) i++; else i--;
            
          }
          if(alive_counter==0 && !move_maked){
            board[x][y]=board[clicked.x][clicked.y];
            board[clicked.x][clicked.y]=new Piece();
            player=!player;
            clicked=new Clicked();
          }
          else if(alive_counter==1){
            board[x][y]=clicked.pointed;
            board[ex][ey]=new Piece();
            if(player) blackPiecesLeft--;else whitePiecesLeft--; //destruktor
            board[clicked.x][clicked.y]=new Piece();
            clicked.x=x;
            clicked.y=y;
            move_maked=true;
          }
        }  
      }
      else{ //pionek
        if(abs(clicked.x-x)==1 && (((clicked.y-y)==1 && player==false) || (clicked.y-y)==-1 && player==true ) &&  !move_maked){ //zawiera warunek na chodzenie w przód,tyl
          board[x][y]=clicked.pointed;
          if((y==0 && !player)||(y==7 && player)) clicked.pointed.Q=true;
          board[clicked.x][clicked.y]=new Piece();
          player=!player;
          clicked=new Clicked();
        }
        else if(abs(clicked.x-x)==2 && abs(clicked.y-y)==2){
          if(board[(int)((clicked.x+x)/2)][(int)((clicked.y+y)/2)].dead==false && board[(int)((clicked.x+x)/2)][(int)((clicked.y+y)/2)].Owner==!player){
          //if(board[(int)((clicked.x+x)/2)][(int)((clicked.y+y)/2)]==new Pice(!player)){
            board[x][y]=clicked.pointed;
            if((y==0 && !player)||(y==7 && player)) clicked.pointed.Q=true;
            board[(clicked.x+x)/2][(clicked.y+y)/2]=new Piece();
            if(player) blackPiecesLeft--;else whitePiecesLeft--;  //destruktor  
           
            board[clicked.x][clicked.y]=new Piece();
            clicked.x=x;
            clicked.y=y;
            if(!canStillMove(clicked.x,clicked.y)){
              move_maked=false;
              player=!player;
              clicked=new Clicked();
            }
            else move_maked=true;
          }
        }
        
      }
    }
  }
}



boolean canStillMove(int X,int Y){
  for(int i=-1;i<2;i+=2){
    if(X+i*2<0 || X+i*2>7) continue;
    for(int j=-1;j<2;j+=2){
      if(Y+j*2<0 || Y+j*2>7) continue;
      if(board[(X+i*2)][(Y+j*2)].dead==true ){
        if(board[(X+i)][(Y+j)].dead==false && board[(X+i)][(Y+j)].Owner==!player) {
          return true;
        }
      }
    }
  }
  return false;
}



void mousePressed() {
  if(!GAMEEND){
    if(mouseButton ==LEFT ) makeMove();
    else if(!move_maked)clicked=new Clicked();
  }
}

void keyPressed(){
   if(key==ENTER&&move_maked){
     player=!player;
     clicked=new Clicked();
     move_maked=false;
   }
}

class Piece{
  boolean Q,dead,Owner;
  Piece(boolean OwnerS){
    dead=false;
    Q=false;
    Owner=OwnerS;
    if(Owner) blackPiecesLeft++;else whitePiecesLeft++;
  }
  Piece(){
    dead=true;
  }
};

class Clicked{
  Piece pointed;
  int x,y;
  Clicked(){
    pointed=null;
  }
  Clicked(int xS,int yS,Piece pointedS){
    x=xS;
    y=yS;
    pointed=pointedS;
  }
};


void checkForWinOrDraw(){
  if(blackPiecesLeft==0){
    GAMEEND=true; 
  }
  else if(whitePiecesLeft==0){
    GAMEEND=true; 
  }
  else{
    boolean Draw=true;
    for(int i=0;i<8;++i) for(int j=0;j<8;j++) if(canStillMove(i,j)) {Draw=false; break;}
    
    if(Draw)GAMEEND=true; 
  } 
}
