-- Reset DB
\i DDL.sql
do $$ 
DECLARE
    PROJECT_TYPE_NUMBER INT := 3;
BEGIN

    -- USERS Table
    DECLARE
        s TEXT;
    BEGIN
        FOR i in 1..10 LOOP
            s := CAST(i AS TEXT);
            -- raise notice 'cnt: %', r;
            INSERT INTO Users (email, name, cc1, cc2)
            VALUES
                ('email' || s || '@example.com', 'name' || s, 'cc1' || s, 'cc2' || s);
        END LOOP;
    END;

    -- Employees Table
    DECLARE
        s TEXT;
    BEGIN
        FOR i in 1..3 LOOP
            s := CAST(i AS TEXT);
            -- raise notice 'cnt: %', r;
            INSERT INTO Employees (id, name, salary)
            VALUES
                (i, s, 1000);
        END LOOP;
    END;

    -- Backers Table
    DECLARE
        i INT;
        s TEXT;
        email TEXT;
        curs refcursor;
        
    BEGIN
        OPEN curs FOR (SELECT u.email FROM Users u);
        i := 1;

        LOOP
        FETCH curs INTO email;
        EXIT WHEN NOT FOUND;
        s := CAST(i as TEXT);

        INSERT INTO Backers (email, street, num, zip, country)
        VALUES
            (email, s, s, s, s);

        i := i + 1;
        END LOOP;
        CLOSE curs;
    END;

    -- Creators Table
    DECLARE
        i INT;
        s TEXT;
        email TEXT;
        curs refcursor;    
    BEGIN
        OPEN curs FOR (SELECT u.email FROM Users u);
        i := 1;

        LOOP
        FETCH curs INTO email;
        EXIT WHEN NOT FOUND;
        s := CAST(i as TEXT);

        INSERT INTO Creators (email, country)
        VALUES
            (email, s);

        i := i + 1;
        END LOOP;
        CLOSE curs;
    END;

    -- Verifies Table
    DECLARE
        id INT;
        email TEXT;
        curs1 refcursor;    
        curs2 refcursor;
    
    BEGIN
        OPEN curs1 FOR (SELECT u.email FROM Users u);
        LOOP

            FETCH curs1 INTO email;
            EXIT WHEN NOT FOUND;

            id := (SELECT e.id FROM Employees e ORDER BY random() LIMIT 1);

            INSERT INTO Verifies (email, id, verified) VALUES
                (email, id , '2000-01-10');

        END LOOP;
        CLOSE curs1;
    END;

    DECLARE
        s TEXT;
        id INT;
    BEGIN
        FOR i in 1..PROJECT_TYPE_NUMBER LOOP

            id := (SELECT e.id FROM Employees e ORDER BY random() LIMIT 1);
            s := CAST(i as TEXT);

            INSERT INTO ProjectTypes (name, id)
                VALUES (s, id);

        END LOOP;
    END;

END; $$;

select * from users;
select * from employees;
select * from backers;
select * from creators;
select * from verifies;
select * from projecttypes;