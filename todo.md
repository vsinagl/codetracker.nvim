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
- [ ] fce pro extrakci filetype (pokud nazev obsahuje .)
    - vraci modul, ktery ma v sobe filepath ---> path fajlu vcetne jmena
    - a filetype --> typ fajlu (napr c, cpp, ruby atd....)

#### main structure
- [x] vyresit autocmd pro inactivitu
- [x] sql file for creating databases
- [x] sql Database class with apropriate functions
- [ ] unit test for Database methods
- [ ] event function
- [ ] testing the event function
    - *this function get all the buffer information and store them into table*
- [ ] session_input function
    - input is the table with all the session stats, this will run a query that will populate the main table

