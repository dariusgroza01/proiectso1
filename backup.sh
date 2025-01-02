#!/bin/bash

PS3="Alegeti o optiune:"
select optiune in "Cauta fisier dupa data" "Optiune 2" "Optiune 3" "Iesire"; do
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
    "Optiune 2")
    echo "Ai selectat optiuena 2"
    ;;
    "Optiune 3")
    echo "Ai selectat optiunea umarul trei"
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