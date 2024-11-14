import subprocess

def job_sync_stats():

    # Liste des scripts à exécuter
    scripts = ['sync_data.sh']

    for script in scripts:
        print(f"|||| Executing script {script} |||")
        # Exécute chaque script
        subprocess.run(['./' + script])