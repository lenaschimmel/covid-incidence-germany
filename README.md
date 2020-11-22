# covid-incidence-germany
_This project can be used as-is, but is has been created to work in conjunction with [riskjournal](https://github.com/lenaschimmel/riskjournal)._

A simple (but inefficient) bash script to generate weekly incidence data for each administrative district (Landkreis)

## Use case
The Robert Koch Institut (short: RKI) provides daily stats on the Covid-19 infections in Germany. They are available via ArcGIS [as API](https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0) and [as a CSV download](https://www.arcgis.com/home/item.html?id=f10774f1c63e40168479a1feb6c7ca74). The data is also [archived by the NDR as CSV](https://github.com/NorddeutscherRundfunk/corona_daten "Norddeutscher Rundfunk - Northern German Broadcast") and [by the ARD as JSON](https://github.com/ard-data/2020-rki-archive "Arbeitsgemeinschaft der öffentlich-rechtlichen Rundfunkanstalten der Bundesrepublik Deutschland – Working group of public broadcasters of the Federal Republic of Germany").

All of these data sources contain a lot of details, even up to individual infection cases.

The political discurse in Germany around Covid-19, as well as many tools (like [Microcovid](https://www.microcovid.org)) operate with _incidence data_, specifically with the number of new Covid-19 cases per 100.000 inhabitants during the past 7 days, for each administrative district (Landkreis). **It seems that this incidence data is not readily available anywhere.**

_Note: during the (late) devlopment of this script, I learned about [rki-covid-api](https://github.com/marlon360/rki-covid-api) which offers this data, but as far as I can tell, only the most current data. For another project, I need data for past days/weeks, so I continued working on this script._

## Requirements
You can either run this script:
 * using Docker
   * e.g. like this: `docker build -t cig . && docker run cig`
   * the docker version uses a `cron` job to update the data every 4 hours
 * directly, if you are on a unix-like system and have:
   * `curl`
   * `gzip`
   * `bash`
   * a version of `date` that understands the `-d` flag as described [here](https://man7.org/linux/man-pages/man1/date.1.html), e.g. the _coreutils_ version
   
## Output
_To be improved, and then documented. Currently there's only a bunch of csv files._

## Known issues
 * The script is very slow. It takes about 40 minutes on a 2017 MacBook Pro to complete.
