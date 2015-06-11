
DROP TABLE users CASCADE;
DROP TABLE engineers CASCADE;
DROP TABLE days CASCADE;
DROP TABLE times CASCADE;
DROP TABLE time_slots CASCADE;

CREATE  TABLE users (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  password VARCHAR(255)
);

CREATE TABLE engineers (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  password VARCHAR(255)
);

CREATE TABLE days (
  id SERIAL PRIMARY KEY,
  day VARCHAR(255)
);

CREATE TABLE times (
  id SERIAL PRIMARY KEY,
  time_slot VARCHAR(255)
);

CREATE TABLE time_slots (
  id SERIAL PRIMARY KEY,
  day_id INTEGER,
  times_id INTEGER,
  user_id INTEGER,
  engineer_id INTEGER
);
