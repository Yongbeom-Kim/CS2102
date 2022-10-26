/* ----- TRIGGERS     ----- */

-- Trigger 3
CREATE OR REPLACE FUNCTION check_min_reward_level()
RETURN TRIGGER AS $$
BEGIN
  IF NOT EXISTS (SELECT id FROM Rewards r WHERE r.id = NEW.id) THEN
    DELETE FROM Projects p WHERE p.id = NEW.id;
  END IF; RETURN NULL;
END; $$ LANGUAGE plpgsql;

DROP TRIGGER check_min_reward_level on Projects;
CREATE CONSTRAINT TRIGGER check_min_reward_level
AFTER INSERT ON Projects
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_min_reward_level();

-- Trigger 4
CREATE OR REPLACE FUNCTION check_refund_date()
RETURN TRIGGER AS $$
BEGIN
  IF ((SELECT request FROM Backs b WHERE b.email = NEW.email AND b.id = NEW.pid) IS NOT NULL
  AND ((SELECT request FROM Backs b WHERE b.email = NEW.email AND b.id = NEW.pid) > (SELECT deadline FROM Projects p WHERE p.id = NEW.pid) + 90 AND NEW.accepted = FALSE) 
      OR (SELECT request FROM Backs b WHERE b.email = NEW.email AND b.id = NEW.pid) <= (SELECT deadline FROM Projects p WHERE p.id = NEW.pid) + 90) THEN RETURN NEW;
  END IF; RETURN NULL;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_refund_date
BEFORE INSERT ON Refunds
FOR EACH ROW EXECUTE FUNCTION check_refund_date();

/* ----- PROECEDURES  ----- */
/* Procedure #1 */
CREATE OR REPLACE PROCEDURE add_user(
  email TEXT, name    TEXT, cc1  TEXT,
  cc2   TEXT, street  TEXT, num  TEXT,
  zip   TEXT, country TEXT, kind TEXT
) AS $$
-- add declaration here
BEGIN
  -- your code here
END;
$$ LANGUAGE plpgsql;



/* Procedure #2 */
CREATE OR REPLACE PROCEDURE add_project(
  id      INT,     email TEXT,   ptype    TEXT,
  created DATE,    name  TEXT,   deadline DATE,
  goal    NUMERIC, names TEXT[],
  amounts NUMERIC[]
) AS $$
-- add declaration here
BEGIN
  -- your code here
END;
$$ LANGUAGE plpgsql;



/* Procedure #3 */
CREATE OR REPLACE PROCEDURE auto_reject(
  eid INT, today DATE
) AS $$
-- add declaration here
BEGIN
  -- your code here
END;
$$ LANGUAGE plpgsql;
/* ------------------------ */





/* ----- FUNCTIONS    ----- */
/* Function #1  */
CREATE OR REPLACE FUNCTION find_superbackers(
  today DATE
) RETURNS TABLE(email TEXT, name TEXT) AS $$
-- add declaration here
BEGIN
  -- your code here
END;
$$ LANGUAGE plpgsql;



/* Function #2  */
CREATE OR REPLACE FUNCTION find_top_success(
  n INT, today DATE, ptype TEXT
) RETURNS TABLE(id INT, name TEXT, email TEXT,
                amount NUMERIC) AS $$
  SELECT 1, '', '', 0.0; -- replace this
$$ LANGUAGE sql;



/* Function #3  */
CREATE OR REPLACE FUNCTION find_top_popular(
  n INT, today DATE, ptype TEXT
) RETURNS TABLE(id INT, name TEXT, email TEXT,
                days INT) AS $$
-- add declaration here
BEGIN
  -- your code here
END;
$$ LANGUAGE plpgsql;
/* ------------------------ */