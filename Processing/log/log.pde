/*
questo codice invia file gcode alla stampante, riceve risposta e crea log
*/

//importazione librerie necessarie
import processing.serial.*;
import java.util.Calendar;

//variabili modificabili dall'utente
int porta = 3; //porta di Arudino (win 0 - imac 3/7 - macbook 4/10)
String nomeFile = "stampa"; //nome file gcode e csv
//fine variabili modificabili dall'utente

Serial port; //Crea oggetto Serial
String valore = ""; //Dati recevuti da porta seriale
int counter = 0;
String lines []; //codice gcode
int i = 0;
String nocommento = "";
boolean inviato = false;
boolean informazioni = false;
long informazioniTempo;
Table table; //log
boolean salvato = false;

void setup() {
  printArray(Serial.list()); //stampa porte disponibili
  String Arduinoport = Serial.list()[porta]; //porta di Arudino
  port = new Serial(this, Arduinoport, 250000); //crea connessione con Arduino
  
  lines = loadStrings(nomeFile+".gcode"); //carica gcode
  
  //crea tabella e intestazioni
  table = new Table();
  table.addColumn("time");
  table.addColumn("codice");
  table.addColumn("risposta");
}

void draw() {
  if(counter>500 && valore.equals("")){ //scrivi se non c'è niente da leggere
    
    if(!salvato){
      //togli commenti
      String[] stringa = split(lines[i], ';');
      nocommento = stringa[0];
      
      //invia codice o M105
      if(!nocommento.equals("")){
        if(!inviato){
          scriviArduino(nocommento);
          informazioni = true;
          if(millis()-informazioniTempo>1000){ //chiedi temperature ogni ~1sec.
            scriviArduino("M105"); //"M105" -> temperature
            informazioni = false;
            informazioniTempo = millis();
          }
          inviato = true;
        }
      }else{
        i++;
        scriviCsv("", "");
      }
    }else{
      port.stop(); //chiudi comunicazione
    }
    
  }else{
    counter++;
    //attendi i primi ~10sec. per evitare il messaggio di connessione
    /*
    start
    echo: External Reset
    Marlin1.0.2
    echo: Last Updated: May  8 2021 15:49:12 | Author: (geeetech, I3 config)
    Compiled: May  8 2021
    echo: Free Memory: 3115  PlannerBufferBytes: 1488
    echo:Stored settings retrieved
    echo:SD card ok
    */
  }
}

//scrivi comando
void scriviArduino(String stringa){
  for(int i=0; i<stringa.length(); i++){
    port.write(str(stringa.charAt(i))); //scrivi ogni lettera del comando
  }
}

//leggi messaggio
void serialEvent(Serial p) { 
  valore = p.readStringUntil(10);
  if(valore != null){
    if(counter>500){ //se non è il messaggio di connessione aggiungi comando
      if(!informazioni){
        println("M105 " + valore); //stampa messaggio
        scriviCsv("M105", valore);
        i++;
      }else{
        println(nocommento + " " + valore); //stampa messaggio
        scriviCsv(nocommento, valore);
      }
    }else{
      println(valore); //stampa messaggio
    }
    inviato = false;
  }
  valore = "";
}

//scrivi file csv
void scriviCsv(String codice, String risposta){
  if(i>=lines.length){ //gcode finito
    if(!salvato){
      //salva tabella
      saveTable(table, "data/"+nomeFile+".csv");
      
      println("salvato");
      salvato = true;
    }
    return;
  }else if(!codice.equals("") && !risposta.equals("")){
    //ottinenti il tempo
    String ora = timestamp();
    
    //aggiungi la riga di codice gcode alla tabella
    TableRow newRow = table.addRow();
    newRow.setString("time", ora);
    newRow.setString("codice", codice);
    newRow.setString("risposta", risposta); //TODO
  }
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  String time = String.format("%1$tH:%1$tM:%1$tS.%1$tN", now);
  return time.substring(0, time.length()-6);
}
