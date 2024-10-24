-- LEVEL 1

-- Question 1: Number of users with sessions

SELECT COUNT(DISTINCT user_id)
FROM sessions;

-- Question 2: Number of chargers used by user with id 1

-- Assumed required distinct chargers

SELECT COUNT(DISTINCT charger_id) AS num_chargers
FROM sessions
WHERE user_id = 1;

-- LEVEL 2

-- Question 3: Number of sessions per charger type (AC/DC):

SELECT chargers.type, COUNT(sessions.id)
FROM sessions JOIN chargers ON sessions.charger_id = chargers.id
GROUP BY chargers.type;

-- Question 4: Chargers being used by more than one user

-- Assumed not simultaneouly

WITH users_chargers AS (
    SELECT users.id AS user_id, chargers.id AS charger_id, chargers.label
    FROM users JOIN sessions ON users.id = sessions.user_id
            JOIN chargers ON sessions.charger_id = chargers.id
)
SELECT label, count(user_id) AS user_count
FROM users_chargers
GROUP BY charger_id
HAVING user_count > 1;

-- Question 5: Average session time per charger

-- Since no specific time units are required, I opt to express the session time in seconds.

WITH charger_session_time AS (
    SELECT sessions.charger_id,
           (UNIXEPOCH(sessions.end_time) -
            UNIXEPOCH(sessions.start_time)) AS seconds
    FROM sessions
)
SELECT label, AVG(seconds)
FROM chargers JOIN charger_session_time ON id = charger_id
GROUP BY charger_id;


-- LEVEL 3

-- Question 6: Full username of users that have used more than one charger in one day (NOTE: for date only consider start_time)

-- I assume that the requirement is to use more than one *different* charger in one day

SELECT DISTINCT name || ' ' || surname FROM 
    (SELECT name, surname, DATE(start_time) AS day,
            COUNT(DISTINCT charger_id) AS num_chargers
    FROM sessions JOIN users ON sessions.user_id = users.id
    GROUP BY user_id, day
    HAVING num_chargers > 1) AS users_using_multiples_chargers_per_day;


-- Question 7: Top 3 chargers with longer sessions

WITH charger_session_time AS (
    SELECT charger_id,
           (UNIXEPOCH(sessions.end_time) -
            UNIXEPOCH(sessions.start_time)) AS seconds
    FROM sessions
)
SELECT charger_id, label, seconds,
       RANK() OVER (ORDER BY seconds DESC) as ranked
FROM charger_session_time JOIN chargers ON charger_id = chargers.id
LIMIT 3;


-- Question 8: Average number of users per charger (per charger in general, not per charger_id specifically)

-- The following answer assumes that this requirement refers to the average number of users per day for each charger type.
-- About the day, it considers the start_time as in the previous question.

WITH charger_types_dates AS (
    SELECT chargers.type AS charger_type,
           DATE(start_time) as day,
           COUNT(user_id) as num_users
    FROM sessions JOIN chargers ON sessions.charger_id = chargers.id
    GROUP BY charger_type, day
)
SELECT charger_type, AVG(num_users)
FROM charger_types_dates
GROUP BY charger_type;


-- Question 9: Top 3 users with more chargers being used

WITH user_num_chargers AS (
    SELECT user_id, COUNT(charger_id) AS num_chargers
    FROM sessions
    GROUP BY user_id
)
SELECT name, surname, num_chargers,
       RANK() OVER(ORDER BY num_chargers DESC)
FROM users JOIN user_num_chargers ON users.id = user_id
LIMIT 3;


-- LEVEL 4

-- Question 10: Number of users that have used only AC chargers, DC chargers or both

-- I assume it requires classification of the users in AC_only, DC_only, both

WITH user_type_charger AS (
    SELECT DISTINCT user_id, chargers.type AS charger_type
    FROM sessions JOIN chargers ON sessions.charger_id = chargers.id
),
    users_num_chargers AS (
    SELECT user_id, COUNT(charger_type) AS num_chargers
    FROM user_type_charger
    GROUP BY user_id
),
    users_with_both_chargers AS (
        SELECT user_id FROM users_num_chargers WHERE num_chargers = 2
),
    users_with_AC AS (
        SELECT user_type_charger.user_id
        FROM user_type_charger JOIN users_with_both_chargers ON user_type_charger.user_id != users_with_both_chargers.user_id
        WHERE charger_type = 'AC'
)
SELECT DISTINCT name, surname,
        CASE
        WHEN user_id in (SELECT user_id FROM users_with_both_chargers) THEN 'both'
        WHEN user_id in (SELECT user_id FROM users_with_AC) THEN 'AC_only'
        ELSE 'DC_only'
        END AS category
FROM users JOIN sessions ON users.id = user_id;


-- Question 11: Monthly average number of users per charger

-- Since all the entries in the dataset are from the same year-month, this
-- query won't produce any observable differences compared to query #8

WITH charger_dates_users AS (
    SELECT charger_id,
           STRFTIME('%Y-%m', start_time) as month,
           COUNT(user_id) as num_users
    FROM sessions JOIN chargers ON sessions.charger_id = chargers.id
    GROUP BY charger_id, month
)
SELECT charger_id, label, AVG(num_users)
FROM charger_dates_users JOIN chargers ON charger_id = chargers.id
GROUP BY charger_id;


-- Question 12: Top 3 users per charger (for each charger, number of sessions)

-- The three users with more sessions per charger

WITH charger_user_sessions AS (
    SELECT charger_id, user_id, COUNT(sessions.id) as num_sessions
    FROM sessions
    GROUP BY charger_id, user_id
), ranked_charger_users AS (
    SELECT charger_id, user_id, num_sessions,
            RANK() OVER (PARTITION BY charger_id ORDER BY num_sessions DESC) AS ranked
    FROM charger_user_sessions
)
SELECT label, name, surname, num_sessions, ranked
FROM ranked_charger_users JOIN chargers ON charger_id = chargers.id
                          JOIN users ON user_id = users.id
WHERE ranked <= 3;


-- LEVEL 5

-- Question 13: Top 3 users with longest sessions per month (consider the month of start_time)

WITH users_month_duration AS (
    SELECT user_id, 
           STRFTIME('%Y-%m', start_time) as month, 
           (UNIXEPOCH(sessions.end_time) - UNIXEPOCH(sessions.start_time)) AS seconds
    FROM users JOIN sessions ON users.id = user_id
), month_users_max_duration AS (
    SELECT month, user_id, MAX(seconds) max_duration
    FROM users_month_duration
    GROUP BY month, user_id
), ranked_duration AS (
    SELECT month, user_id, max_duration,
            RANK() OVER(ORDER BY max_duration DESC) AS ranked
    FROM month_users_max_duration
)
SELECT month, name, surname, max_duration, ranked
FROM ranked_duration JOIN users ON user_id = users.id
WHERE ranked <= 3;


-- Question 14. Average time between sessions for each charger for each month (consider the month of start_time)

-- I interpret the requirement is to find the average session duration, for each charger and month.

WITH charger_month_duration AS (
    SELECT charger_id,
        STRFTIME('%Y-%m', start_time) as month, 
        (UNIXEPOCH(sessions.end_time) - UNIXEPOCH(sessions.start_time)) AS seconds
    FROM chargers JOIN sessions ON chargers.id = charger_id
), month_charger_avg AS (
    SELECT month, charger_id, AVG(seconds) avg_duration
    FROM charger_month_duration
    GROUP BY month, charger_id
)
SELECT month, label, avg_duration
FROM month_charger_avg JOIN chargers ON charger_id = chargers.id;
