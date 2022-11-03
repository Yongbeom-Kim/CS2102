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


/* Trigger 6 */
/* 6. Backers can only request for refund on successful projects. You need to
create an UPDATE trigger here. You may assume that the only change is
to set the Backs.backing from NULL to non-NULL values.
*/
CREATE OR REPLACE FUNCTION check_successful()
RETURNS TRIGGER AS $$

DECLARE
project_backed RECORD;
amt_pleged INT;

BEGIN
project_backed := (SELECT * FROM Projects where id = OLD.id);
amt_pleged := (SELECT SUM(amount) FROM Backs b where b.id = project_backed.id);

if (amt_pleged < project_backed.goal OR project_backed.deadline < CURRENT_DATE)
  THEN RETURN NULL;

END IF;

END;
$$ language plpgsql;

CREATE OR REPLACE TRIGGER refund_only_successful
BEFORE UPDATE ON Backs
FOR EACH ROW 
  WHEN ((OLD.request IS NULL) AND (NEW.request IS NOT NULL))
  EXECUTE FUNCTION check_successful();


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
/*Write a function to find project id, the name of the project, the email of
the creator, and the amount pledged for the project for the top N most
successful project based on the success metric for given date (i.e., the
project deadline must be before the given date) and for the given project
type*/

CREATE OR REPLACE FUNCTION find_top_success(
  n INT, today DATE, ptype TEXT
) RETURNS TABLE(id INT, name TEXT, email TEXT,
                amount NUMERIC) AS $$
  SELECT id, name, email, (SELECT SUM(amount) FROM Backs b WHERE b.id = p.id) as amount
  FROM Projects p
  WHERE p.deadline < today AND p.ptype = ptype
  ORDER BY (((SELECT SUM(amount) FROM Backs b WHERE b.id = p.id) + (0.00))/p.goal) DESC,
    p.deadline DESC,
    p.id ASC
  LIMIT n;

$$ LANGUAGE sql;



/* Function #3  */
/*3. Write a function to find the project id, name of the project, the email of
the creator, and the number of days it takes for the project to reach its
funding goal for the top N most popular project based on the popularity
metric for the given date (i.e., the project must be created before today)
and for the given project type.*/
CREATE OR REPLACE FUNCTION find_top_popular(
  n INT, today DATE, ptype TEXT
) RETURNS TABLE(id INT, name TEXT, email TEXT,
                days INT) AS $$
BEGIN
  RETURN QUERY
  SELECT id, name, email, MIN(days) as days FROM 
    (SELECT p1.id, p1.name, p1.email (b1.request - p1.created) as days
    FROM Backs b1 
        JOIN Backs b2 ON b2.id = b1.id AND b2.request <= b1.request
        JOIN Projects p1 on p1.id = b1.id
    GROUP BY b1.request, p1.id, p1.goal, p1.id, p1.created
    HAVING SUM(b2.amount) >= p1.goal
        AND p1.ptype = ptype
        AND p1.created < today) subq
  ORDER BY (min(days)) ASC,
      id ASC
  LIMIT n;
END;
$$ LANGUAGE plpgsql;