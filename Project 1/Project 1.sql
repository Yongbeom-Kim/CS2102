-- \i C:/Users/yuan1/Documents/Study/2223sem1/CS2102/project/Project1.sql;
-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;



-- change the name of table (User --> Users)
CREATE TABLE Users (
    user_name text NOT NULL,
    user_email VARCHAR(319) PRIMARY KEY,
    cc_number1 integer NOT NULL,
    cc_number2 integer
);

-- create Country table
CREATE TABLE Country (
    country_name text PRIMARY KEY,
    tax_code text NOT NULL
);

-- adjust the position of Address
-- move FOREIGN KEY to a new line (same for other tables below)
CREATE TABLE Address (
    id serial PRIMARY KEY, 
    street_name text NOT NULL,
    house_number text NOT NULL,
    zip_code integer NOT NULL,
    country_name text NOT NULL,
    FOREIGN KEY (country_name) REFERENCES Country(country_name)
);

-- remove project attribute and its foriegn key
CREATE TABLE Creator (
    creator_email VARCHAR(319) PRIMARY KEY,
    origin_country text NOT NULL,
    FOREIGN KEY (creator_email) REFERENCES Users(user_email),
    FOREIGN KEY (origin_country) REFERENCES Country(country_name)
);

-- change the of backer_address (text --> serial)
CREATE TABLE Backer (
    backer_email VARCHAR(319) NOT NULL PRIMARY KEY,
    backer_address serial NOT NULL,
    FOREIGN KEY (backer_email) REFERENCES Users(user_email),
    FOREIGN KEY (backer_address) REFERENCES Address(id)
);

CREATE TABLE Project (
    project_id serial PRIMARY KEY,
    project_name text NOT NULL,
    funding_goal integer NOT NULL,
    time_created timestamp NOT NULL,
    deadline timestamp NOT NULL,
    creator VARCHAR(319) NOT NULL,
    FOREIGN KEY (creator) REFERENCES Creator(creator_email),
    UNIQUE(project_id, deadline)
);

CREATE TABLE GoalReachedProject (
    project_id serial PRIMARY KEY,
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);

CREATE TABLE RewardLevel (
    project serial NOT NULL,
    FOREIGN KEY (project) REFERENCES Project(project_id),
    reward_name text NOT NULL,
    minimum_amount integer NOT NULL,
    deadline timestamp NOT NULL,
    FOREIGN KEY (project, deadline) REFERENCES Project(project_id, deadline), 
    PRIMARY KEY (reward_name, project),
    UNIQUE (project, reward_name, minimum_amount, deadline)
);

CREATE TABLE FundReward (
    project serial NOT NULL,
    FOREIGN KEY (project) REFERENCES Project(project_id),
    reward_name text NOT NULL,
    backer VARCHAR(319) NOT NULL,
    FOREIGN KEY (backer) REFERENCES Backer(backer_email),
    amount_pledged integer NOT NULL,
    time_pledged timestamp NOT NULL,
    minimum_amount integer NOT NULL,
    deadline timestamp NOT NULL,
    PRIMARY KEY (project, backer),
    CONSTRAINT FK_RewardLevel
        FOREIGN KEY (project, reward_name, minimum_amount, deadline) REFERENCES RewardLevel(project, reward_name, minimum_amount, deadline),
    CONSTRAINT Project_Goal_Reached 
        CHECK (amount_pledged >= minimum_amount),
    CONSTRAINT Pledge_Within_Project_Deadline
        CHECK (time_pledged <= deadline)
);

CREATE TABLE Updates (
    project serial NOT NULL,
    time_updated timestamp NOT NULL,
    content text NOT NULL,
    PRIMARY KEY (project, time_updated),
    FOREIGN KEY (project) REFERENCES Project(project_id)
);

CREATE TABLE Employee (
    employee_id serial PRIMARY KEY,
    employee_name text NOT NULL,
    monthly_salary integer NOT NULL
    CONSTRAINT Employee_Monthly_Salary
        CHECK (monthly_salary > 0)
);

CREATE TABLE Pending (
    project serial NOT NULL,
    FOREIGN KEY (project) REFERENCES Project(project_id),
    time_requested timestamp NOT NULL,
    backer VARCHAR(319) NOT NULL,
    FOREIGN KEY (backer) REFERENCES Backer(backer_email),
    employee serial,
    FOREIGN KEY (employee) REFERENCES Employee(employee_id),
    PRIMARY KEY (backer, project),
    deadline timestamp NOT NULL,
    FOREIGN KEY (project, deadline) REFERENCES Project(project_id, deadline),
    UNIQUE (backer, project, time_requested, deadline)
);

CREATE TABLE Processed (
    project serial NOT NULL,
    FOREIGN KEY (project) REFERENCES Project(project_id),
    backer VARCHAR(319) NOT NULL,
    FOREIGN KEY (backer) REFERENCES Backer(backer_email),
    time_processed timestamp NOT NULL,
    employee serial,
    FOREIGN KEY (employee) REFERENCES Employee(employee_id),
    time_requested timestamp NOT NULL,
    deadline timestamp NOT NULL,
    FOREIGN KEY (backer, project, time_requested, deadline) REFERENCES Pending(backer, project, time_requested, deadline),
    CONSTRAINT FK_Refund_Processed
        FOREIGN KEY (backer, project) REFERENCES Pending(backer, project),
    PRIMARY KEY (backer, project),
    approved boolean NOT NULL,
    goal_project serial NOT NULL,
    FOREIGN KEY (goal_project) REFERENCES GoalReachedProject(project_id),
    CONSTRAINT Refund_Request_Within_90_Days
        CHECK (time_requested <= deadline + 90 * INTERVAL '1 day' ),
    CONSTRAINT Refund_Process_Condition
        CHECK (approved = false OR (approved = true AND project = goal_project))
);

CREATE TABLE Verify (
    user_email VARCHAR(319) NOT NULL,
    FOREIGN KEY (user_email) REFERENCES Users(user_email),
    date_verified date NOT NULL,
    employee serial NOT NULL,
    FOREIGN KEY (employee) REFERENCES Employee(employee_id),
    PRIMARY KEY(user_email, date_verified)
);