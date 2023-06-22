import schedule
import time
import os

from job_sync_stats import job_sync_stats

def start_cron():
    # Essayez d'obtenir la valeur de la variable d'environnement 'CRON_SCHEDULE'
    # Si elle n'existe pas, utilisez une valeur par défaut ('01:00' par exemple)
    cron_schedule:str = os.getenv('CRON_SCHEDULE', '01:00')
    print(f"CRON SCHEDULE {cron_schedule}")
    schedule.every().day.at(cron_schedule).do(job_sync_stats)    

    while True:
        print("checking pending jobs...")
        schedule.run_pending()
        time.sleep(60)# the cron will check every second (to test) 


if __name__ == "__main__":
    start_cron()