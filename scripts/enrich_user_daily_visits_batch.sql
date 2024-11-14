DO $$
DECLARE
    batch_size INT := 10000;        -- Taille de chaque batch
    rows_affected INT := 0;      -- Nombre de lignes affectées par batch
    total_rows_updated INT := 0; -- Compteur de lignes mises à jour au total
    max_row INT := 1000000;          -- Nombre maximum de lignes à traiter
    start_time TIMESTAMP;        -- Heure de début de l'exécution
    end_time TIMESTAMP;          -- Heure de fin de l'exécution
    elapsed_time INTERVAL;       -- Intervalle du temps écoulé
BEGIN
    -- Démarrer la mesure du temps
    start_time := clock_timestamp();

    -- Boucle pour mettre à jour par batch
    LOOP
        -- Met à jour par lot de batch_size lignes à la fois
        WITH batch AS (
            SELECT ctid
            FROM user_daily_visits
            WHERE platform IS NULL  -- Ne sélectionne que les lignes qui ne sont pas encore mises à jour
            LIMIT batch_size
        )
        UPDATE user_daily_visits
        SET platform = CASE
                WHEN user_agent LIKE 'Mozilla%' THEN 'Web'
                WHEN user_agent LIKE 'Tchap%Android%' THEN 'Mobile'
                WHEN user_agent LIKE 'RiotNSE/2%iOS%' THEN 'Mobile'
                WHEN user_agent LIKE 'RiotSharedExtension/2%iOS%' THEN 'Mobile'
                WHEN user_agent LIKE 'Tchap%iOS%' THEN 'Mobile'
                WHEN user_agent LIKE 'Riot%iOS' THEN 'Mobile'
                WHEN user_agent LIKE 'Riot%Android' THEN 'Mobile'
                WHEN user_agent LIKE 'Element%Android' THEN 'Mobile'
                WHEN user_agent LIKE 'Element%iOS' THEN 'Mobile'
                ELSE 'Autre'
            END,
            device_type = CASE
                WHEN user_agent LIKE 'Mozilla%Windows%Firefox%' THEN 'Firefox Windows'
                WHEN user_agent LIKE 'Mozilla%Windows%Chrome%' THEN 'Chrome Windows'
                WHEN user_agent LIKE 'Mozilla%Windows%Trident%' THEN 'Internet Explorer Windows'
                WHEN user_agent LIKE 'Mozilla%Mac OS%Firefox%' THEN 'Firefox Mac OS'
                WHEN user_agent LIKE 'Mozilla%Mac OS%Chrome%' THEN 'Chrome Mac OS'
                WHEN user_agent LIKE 'Mozilla%Mac OS%Safari%' THEN 'Safari Mac OS'
                WHEN user_agent LIKE 'Mozilla%Android%Firefox%' THEN 'Firefox Android'
                WHEN user_agent LIKE 'Mozilla%Android%Chrome%' THEN 'Chrome Android'
                WHEN user_agent LIKE 'Mozilla%Linux%Firefox%' THEN 'Firefox Linux'
                WHEN user_agent LIKE 'Mozilla%Linux%Chrome%' THEN 'Chrome Linux'
                WHEN user_agent LIKE 'Mozilla%CrOS%Chrome%' THEN 'Chrome OS'
                WHEN user_agent LIKE 'Mozilla%Mobile%' THEN 'Navigateur Mobile'
                WHEN user_agent LIKE 'Mozilla%' THEN 'Autre Navigateur'
                WHEN user_agent LIKE 'Tchap%NEO%' THEN 'Tchap Android NEO'
                WHEN user_agent LIKE 'Tchap%Android%' THEN 'Tchap Android'
                WHEN user_agent LIKE 'RiotNSE/2%iOS%' THEN 'Tchap iOS'
                WHEN user_agent LIKE 'RiotSharedExtension/2%iOS%' THEN 'Tchap iOS'
                WHEN user_agent LIKE 'Tchap%iOS%' THEN 'Tchap iOS'
                WHEN user_agent LIKE 'Riot%' THEN 'Element'
                WHEN user_agent LIKE 'Element%' THEN 'Element'
                ELSE 'Autre'
            END
        WHERE ctid IN (SELECT ctid FROM batch);

        -- Récupérer le nombre de lignes affectées par cette mise à jour
        GET DIAGNOSTICS rows_affected = ROW_COUNT;

        -- Augmenter le compteur total avec le nombre de lignes mises à jour
        total_rows_updated := total_rows_updated + rows_affected;

        RAISE NOTICE 'rows updated: %/%', total_rows_updated, max_row;

        -- Sortir de la boucle si aucune ligne n'a été affectée (c'est-à-dire, tout a été mis à jour)
        EXIT WHEN rows_affected = 0;

        -- Sortir de la boucle si nous avons atteint ou dépassé le max_row
        EXIT WHEN total_rows_updated >= max_row;
    END LOOP;

    -- Finir la mesure du temps
    end_time := clock_timestamp();

    -- Calcul du temps écoulé
    elapsed_time := end_time - start_time;

    -- Optionnel : Affiche le nombre de lignes traitées dans l'exécution
    RAISE NOTICE 'Total rows updated: %', total_rows_updated;

    -- Afficher le temps pris pour l'exécution
    RAISE NOTICE 'Elapsed time: %', elapsed_time;
END $$