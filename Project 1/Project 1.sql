CREATE TABLE User (
    user_name text NOT NULL,
    user_email VARCHAR(319) PRIMARY KEY,
    cc_number1 integer NOT NULL,
    cc_number2 integer
);

CREATE TABLE Creator (
    creator_email VARCHAR(319) NOT NULL FOREIGN KEY REFERENCES User(user_email),
    project integer NOT NULL FOREIGN KEY REFERENCES Project(project_id),
    origin_country text NOT NULL FOREIGN KEY REFERENCES Country(country_name)
);

CREATE TABLE Backer (
    backer_email VARCHAR(319) NOT NULL FOREIGN KEY REFERENCES User(user_email),
    backer_address text NOT NULL FOREIGN KEY REFERENCES Address(id)
);

CREATE TABLE Address (
    id serial PRIMARY KEY, 
    street_name text NOT NULL,
    house_number text NOT NULL,
    zip_code integer NOT NULL,
    country_name text NOT NULL FOREIGN KEY REFERENCES Country(country_name)
);

CREATE TABLE Project (
    project_id serial PRIMARY KEY,
    project_name text NOT NULL,
    funding_goal integer NOT NULL,
    time_created timestamp NOT NULL,
    deadline timestamp NOT NULL,
    creator VARCHAR(319) NOT NULL FOREIGN KEY REFERENCES Creator(creator_email)
);

CREATE TABLE FundReward (
    project serial NOT NULL FOREIGN KEY REFERENCES Project(project_id),
    backer VARCHAR(319) NOT NULL FOREIGN KEY REFERENCES Backer(backer_email),
    amount_pledged integer NOT NULL,
    time_pledged timestamp NOT NULL,
    PRIMARY KEY (project, backer),
    CONSTRAINT FK_RewardLevel
        FOREIGN KEY (project, reward_name) NOT NULL REFERENCES RewardLevel(reward_name, project),
    CONSTRAINT Project_Goal_Reached 
        CHECK (amount_pledged >= SELECT minimum_amount FROM RewardLevel WHERE RewardLevel(reward_name, project) = FK_RewardLevel)
    CONSTRAINT Pledge_Within_Project_Deadline
        CHECK (time_pledged <= SELECT deadline FROM Project WHERE project_id = project)
);

CREATE TABLE RewardLevel (
    project serial NOT NULL FOREIGN KEY REFERENCES Project(project_id),
    reward_name text NOT NULL;
    minimum_amount integer NOT NULL,
    PRIMARY KEY (reward_name, project)
    UNIQUE (project_id, minimum_amount)
);

CREATE TABLE Updates (
    project serial NOT NULL FOREIGN KEY REFERENCES Project(project_id),
    time_updated timestamp NOT NULL,
    content text NOT NULL, -- what is the content
    PRIMARY KEY (project, time_updated)
);

CREATE TABLE Refund (
    project serial NOT NULL FOREIGN KEY REFERENCES Project(project_id),
    time_requested timestamp NOT NULL,
    backer VARCHAR(319) NOT NULL FOREIGN KEY REFERENCES Backer(backer_email),
    PRIMARY KEY (backer, project),
    CONSTRAINT Refund_Request_Within_90_Days
        CHECK (time_requested <= DATEADD(day, 90, SELECT deadline FROM Project WHERE project_id = project))
);

CREATE TABLE Employee (
    employee_id serial PRIMARY KEY,
    employee_name text NOT NULL,
    monthly_salary integer NOT NULL
);

CREATE TABLE Pending (
    project serial NOT NULL FOREIGN KEY REFERENCES Project(project_id),
    backer VARCHAR(319) NOT NULL FOREIGN KEY REFERENCES Backer(backer_email),
    employee serial FOREIGN KEY REFERENCES Employee(employee_id),
    CONSTRAINT FK_Refund_Pending
        FOREIGN KEY (backer, project) NOT NULL REFERENCES Refund(backer, project),
    PRIMARY KEY (FK_Refund_Pending)
);

CREATE TABLE Processed (
    project serial NOT NULL FOREIGN KEY REFERENCES Project(project_id),
    backer VARCHAR(319) NOT NULL FOREIGN KEY REFERENCES Backer(backer_email),
    time_processed timestamp NOT NULL,
    employee serial FOREIGN KEY REFERENCES Employee(employee_id),
    CONSTRAINT FK_Refund_Processed
        FOREIGN KEY (backer, project) NOT NULL REFERENCES Refund(backer, project),
    PRIMARY KEY (FK_Refund_Processed),
    approved boolean NOT NULL,
    CONSTRAINT Refund_Process_Condition
        CHECK (approved = false OR (approved = true AND Project_Goal_Reached = true))
);

CREATE TABLE Verify (
    user VARCHAR(319) NOT NULL FOREIGN KEY REFERENCES User(user_email),
    time_verified timestamp NOT NULL,
    employee serial FOREIGN KEY REFERENCES Employee(employee_id)
);