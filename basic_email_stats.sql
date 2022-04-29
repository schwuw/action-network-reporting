SELECT gr.name AS "group",
       em.send_date AS "send date",
       em.subject AS "subject",
       em.from AS "from name",
       em.total_sent AS "total sent",
       em.actions_count AS "actions count",
       json_extract_path_text(em.stats, 'open') AS "opens",
       json_extract_path_text(em.stats, 'click') AS "clicks",
/*       json_extract_path_text(em.stats, 'unsub') AS "unsubscribes", */ -- There is no aggregate unsubscribe stat
       json_extract_path_text(em.stats, 'spam') AS "spam complaints",
       json_extract_path_text(em.stats, 'bounce') AS "bounces",
       -- Added a space to calculate the click rate of opened emails
       CASE WHEN clicks > 0 THEN (clicks/opens) * 100 
              ELSE 0 END AS click_rate
-- set to California Calls Action Network schema              
FROM calicalls_an.emails em
INNER JOIN calicalls_an.groups gr ON (gr.id = em.group_id)
WHERE em.status = 5 
-- Got an 'divide by zero error so added lines to ensure only looking at opened email
       AND opens > 0
-- Added a filter to only look at emails sent to over 1000 email addresses
       AND "total sent" > 1000
-- ordered by click rate descending
ORDER BY click_rate DESC
