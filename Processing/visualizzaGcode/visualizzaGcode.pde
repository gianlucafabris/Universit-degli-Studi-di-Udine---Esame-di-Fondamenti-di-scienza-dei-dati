/*
questo codice visualizza un file gcode (utilizzabile senza stampante 3d)
*/

//variabili modificabili dall'utente
String nomeFile = "stampa"; //nome file gcode
boolean prospettica = true; // visuale prospettica/ortogtafica
//fine variabili modificabili dall'utente

String lines []; //codice gcode
int i = 0;
float precx = 0;
float precy = 0;
float precz = 0;
boolean absolute = true;
boolean finito = false;

void setup() {
  lines = loadStrings(nomeFile+".gcode"); //carica gcode
  size(1600, 900, P3D); //disegno 1600x900, 3d funziona solo su win
  background(0); //background nero
  
  if(prospettica){
    //visuale prospettica
    translate((width-190)/2+100, (height-200)/2+250, 500);
    rotateX(PI/4);
    rotateZ(-PI/4);
  }else{
    //visuale ortogtafica
    translate((width-190)/2, (height-200)/2+225, 700);
    rotateX(PI*3/8);
    rotateZ(-PI/8);
    ortho();
  }
  
  //piatto di stampa
  stroke(255,0,0);
  
  line(0,   0,    0, 190, 0,    0);
  line(190, 0,    0, 190, -200, 0);
  line(190, -200, 0, 0,   -200, 0);
  line(0,   -200, 0, 0,   0,    0);
  
  //area di stampa
  stroke(255,255,255);
  
  line(0,   0,    0, 0,   0,    180);
  line(190, 0,    0, 190, 0,    180);
  line(190, -200, 0, 190, -200, 180);
  line(0,   -200, 0, 0,   -200, 180);
  
  line(0,   0,    180, 190, 0,    180);
  line(190, 0,    180, 190, -200, 180);
  line(190, -200, 180, 0,   -200, 180);
  line(0,   -200, 180, 0,   0,    180);
}

void draw() {
  leggiGcode();
}

//leggi file gcode - https://marlinfw.org/meta/gcode/
void leggiGcode(){
  if(i>=lines.length){ //gcode finito
    if(!finito){
      println("finito");
      finito = true;
    }
    return;
  }else{
    //togli commenti
    String[] stringa = split(lines[i], ';');
    String nocommento = "";
    nocommento = stringa[0];
    
    //taglia ad ogni spazio
    String[] stringa1 = split(nocommento, ' ');
    switch(stringa1[0]){
      //linear move
      case "G0": case "G1":
        //ottini valori di spostmento x,y,z,e (f - feedrate non molto rilevante per la visualizzazione)
        String[] stringa2 = split(nocommento, 'X');
        String[] stringa3 = split(nocommento, 'Y');
        String[] stringa4 = split(nocommento, 'Z');
        String[] stringa5 = split(nocommento, 'E');
        
        float x=precx;
        float y=precy;
        float z=precz;
        float e=0;
        
        //moviemento senza esrusione
        stroke(0,255,255);
        strokeWeight(1);
        
        if(stringa2.length>1){
          String[] stringa6 = split(stringa2[1], ' ');
          x=float(stringa6[0]);
        }
        if(stringa3.length>1){
          String[] stringa7 = split(stringa3[1], ' ');
          y=float(stringa7[0]);
        }
        if(stringa4.length>1){
          String[] stringa8 = split(stringa4[1], ' ');
          z=float(stringa8[0]);
        }
        if(stringa5.length>1){
          String[] stringa9 = split(stringa5[1], ' ');
          e=float(stringa9[0]);
          //moviemnto con estrusione
          stroke(0,0,255);
          strokeWeight(2);
        }
        
        if(prospettica){
          //visuale prospettica
          translate((width-190)/2+100, (height-200)/2+250, 500);
          rotateX(PI/4);
          rotateZ(-PI/4);
        }else{
          //visuale ortogtafica
          translate((width-190)/2, (height-200)/2+225, 700);
          rotateX(PI*3/8);
          rotateZ(-PI/8);
          ortho();
        }
        
        //disegna il movimento
        line(precx, -precy, precz, x, -y, z);
        
        //disenga due linee nere a destra e sinistra per rendere più visibile la linea del movimento
        stroke(0);
        strokeWeight(0.25);
        line(precx-0.5, -precy+0.5, precz, x-0.5, -y+0.5, z);
        line(precx+0.5, -precy-0.5, precz, x+0.5, -y-0.5, z);
        
        //area di stampa
        stroke(255,255,255);
        
        line(0,   0,    0, 0,   0,    180);
        line(190, 0,    0, 190, 0,    180);
        line(190, -200, 0, 190, -200, 180);
        line(0,   -200, 0, 0,   -200, 180);
        
        line(0,   0,    180, 190, 0,    180);
        line(190, 0,    180, 190, -200, 180);
        line(190, -200, 180, 0,   -200, 180);
        line(0,   -200, 180, 0,   0,    180);
        
        //prepara inizio prossima linea
        if(stringa2.length>1){
          precx=x;
        }
        if(stringa3.length>1){
          precy=y;
        }
        if(stringa4.length>1){
          precz=z;
        }
      break;
      //posizione assoluta
      case "G90":
        absolute = true;
      break;
      //posizione relativa
      case "G91":
        absolute = false;
      break;
      //altri codici gcode non molto rilevanti per la visualizzazione
      default:
        
      break;
    }
    
    i++;
  }
}
