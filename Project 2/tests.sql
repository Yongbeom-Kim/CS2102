/* Creating dummy data */
INSERT INTO
    Users (email, name, cc1, cc2)
VALUES
    ('123@abc.com', 'a', '123abc', 'abc123');

INSERT INTO
    Users (email, name, cc1, cc2)
VALUES
    ('1234@abc.com', 'b', '123abc', 'abc123');

INSERT INTO
    Backers(email, street, num, zip, country)
VALUES
    ('123@abc.com', '42 Street', '1', '123456', 'f');

INSERT INTO
    Creators(email, country)
VALUES
    ('1234@abc.com', 'f');

INSERT INTO
    Employees (id, name, salary)
VALUES
    (1, 'B', 100);

INSERT INTO
    ProjectTypes (name, id)
VALUES
    ('p1', 1);

INSERT INTO
    Projects (id, email, ptype, created, name, deadline, goal)
VALUES
    (
        1,
        '1234@abc.com',
        'p1',
        NOW(),
        'P1',
        '2022-12-30',
        200
    );

INSERT INTO
    Rewards(name, id, min_amt)
VALUES
    ('gold', 1, 100);

/* Trigger 5: Insert valid row */
INSERT INTO
    Backs (email, name, id, backing, request, amount)
VALUES
    ('123@abc.com', 'gold', 1, NOW(), NULL, 180);

/* Trigger 5: Insert invalid row - amount too small*/
INSERT INTO
    Backs (email, name, id, backing, request, amount)
VALUES
    ('1234@abc.com', 'gold', 1, NOW(), NULL, 80);

/* Trigger 5: Insert invalid row - date too large*/
INSERT INTO
    Backs (email, name, id, backing, request, amount)
VALUES
    (
        '1234@abc.com',
        'gold',
        1,
        '2023-01-01',
        NULL,
        180
    );


/* Procedure 1 */
-- Success case: Add new backer (user does not exist)
CALL add_user('p1t1@123.com', 'p1t1', '123456', null, 'street', '1234', '12345', 'country', 'BACKER');
-- Success case: Add new creator (user exists)
CALL add_user('p1t1@123.com', 'p1t1', '123456', null, 'street', '1234', '12345', 'country', 'CREATOR');
-- Success case: Add both (user does not exist)
CALL add_user('p1t1_2@123.com', 'p1t1', '123456', null, 'street', '1234', '12345', 'country', 'BOTH');
-- No Change to DB: Add both (creator and backer already exist)
CALL add_user('p1t1_2@123.com', 'p1t1', '123456789', null, 'street123', '1234', '12345', 'country', 'BOTH');
-- Failure case: Add backer (missing information - street)
-- Failure case: Add creator (missing information)
CALL add_user('p1t1_23@12356.com', 'p1t1', '123456789', null, null, '1234', '12345', null, 'BOTH');

