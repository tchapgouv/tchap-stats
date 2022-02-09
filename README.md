# Tchap stats

Job which fetches stats from an S3 bucket.

To run on scalingo, since there is no webapp, you need to scale the web container to 0 (otherwise scalingo complains that there is no webapp, or that the webapp crashed on startup) :

`scalingo --app my-app scale web:0:M`

See doc in https://doc.scalingo.com/platform/app/web-less-app

You may need to first create a dummy app to get the scalingo machine up (see [this commit](https://github.com/tchapgouv/tchap-stats/commit/ad9ab080922d8150e69dc224b87562898038f6b8)), then scale the web container to zero, then remove the dummy app.