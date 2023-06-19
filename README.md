# Tchap stats

## Descriptions des tables et vues créées par ces scripts


### données brutes
* user_daily_visits : données globales de toutes les visites des utilisateurs avec leur type d'appareil. 68G lignes
* subscriptions_aggregate : 
* events_aggregate : 

### vues aggrégées
* daily_unique_user_count : (deprecated) vue aggrégées par jour des utilisateurs actifs par leur type d'appareil
* monthly_unique_user_count : (deprecated) vue aggrégées par mois des utilisateurs actifs par leur type d'appareil
* unique_user_daily_count_30d : //TODO
* user_monthly_visits : //TODO
* user_visit_summary : //TODO

* user_daily_visits_agg_XXX : vue aggrégée par jour des utilisateurs actifs par leur type d'appareil sur une période de temps
  * user_daily_visits_agg_30d
  * user_daily_visits_agg_120d
  * user_daily_visits_agg_1y
* user_daily_visits_by_month_YY : vue aggrégée par mois des utilisateurs actifs par leur type d'appareil sur une période de temps. 1y
  * user_daily_visits_by_month_1y



## fonctionnement
Job which fetches stats from an S3 bucket.

To run on scalingo, since there is no webapp, you need to scale the web container to 0 (otherwise scalingo complains that there is no webapp, or that the webapp crashed on startup) :

`scalingo --app my-app scale web:0:M`

See doc in https://doc.scalingo.com/platform/app/web-less-app

You may need to first create a dummy app to get the scalingo machine up (see [this commit](https://github.com/tchapgouv/tchap-stats/commit/ad9ab080922d8150e69dc224b87562898038f6b8)), then scale the web container to zero, then remove the dummy app.

Access the database

add your public ssh key to your scalingo profile
with a tunnel 

scalingo -a tchap-stats-prod db-tunnel SCALINGO_POSTGRESQL_URL
You can access your database on:
127.0.0.1:10000


## Create a local tunnel 
scalingo -a tchap-stats-prod db-tunnel --region osc-secnum-fr1 SCALINGO_POSTGRESQL_URL

## Connect to the machine
scalingo --region osc-secnum-fr1 -a tchap-stats-prod run bash 
