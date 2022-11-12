/* Function #1  */
CREATE OR REPLACE FUNCTION check_successful_project(
  pid INT,
  today DATE
) RETURNS BOOLEAN AS $$
BEGIN
  IF ((SELECT SUM(amount) FROM Backs b WHERE b.id = pid) 
    >= (SELECT p.goal FROM Projects p WHERE p.id = pid)
    AND today < (SELECT deadline FROM Projects p WHERE p.id = pid)
    AND (SELECT SUM(amount) FROM Backs b WHERE b.id = pid) IS NOT NULL) THEN
    RETURN TRUE; ELSE RETURN FALSE;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION find_superbackers(
  today DATE
) RETURNS TABLE(email TEXT, name TEXT) AS $$
DECLARE
  start_date DATE;
BEGIN
  start_date := today - interval '30 days';
  SELECT b.email, b.name
  FROM Backers b
  -- check verified
  WHERE EXISTS (SELECT 1 FROM Verifies v WHERE v.email = b.email)
  -- check 5 successful projects
  AND ((SELECT COUNT(*) 
    FROM Backs bk 
    JOIN Projects p ON bk.id = p.id 
    WHERE bk.email = b.email 
    AND p.deadline BETWEEN start_date AND today) >= 5
    AND (SELECT COUNT(DISTINCT p.ptype) FROM Backs bk 
      JOIN Projects p ON bk.id = p.id
      WHERE bk.email = b.email
      AND p.deadline BETWEEN start_date AND today) >= 3
    AND (SELECT check_successful_project(bk.id, today)) = TRUE)
  -- checks at least $1500
  OR (NOT EXISTS (SELECT SUM(amount)
    FROM Backs bk 
    WHERE (bk.email = b.email) 
    AND bk.id IN (SELECT p.id 
      FROM Projects p 
      WHERE (SELECT SUM(amount) 
        FROM Backs bk
        GROUP BY bk.id
        HAVING bk.id = p.id) > p.goal) 
        GROUP BY bk.email) >= 1500
    AND (SELECT 1 
      FROM Refunds r 
      WHERE b.email = r.email 
      AND r.deadline 
      BETWEEN start_date AND today)
    AND (SELECT check_successful_project(bk.id, today)) = TRUE);
END;
$$ LANGUAGE plpgsql;