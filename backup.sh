#!/bin/bash

locatie_cloud=$(pwd)

PS3="Alegeti o optiune:"
select optiune in "Cauta fisier dupa data" "Mutare fisiere" "CronJob 60 zile maintenance" "Iesire"; do
  case $optiune in
    "Cauta fisier dupa data")
    read -p "Introduceti numele directorului: " directory

    if [[ ! -d "$directory" ]]; then
    echo "Directorul '$directory' nu exista."
    exit 1
    fi
    read -p "Introduceti data de filtrare (YYYY-MM-DD) sau numarul de zile/saptamani/luni (ex.: 5d, 2w, 3m): " date_of_file

    # Function to calculate relative dates
    calculator_data() {
    local tip_timp="${1: -1}"   # Extragem ultimul caracter din sirul de caractere introdus, adica zile(d), saptamani(w) sau luni(m)
    local numar_unitati="${1%?}"    # Extragem tot pana la ultimul caracter, ca sa stim cantitatea de timp

    # Validam ca sirul de caractere pana la ultimul carcter sunt numere
    if ! [[ "$numar_unitati" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid relative time format. Use <number>d, <number>w, or <number>m."
        exit 1
    fi

    # Calculam data in functie de variabila tip_timp
    case "$tip_timp" in
        d) date --date="-$numar_unitati days" +"%Y-%m-%d" ;;
        w) date --date="-$((numar_unitati * 7)) days" +"%Y-%m-%d" ;;
        m) date --date="-$numar_unitati months" +"%Y-%m-%d" ;;
        *)
        echo "Tipul de timp nu este suportat '$tip_timp'. Folositi: 'd' pentru zile, 'w' pentru saptamani sau 'm' pentru luni."
        exit 1
        ;;
    esac
    }

    # Determinam tipul de data introdus
    if [[ "$date_of_file" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    # Data calendaristica:
    search_date="$date_of_file"
    elif [[ "$date_of_file" =~ ^[0-9]+[dwm]$ ]]; then
    # Unitate de timp introdusa:
    search_date=$(calculator_data "$date_of_file")
    else
    echo "Input invalid! Folositi YYYY-MM-DD pentru data calendaristica sau <numar>d, <numar>w, <numar>m pentru timp relativ."
    exit 1
    fi

    # Cautam fisierele in fucntie de data calculata in directorul cerut
    echo "Fisiere mai vechi decat: $search_date in $directory:"
    find "$directory" -type f ! -newermt "$search_date" -print
    ;;
    "Mutare fisiere")
    echo "Selectati locatia: 1)Local sau in 2)Cloud"
    read locatie
    case "$locatie" in
      1)
      echo "Ati selectat Local"
      read -p "Introduceti directorul unde doriti sa navigati:" dir_src_file
      if [ -d $dir_src_file ]; then
       echo "Dir-ul exista"
       cd $dir_src_file && ls -la 
       read -p "Introduceti numele fisierului: " nume_fisier
       if [ -f $nume_fisier ]; then
        read -p "Introduce destinatia fisierului pe care doriti sa i-l mutati: " dest_fisier
            if [ -d $dest_fisier ];then
                mv $nume_fisier $dest_fisier
                echo "Fisierul $nume_fisier a fost mutat in $dest_fisier"
            else 
                echo "Fisierul destinatie nu exista"
                continue
            fi        
        else
        echo "Fisierul $nume_fisier nu se afla in acest director"
        continue
       fi
      else
       echo "Directorul in care vreti sa navigati nu exista"
       continue
      fi
       ;;      
       2)
        echo "Ati selctat in Cloud"
        read -p "Introduceti directorul unde doriti sa navigati:" dir_src_file
        if [ -d $dir_src_file ]; then
          cd $dir_src_file && ls -la
          read -p "Introduceti numele fisierului pe care doriti sa i-l uploadati in cloud(git): " fisier_git
          if [ -f $fisier_git ]; then
           mv $fisier_git $locatie_cloud
           cd $locatie_cloud
           git add $fisier_git && git commit -m "Upload of $fisier_git" && git push
           echo "Fisierul $fisier_git a fost uploadat cu succes in GitHub"
          else
           echo "Fisierul $fisier_git nu se afla in aceasta locatie"
           continue
          fi
        else
         echo "Directorul in care vreti sa navigati nu exista"
         continue
        fi
        ;;
       *)
       echo "Optiune de mutare invalida"
       continue
       ;;
    esac
    ;;
    "CronJob 60 zile maintenance")
    add_cronjob() {
  local path="$1"

  if [[ ! -d "$path" ]]; then
    echo "Directorul $path nu exista"
    exit 1
  fi

  # Definim Cron Job-ul
  local job="0 20 * * 1 find $path -type f -mtime +60 -delete #delete_old_files"

  # Adaugam Cron Job-ul daca inca nu exista
  if crontab -l 2>/dev/null | grep -q "#delete_old_files"; then
    echo "Cron job-ul deja exista"
  else
    (crontab -l 2>/dev/null; echo "$job") | crontab -
    echo "Cron job adaugat cu succes"
  fi
}


remove_cronjob() {
  # Stergem Cron Job-ul cu comentariul #delete_old_files
  crontab -l 2>/dev/null | grep -v "#delete_old_files" | crontab -
  echo "Cron job sters cu succes."
}


echo "Alegeti Optiune pentru CronJob de stergere a fisierlor mai vechi de 60 zile"
echo "1.Adaugare CronJob"
echo "2.Stergere CronJob"
read -p "Alegeti optiune: " choice

case $choice in
  1)
    read -p "Introduceti directorul pentru cronjob: " dir
    add_cronjob "$dir"
    ;;
  2)
    remove_cronjob
    ;;
  *)
    echo "Alegere invalida"
    continue
    ;;
esac
    ;;
    "Iesire")
    echo "Iesire program..."
    exit
    ;;
    *)
    echo "Optiune invalida"
    ;;
  esac
done