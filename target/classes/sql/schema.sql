
CREATE TABLE IF NOT EXISTS accounts (
id int PRIMARY KEY auto_increment,
username varchar(50),
password varchar(50)
);

CREATE TABLE IF NOT EXISTS data (
text varchar(200)
);