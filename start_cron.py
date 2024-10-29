import schedule
import time
import os

from job_sync_stats import job_sync_stats

def start_cron():
    # Essayez d'obtenir la valeur de la variable d'environnement 'CRON_SCHEDULE'
    # Si elle n'existe pas, utilisez une valeur par défaut ('01:00' par exemple) UTC
    cron_schedule:str = os.getenv('CRON_SCHEDULE', '01:00')
    force_sync_at_start:bool = os.getenv('FORCE_SYNC_AT_START', False)

    #if wanted, launch the sync stats process when container is restarted
    if force_sync_at_start:
        try: 
            job_sync_stats()
        except:
            print(f"job_sync_stats job has failed")


    print(f"CRON SCHEDULE {cron_schedule}")
    schedule.every().day.at(cron_schedule).do(job_sync_stats)    

    while True:
        schedule.run_pending()
        time.sleep(3600)# the cron will check every hour if a jobs need to be executed
        


if __name__ == "__main__":
    start_cron()