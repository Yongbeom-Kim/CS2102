CREATE TABLE Users (
    user_name text NOT NULL,
    user_email VARCHAR(319) PRIMARY KEY,
    cc_number1 integer NOT NULL,
    cc_number2 integer
);

CREATE TABLE Country (
    country_name text PRIMARY KEY,
);

CREATE TABLE Address (
    id serial PRIMARY KEY, 
    street_name text NOT NULL,
    house_number text NOT NULL,
    zip_code integer NOT NULL,
    country_name text NOT NULL FOREIGN KEY REFERENCES Country(country_name)
);

CREATE TABLE Creator (
    creator_email VARCHAR(319) NOT NULL,
    FOREIGN KEY (creator_email) REFERENCES Users(user_email),
    origin_country text NOT NULL,
    FOREIGN KEY (origin_country) REFERENCES Country(country_name),
    PRIMARY KEY (creator_email)
);

CREATE TABLE Backer (
    backer_email VARCHAR(319) NOT NULL,
    FOREIGN KEY (backer_email) REFERENCES Users(user_email),
    backer_address serial NOT NULL,
    FOREIGN KEY (backer_address) REFERENCES Address(id),
    PRIMARY KEY (backer_email)
);


CREATE TABLE Project (
    project_id serial PRIMARY KEY,
    project_name text NOT NULL,
    funding_goal integer NOT NULL,
    time_created timestamp NOT NULL,
    deadline timestamp NOT NULL,
    creator VARCHAR(319) NOT NULL,
    FOREIGN KEY (creator) REFERENCES Creator(creator_email)
);

CREATE TABLE RewardLevel (
    project serial NOT NULL,
    deadline timestamp NOT NULL,
    FOREIGN KEY (project, deadline) REFERENCES Project(project_id, deadline),
    reward_name text NOT NULL,
    minimum_amount integer NOT NULL,
    PRIMARY KEY (reward_name, project),
    UNIQUE (project, deadline, reward_name, minimum_amount)
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
    CONSTRAINT FK_RewardLevel
        FOREIGN KEY (project, reward_name, minimum_amount, deadline) NOT NULL REFERENCES RewardLevel(project, reward_name, minimum_amount, deadline),
    CONSTRAINT Project_Goal_Reached 
        CHECK (amount_pledged >= minimum_amount)
    CONSTRAINT Pledge_Within_Project_Deadline
        CHECK (time_pledged <= deadline),
    PRIMARY KEY (project, backer),
);

CREATE TABLE Updates (
    project serial NOT NULL,
    FOREIGN KEY (project) REFERENCES Project(project_id),
    time_updated timestamp NOT NULL,
    content text NOT NULL,
    PRIMARY KEY (project, time_updated)
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
    PRIMARY KEY (backer, project)
);

CREATE TABLE Processed (
    project serial NOT NULL,
    deadline timestamp NOT NULL,
    FOREIGN KEY (project, deadline) REFERENCES Project(project_id, deadline),
    backer VARCHAR(319) NOT NULL,
    FOREIGN KEY (backer) REFERENCES Backer(backer_email),
    time_processed timestamp NOT NULL,
    time_requested timestamp NOT NULL,
    employee serial,
    FOREIGN KEY (employee) REFERENCES Employee(employee_id),
    CONSTRAINT FK_Refund_Processed
        FOREIGN KEY (backer, project, time_requested) NOT NULL REFERENCES Pending(backer, project, time_requested),
    PRIMARY KEY (FK_Refund_Processed),
    approved boolean NOT NULL,
    CONSTRAINT Refund_Request_Within_90_Days
        CHECK (time_requested <= DATEADD(day, 90, deadline))
    CONSTRAINT Refund_Process_Condition
        CHECK (approved = false OR (approved = true AND Project_Goal_Reached = true))
);

CREATE TABLE Verify (
    user VARCHAR(319) NOT NULL,
    FOREIGN KEY (user) REFERENCES Users(user_email),
    date_verified date NOT NULL,
    employee serial,
    FOREIGN KEY (employee) REFERENCES Employee(employee_id),
    PRIMARY KEY (user, date_verified)
);