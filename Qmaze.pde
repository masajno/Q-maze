int x_size = 10;
int y_size = 9;
int max_a,count=0;
double max;
int select_a = 0;
double reward;

int[][] maze = new int[y_size][x_size];//迷路の配列を定義

double[][] Qtable = new double[90][4];//横10*縦9マスの迷路のQ値の配列を定義

//sはマスの位置を表す
// 0  1  2  3  4  5  6  7  8  9
//10 11 12 13 14 15 16 17 18 19
//20 21....
//このように横10*縦9マスの迷路

void draw_maze(){//迷路の描写 壁の値を-1 道の値を0 ゴールの値を10とする
  background(255);
  
  for(int i=0; i<y_size; i++){
    for(int j=0; j<x_size; j++){
      if(maze[i][j]==-1){
        fill(128);
        rect(j*50,i*50,50,50);
      }
      
      else if(maze[i][j]==10){
        fill(255,0,0);
        rect(j*50,i*50,50,50);
      }
      
      else if(maze[i][j]==0){
        fill(255);
        rect(j*50,i*50,50,50);
      }
      
    }
  }
  
}


void draw_robot(int s){ //迷路にいる自分の位置を描写 sはマスの位置を表す
  fill(0,255,0);
  ellipse(50*(s%10)+25,50*(int)(s/10)+25,20,20);
}

double robot_reward(int s, int a){
  //a=0で下　a=1で右 a=2で上 a=3で左に進む 進んだ先が行き止まりだと報酬-1 道だと報酬0 ゴールだと報酬10
  double reward;
  //sの１０の位がy座標になるから10で割ってint型に
  //sの1の位がx座標になるから10で割ったあまりを使う
  if(a==0){
    reward=maze[(int)(s/10)+1][s%10];
  }
  else if(a==1){
    reward=maze[(int)(s/10)][s%10+1];
  }
  else if(a==2){
    reward=maze[(int)(s/10)-1][s%10];
  }
  else if(a==3){
    reward=maze[(int)(s/10)][s%10-1];
  }
  
  else{reward=0;}
  
  println("s="+s+", a="+a+", reward="+reward);
  return reward;
}


int robot_sd(int s, int a){//位置sから移動aをした後の位置をreturn
  int sd;
  if(a==0){
    sd=((int)(s/10)+1)*10+s%10;
  }
  else if(a==1){
    sd=((int)(s/10))*10+s%10+1;
  }
  else if(a==2){
    sd=((int)(s/10)-1)*10+s%10;
  }
  else if(a==3){
    sd=((int)(s/10))*10+s%10-1;
  }
  else{sd=0;}
  println("s="+s+", a="+a+", sd="+sd);
  return sd;
}

int epsilon_greedy(int epsilon, int s, int num_a, double[][] Qtable){
  //ε-greedy法で次の行動を選択
  if(epsilon>(int)random(100)){
    select_a = (int)random(num_a);
  }
  else{
    select_a = select_action(s, num_a, Qtable);
  }
  return select_a;
}

double max_Qval(int s, int num_a, double[][] Qtable){//Q値の最大値を出力
  for(int a=0; a<num_a-1; a++){
    if(Qtable[s][a]<Qtable[s][a+1]){
      max=Qtable[s][a+1];
    }
    else if(Qtable[s][a]==Qtable[s][a+1]){
      max_a=(int)random(num_a);
    }
    else{
      max=Qtable[s][a];
    }
  }
 return max;
}


int select_action(int s, int num_a, double[][] Qtable) {//Q値の最大からアクションを選択
  double max;
  int max_a=0;
  int[] i_max = new int[num_a];
  int num_i_max = 1;

  i_max[0] = 0;
  max = Qtable[s][0];

  for (int i = 1; i<num_a; i++) {
    if (Qtable[s][i]>max) {
      max = Qtable[s][i];
      num_i_max = 1;
      i_max[0] = i;
    } else if (Qtable[s][i] == max) {
      num_i_max++;
      i_max[num_i_max - 1] = i;
    }
  }

  max_a = i_max[(int)random(num_i_max)];

  return max_a;
}

int s=11 ,e=10;
double alpha = 0.5, gamma = 0.9;

void episode(double[][] Qtable){//今までの関数を使って試行する
  int s=11;
  int sd;
  double reward=0;
  for(int i=0; i<100&&reward==0; i++){//試行回数が100回または報酬を得た時点で試行を終了
    epsilon_greedy(e, s, 4, Qtable);
    reward=robot_reward(s, select_a);
    print(select_a);
    sd=robot_sd(s, select_a);
    //Q値を保存
    Qtable[s][select_a] = (1-alpha) * Qtable[s][select_a] + alpha*(reward + gamma * max_Qval(sd, 4 , Qtable));
    s = sd;
    draw_robot(s);
  }
}

void setup(){
  size(500,450);
  randomSeed(second());
  maze[2][2]=-1; 
  maze[2][3]=-1;
  maze[6][3]=-1;
  maze[7][2]=-1;
  maze[3][8]=-1;
  maze[6][2]=-1;
  maze[3][6]=-1;
  maze[7][6]=-1;
  maze[3][7]=-1;
  maze[6][8]=10;
  for(int i=0; i<9; i++){
    maze[0][i]=-1;
    maze[8][i]=-1;
    maze[i][0]=-1;
    maze[i][9]=-1;
  }
  
  draw_maze();
  
  draw_robot(s);
  
}


void draw(){//試行して報酬を獲得するepisode関数を300回繰り返してゴールまでの道を学習
  draw_maze();
  
  draw_robot(s);
  episode(Qtable);
  count +=1;
  
  if(count==300){
    noLoop();
  }
}
