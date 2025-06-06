# Tchap stats

Ce projet permet de construire les tables dans : https://stats.tchap.incubateur.net/browse/2-tchap-stats

## Descriptions des tables et vues créées par ces scripts

## données brutes
Viennent des exports des base de données de Tchap
* user_daily_visits : données globales de toutes les visites des utilisateurs avec leur type d'appareil. aggrégé par jour. 68 milliard de lignes
* subscriptions_aggregate : données des nouvelles inscriptions
* events_aggregate : données des événements matrix
* account_data_aggregate : TODO

## vues matérialisées (materialized view)
Construites à partir des vues de données brutes. 
Elles permettent d'aggréger les données selon une ou deux dimensions ce qui accèlere le temps de traitement lors de la création des dashboard. 


### vue aggrégés de user_daily_visits

* user_daily_visits_agg_XXX : vue aggrégée par jour des utilisateurs actifs par leur type d'appareil (mobile ou web) sur une période de temps
  * user_daily_visits_agg_30d : les 30 derniers jours
  * user_daily_visits_agg_120d : les 120 derniers jours
  * user_daily_visits_agg_1y : la derniere année
* user_daily_visits_by_month_YY : vue aggrégée par mois des utilisateurs actifs par leur type d'appareil sur une période de temps. 1y
  * user_daily_visits_by_month_1y : la derniere année
  * user_daily_visits_by_month_18m : sur les 18 derniers mois


#### Deprecated
* daily_unique_user_count : (deprecated, too long to update) vue aggrégées par jour des utilisateurs actifs par leur type d'appareil
* monthly_unique_user_count : (deprecated, too long to update) vue aggrégées par mois des utilisateurs actifs par leur type d'appareil
* unique_user_daily_count_30d : //TODO
* user_monthly_visits : (deprecated, too long to update) use instead user_daily_visits_by_month_1y
* user_visit_summary : //TODO


## fonctionnement
Job which fetches stats from an S3 bucket.

To run on scalingo, since there is no webapp, you need to scale the web container to 0 (otherwise scalingo complains that there is no webapp, or that the webapp crashed on startup) :

`scalingo --app my-app scale web:0:M`

See doc in https://doc.scalingo.com/platform/app/web-less-app

You may need to first create a dummy app to get the scalingo machine up (see [this commit](https://github.com/tchapgouv/tchap-stats/commit/ad9ab080922d8150e69dc224b87562898038f6b8)), then scale the web container to zero, then remove the dummy app.

Access the database

Add your public ssh key to your scalingo profile
## Create a local tunnel 
- prod
```bash
scalingo -a tchap-stats-prod db-tunnel --region osc-secnum-fr1 SCALINGO_POSTGRESQL_URL
```

- preprod
```bash
scalingo -a tchap-stats-preprod db-tunnel SCALINGO_POSTGRESQL_URL
```

You can access your database on:
127.0.0.1:10000

## Connect to the machine
- prod
```bash
scalingo --region osc-secnum-fr1 -a tchap-stats-prod run bash 
```

- preprod
```bash
scalingo -a tchap-stats-preprod run bash 
```

### run an import manually 


```
# To import the file of the 2024-10-15 of user daily visits
extract_date=2024-10-15
time ./fetch_from_s3.sh user_daily_visits $extract_date
time psql -d $DATABASE_URL -f scripts/insert_user_daily_visits_data.sql
```

### run a pipeline manually

example : execute pipeline user_daily_visits on 2024-11-14 data
```
bash ./sync_data.sh 2024-11-14 user_daily_visits
```

## activate cron and deacticate web ps
do not work with review app

works with prod : 
scalingo --region osc-secnum-fr1 -a tchap-stats-prod scale web:0
scalingo --region osc-secnum-fr1 -a tchap-stats-prod scale cron:1
