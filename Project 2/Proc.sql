/* ----- TRIGGERS     ----- */
-- Q1
CREATE OR REPLACE FUNCTION check_user()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT (EXISTS (SELECT email FROM Backers b WHERE b.email = NEW.email) OR EXISTS (SELECT email FROM Creators c WHERE c.email = NEW.email)) THEN
    DELETE FROM Users u WHERE u.email = NEW.email;
  END IF; RETURN NULL;
END; $$ LANGUAGE plpgsql;

DROP TRIGGER Q1 on Users;
CREATE CONSTRAINT TRIGGER Q1
AFTER INSERT ON Users
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_user();

-- Q2
CREATE OR REPLACE FUNCTION check_min_amt()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.amount >= (SELECT min_amt FROM Rewards r WHERE r.name = NEW.name AND r.id = NEW.id)) THEN
    RETURN NEW;
  END IF; RETURN NULL;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER Q2
BEFORE INSERT ON Backs
FOR EACH ROW EXECUTE FUNCTION check_min_amt();

/* Trigger 5*/
CREATE OR REPLACE FUNCTION check_back() 
RETURNS TRIGGER AS $$ 
DECLARE 
created DATE;
back_date DATE;
min_amt NUMERIC;

BEGIN
SELECT p.deadline, p.created INTO back_date, created
FROM Projects AS p
WHERE id = NEW.id;

SELECT r.min_amt INTO min_amt
FROM Rewards as r
WHERE id = NEW.id AND name = NEW.name;

IF (created <= NEW.backing)
AND (NEW.backing <= back_date)
AND (min_amt is not null)
THEN RETURN NEW;

ELSE RETURN NULL;

END IF;

END;

$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER back_project 
BEFORE INSERT OR UPDATE ON Backs 
FOR EACH ROW EXECUTE FUNCTION check_back();

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