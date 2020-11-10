#!/bin/bash
set -e
# make sure that relative paths are relative to the location of this script
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $SCRIPTPATH

rm -rf output
rm -rf tmp

curl -o covid_19_daily_latest.tsv.gz https://storage.googleapis.com/public.ndrdata.de/rki_covid_19_bulk/daily/covid_19_daily_latest.tsv.gz
gzip -f -d covid_19_daily_latest.tsv.gz
xsv index covid_19_daily_latest.tsv

# compile a list of all IdLandkreis values
xsv frequency -s IdLandkreis -l 0 covid_19_daily_latest.tsv | xsv select 2 | tail -n +2 > IdLandkreis.csv

# compile a list of all Altersgruppe values
xsv frequency -s Altersgruppe -l 0 covid_19_daily_latest.tsv | xsv select 2 | tail -n +2 > Altersgruppe.csv

# Read each line, which contains one IdLandkreis
while read ID; do
    mkdir -p tmp/$ID
    
    # Find the name matching the IdLandkreis, then output it to the console and into a file
    LANDKREIS=`xsv search -s KrS $ID basisdaten.csv | xsv select Landkreis | tail -n +2`
    EINWOHNER=`xsv search -s KrS $ID basisdaten.csv | xsv select Einwohner | tail -n +2`
    echo "$ID: Landkreis $LANDKREIS mit $EINWOHNER Einwohnern"
    echo $LANDKREIS > tmp/$ID/name

    # Filter all lines of this Landkreis into a single file, which we can then use 14 times to get the lines for the specific date
    xsv search -s IdLandkreis $ID covid_19_daily_latest.tsv > tmp/$ID/all
    xsv index tmp/$ID/all

    # Compute weekly data for a lot of past days (more exactly: for the weeks before each of those days)
    for p in {1..28}
    do
        REFDATE=`date -d "-${p} days" +"%Y-%m-%d"`
        # echo "Computing data for $REFDATE, which was $p days ago"

        mkdir -p output/$REFDATE

        if [ ! -f output/$REFDATE/resultByAltersgruppe.csv ]; then
            echo "IdLandkreis,Landkreis,Altersgruppe,Inzidenz" > output/$REFDATE/resultByAltersgruppe.csv
            echo "IdLandkreis,Landkreis,Inzidenz" > output/$REFDATE/resultSum.csv
        fi

        # truncate the  file, because we will append to it later
        : > tmp/$ID/currentWeek

        for i in {0..6}
        do
            DATE=`date -d "-${i} days -${p} days" +"%Y-%m-%d"`
            xsv search -s Meldedatum $DATE tmp/$ID/all | xsv select Altersgruppe,AnzahlFall | tail -n +2 >> tmp/$ID/currentWeek
        done

        # Now tmp/$ID/currentWeek contains all the lines for the current Landkreis and the selected week

        SUM_CURR=0
        #SUM_PREV=0
        while read ALTERSGRUPPE; do
            INC_CURR=`xsv search -s 1 $ALTERSGRUPPE tmp/$ID/currentWeek  | xsv stats | xsv select sum | tail -n +3`
            
            # if no matching rows were found, the variables will contain two quotes. Let's replace this with 0.
            if [ $INC_CURR = "\"\"" ]; then
                INC_CURR=0
            fi
            
            INC_CURR=$((INC_CURR*100000/EINWOHNER))
            
            echo "$ID,$LANDKREIS,$ALTERSGRUPPE,$INC_CURR" >> output/$REFDATE/resultByAltersgruppe.csv
            SUM_CURR=$((SUM_CURR+INC_CURR))
        done <Altersgruppe.csv
        echo "$ID,$LANDKREIS,$SUM_CURR" >> output/$REFDATE/resultSum.csv
    done
done <IdLandkreis.csv

rm -rf tmp
echo "Fertig"