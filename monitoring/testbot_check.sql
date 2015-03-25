SELECT
  FROM_UNIXTIME(MAX(pl.timestamp)) AS `Last Activity`,
  MAX(pl.timestamp)                AS `lasttimestamp`,
  pl.client_id,
  pc.url
FROM pifr_log pl
  LEFT JOIN pifr_client pc ON pc.client_id = pl.client_id
WHERE pc.client_id IS NOT NULL
      AND pc.status = 4
      AND pc.type = 2
GROUP BY pl.client_id
HAVING lasttimestamp < (unix_timestamp() - 60 * 60 * 1)
ORDER BY lasttimestamp;
