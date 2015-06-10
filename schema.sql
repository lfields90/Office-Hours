
DROP TABLE users, engineers, days, times, schedule CASCADE;

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
  times_id VARCHAR(255),
  user_id INTEGER,
  engineer_id INTEGER
);
