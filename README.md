# Scripts
 Various automation scripts

libacvp.sh - сборка и установка клиента acvp.

# Добавление проета "libacvp" в Eclipse.

1. Создаём рабочую директорию, например 
      /home/admin1/work/acvp/.

2. Переписываем в неё скрипт libacvp.sh.

       
3. Запускаем скрипт libacvp.sh.

4. Переходим в директорию  /home/admin1/work/acvp/ и видим директорию: 
            ACVP_PROJECT 
                    - ARCHIVE;
                    - INSTALLATION;
                    - SOURCE.

5. Запускаем Eclipse.

6. Выбираем "Workspace", например:
    /home/admin1/work/acvp/ACVP_PROJECT. и жмём "Launch".

7. Идём в меню настроек и выбираем: 
    "File -> New -> Makefile Project With Existing Code".
    
8.  В диалоге "import Existing Code" выбираем "Existing Code Location"
    и устанавливаем следующий путь:
    
    /home/admin1/work/acvp/ACVP_PROJECT/SOURCE/libacvp;
    Далее выбираем "Toolchain for Indexer Settings" 
        Linux GCC 
        и жмём "Finish".

9. Идём в "Project -> Properties";
    
    В диалоге "Properties for libacvp" выбираем "C/C++ Build".
    
    В диалоге C/C++ Build выбираем 
        "Configuration" -> "Default [Active]".
        
    И выбираем вкладку "Behavior"
    
    Во Frame "Workbench build Behavior" устанавливаем checkbox 
    "Build (Incremental build)" и оставляем EditBox пустым
    (По умолчанию там прописано "all"). 
      
10. Идём в "Run -> Run Configuration";
    
11. В диалоге "Run configuration" дважды кликаем на
     "C/C++ Application", появляется конфигурация "libacvp Default".

     Во вкладке "Main -> C/C++ Application" устанавливаем путь к 
     исполняемому файлу:
     /home/admin1/work/acvp/ACVP_PROJECT/INSTALLATION/
                                        /libacvp_install/bin/acvp_app.
     
     Во вкладке "Arguments" пишем:
        --all_algs. 

     Во вкладке "Environment" пишем:
        ACV_PORT  -> 8000;
        ACV_SERVER -> 127.0.0.1.
    
    Жмём "Apply".

12.  Запускаем "Run libacvp Default", всё должно работать!        
                         
        