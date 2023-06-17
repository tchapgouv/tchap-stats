# Tchap stats

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

Running queries
https://db-osc-secnum-fr1.scalingo.com/dashboard/61f97a20db4d083c9fad26b2/pg-running-queries


S3 : 
https://www.ovh.com/manager/#/public-cloud/pci/projects/ccb5cc4e86ab47df85f500708f4906f8/storages/objects/64474e6f595841746333526864484d746257563059574a686332557552314a42