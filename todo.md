# WORK IN PROGRES
## KANBAN TASKS

### first test
- [-] funkce pro vytvoreni tabulky buf_sessions
        need to rewrite this
- [x] funkce pro vkladani zaznamu do buf_sessions
- [x] test komunikace s nvimem --> vytvorit helloWorld command!
- [x] events functions test

### building the thing
#### Lua functions
- [x] fce pro extrakci filetype (pokud nazev obsahuje .)
    - vraci modul, ktery ma v sobe filepath ---> path fajlu vcetne jmena
    - a filetype --> typ fajlu (napr c, cpp, ruby atd....)

#### main structure
- [x] vyresit autocmd pro inactivitu
- [x] sql file for creating databases
- [x] sql Database class with apropriate functions
- [x] unit test for Database methods
- [x] event function
- [x] testing the function
- [x] session_input function
    - input is the table with all the session stats, this will run a query that will populate the main table


# ToDo
- [x] -nacitani gitacke slozky
- [x] - potom co se session vypne by se z end tajmu melo odecist 20s (resp. doba inaktivity)
- [x] error when creating new db from scratch !
- [x]  NULL values inside the testing_db, how does they happen ?
    - it's from the telescope buffers --> how to solve it ?
        1. option is to let it be as it is and filter this fields in query
        2. option is to don't save the record when filetype is nil
        3. options is to add special filename when the filetype is nil (as popup window for example)
- [x] simple README.md with structure
- [x] create db
    - put create_db.lua into db.lua
    - test db creation
- [ ] sessions upload - new tables (sessions, projects, repos)
- [ ]  remote repo and working MVP

- [ ] foregin key remote repo  pro primary key v projects ?
    - pridat remote repo jako foregin key a neukladat tak dlouho adresu stringu ale pouze ID projektu.
    - ale tohle asi seru
- [ ] popoup window se summary z databaze.
- [ ] command pro manualni pridani projektu
- [ ] command pro manualni pridani projektu
- [ ] tabulka pro manualni trackovani casu stravenych na projektech


# Errors and Issues
- [ ] Issue: pridat do filetypes textove soubory (txt, md, yaml, toml). Programovaci maji prohozeny sloupec lang_type za is_lang (boolean)
        - nove zaznamy neznamych filetypu maji mit is_lang = 0 (false) !


# TEST
- otestovat rychle prepinani  mezi jednotlivmi sessiony, ukladaji se data vporadku ?
- update 30.11.2024 vypada to ze funguje vklidu ? chtelo by to vice testu


# ZMENY !!
- databazove pole duration se jiz nepouziva: je redundatni (dopocte se ze start_time a end_time pomoci quericek


# WORK LOGS
6.9 ✅ - casy, mam bordel v jednotkach (viz config -> inactivity period a min_inactivity) neco je v ms, neco v s --> sjednotit
       - rozdeleni create records na dve funkce -> jedna se sepne po vyprseni limitu inactivity --> zkontrolovat a otestovat ze funguje
       - hodnoty kdy end_time - start_time < 1 jsou nepripustne --> zkontrolovat
+++++++++++
6.9 - testovani,  hlaseni chyb
    - code reporting
++++++++++
12.9 - testovani, inicializace databaze, tabulka repos a automaticka integrace --> repo pomoci ciziho klice
++++++
13.9 
- [ ] generace most common text files (yaml, md etc..)
SHRNUTI: novy db layout + funkcni vkladani zaznamu
je treba testovat pri pouzivani a zapisovat bugy
++++++






