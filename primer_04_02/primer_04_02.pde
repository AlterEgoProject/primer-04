import ddf.minim.*;

Minim minim;
AudioInput in;

int VIEW_WIDTH=500;
int LINE_HEIGHT=50;

int AMP_VIEW_HEIGHT = 100;
int PEAK_VIEW_HEIGHT = 200;
int BEAT_VIEW_HEIGHT = 300;
int TEMPO_VIEW_HEIGHT = 400;

int PEAK_COUNT = 60;
int BEAT_COUNT = 10;
int TEMPO_COUNT = 4;

float[] amp_array = new float[VIEW_WIDTH];;
float[] peak_array = new float[VIEW_WIDTH];
float[] beat_array = new float[VIEW_WIDTH];
float[] tempo_array = new float[VIEW_WIDTH];

//////////////// from primer_02 ////////////////
PImage im;
float degree; // angle og image
float delta=0.1; // speed fo rotation
float DEGREE_MAX=45;
float AXIS_DISTANCE=4; // location of rotation axis from edge 
                       // (1/AXIS_DISTANCE from bottom edge of image)
float axis_x, axis_y;

void setup(){
  size(500,500);
  //frameRate(60);
  minim = new Minim(this);
  in = minim.getLineIn();
  
  setup_primer_02();
}

void draw(){
  background(255);
  stroke(0);
  float[] in_data = new float[in.bufferSize()];
  for(int i=0; i<in.bufferSize()-1; i++){
    in_data[i]=in.mix.get(i);
  }
  amp_array = slide_window(amp_array, max(in_data));
  peak_array = slide_window(peak_array, isPeak());
  beat_array = slide_window(beat_array, isBeat());
  //tempo_array = slide_window(tempo_array, tempoDetect()/100);
  
  //draw_line(amp_array,AMP_VIEW_HEIGHT);
  //draw_line(peak_array,PEAK_VIEW_HEIGHT);
  //draw_line(beat_array,BEAT_VIEW_HEIGHT);
  //draw_line(tempo_array,TEMPO_VIEW_HEIGHT);
  
  draw_primer_02();
}

// function to draw line graph at "height"
void draw_line(float[] data, int height){
  for(int i = 0; i < data.length-1; i++){
    line( i, height - data[i]*LINE_HEIGHT, i+1, height - data[i+1]*LINE_HEIGHT );
  }
}

// function to delect end of array and add new value
float[] slide_window(float[] old_array, float add_value){
  float[] new_array = new float[old_array.length];
  System.arraycopy(old_array, 0, new_array, 1, old_array.length-1);
  new_array[0] = add_value;
  return new_array;
}

// If intensity is larger than 3 sigma(SD) during PEAK_COUNT, it is peak.
float isPeak(){
  double mean = mean(amp_array,PEAK_COUNT);
  double SD = stdve(amp_array,PEAK_COUNT);
  if (amp_array[0] > mean+3*SD){
    return 1.;
  } else {
    return 0.;
  }
}

// If interval is larger more BEAT_COUNT, this peak is beat.
float isBeat(){
  if(peak_array[0] == 1){
    for(int i=0; i<BEAT_COUNT; i++){
       if (beat_array[i] == 1.){
        return 0.;
      } 
    }
  return 1.;
  }
  return 0.;
}

// Avarage of 4 beat intervals is music tempo.
float tempoDetect(){
  float tempo;
  int counter = 0;
  int[] beat_index = new int[TEMPO_COUNT];
  for(int i=0; i<beat_array.length; i++){
    if( beat_array[i] == 1. ){
      beat_index[counter] = i;
      counter++;
      if( counter >= TEMPO_COUNT ){ break; }
    }
  }
  if( counter < TEMPO_COUNT ){ 
    tempo = 30; 
  } else {
    tempo = (beat_index[counter-1]-beat_index[0])/((float)counter);
  }
  //fill(0);
  //textSize(24);
  //text((int)tempo, 50, 480);
  return tempo;
}

// basical math function
float stdve(float[] data, int range){
  int n = data.length;
  float mean = mean(data,range);
  float SSR = 0.;
  for(int i=0; i<range; i++){
    SSR+=Math.pow((data[i]-mean), 2);
  }
  return (float) Math.sqrt(SSR/n);
}
float mean(float[] data, int range){
  int n = data.length;
  float sum = 0.;
  for(int i=0; i<range; i++){
    sum+=data[i];
  }
  return sum/n;
}

//////////////// referenced from primer_02 ////////////////
void setup_primer_02(){
  degree=0;
  imageMode(CENTER); // centerize the location of image
  im = loadImage("eye.png");
  im.resize(0,200); // image size
}
void draw_primer_02(){
  pushMatrix();
  background(255,255,255); // white backgroud
  change_degree();
  rotation();
  popMatrix();
}

// swiching direction of rotaion (arranged for primer_04)
void change_degree(){
  if( beat_array[0] == 1. ){
    float distance = DEGREE_MAX + abs(degree);
    float tempo = tempoDetect();
    delta = -distance/tempo * (delta/abs(delta));
    degree+=delta;
    //println(distance,tempo,delta,degree);
  } else {
    if( abs(degree) < DEGREE_MAX ){
      degree+=delta;
    } else {
      degree = DEGREE_MAX * (delta/abs(delta));
    }
  }
}

//calcuration of axis and image location
void rotation(){
  translate(width/2, height/2); // center of window
  // axis location
  axis_x = im.width * ( -1/2 + 1/AXIS_DISTANCE  ) * signum(degree); // imagine vector!
  axis_y = im.height/2; // bottom of image
  translate(axis_x, axis_y); // move to axis point
  rotate(radians(degree));
  // image location
  translate(-axis_x, -axis_y); // back to the center of window
  image(im, 0, 0);
}

// Is argument(f) greater than zero ?
float signum(float f) {
  if (f >= 0) {
    return 1.0;
  } else {
    return -1.0;
  }
}
