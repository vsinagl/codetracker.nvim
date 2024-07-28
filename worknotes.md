# DATABASE
## Predpkolady
### text-buffer tracking
- vzdy budu trekovat jeden session -- session bude buffer
    - session tracker skoncim vzdy kdyz se prepnu do noveho bufferu
        - nebo kdyz vyprsi urcity cas po ktery nebyl zmacknuty zadny keystroke
        - nebo kdyz skonci, vypne se seance vimu
    - session tracker zapnu vzdy kdyz se prepnu do bufferu
    - buffer_start_tracker vzdy kdy otevru novy buffer, zaaroven u
- po skonceni sessionu (bufferu) se data odeslou na sqllite server, ktery bude zatim ulozen lokalne
- casem by se to mohlo odeslat jako package na remote server ale to zatim budeme muset pockat

### keystroke session
- aktivni buffer bude mit vlastni buffer pro keystroky. 
    - tento buffer se odesle do db pokud: se prepne buffer, vim skonci atd.
    - nebo pokud se naplni kapacita bufferu --> tu nejak urcim, spocitam. Jde o to abych neodesilal request na sql server po kazdem keystroku ale proste to nejak flushnul
- **dulezite je taky jestli keystroky chapat jako textovy objekt nebo proste jako keystroke. Asi by bylo lepsi trackovat key prikazy v normal modu**

### mode session
- to same jako buffer, ale pro cas v jednotlivem modu


## Database structure
### text-buffer tracking
ID  |  file_name |  file_path  |  file_type  |    os    |  start_time  |  end_time  |
INT     TEXT        TEXT            TEXT         TEXT        TEXT           TEXT


