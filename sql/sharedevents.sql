/*
  SHARED EVENT DATABASE
  TABLES:
   1 -  users: it doesn't need explenation...
   2 -  groups
   3 -  members
   4 -  events: an event created by user
   5 -  categories
   6 -  documents: written by users during an event
   7 -  nodes
   8 -  notes
   9 -  places: an event location
  10 -  partecipation: user's partecipation to events

  NOTE:
    1 - In mysql we can only have one table with CURRENT_TIMESTAMP as default (or on update value)
    for a timestamp value. (I don't know why though)

    2 - first step, after you have switched on the MySQL server,
    type: /Applications/MAMP/Library/bin/mysql --host=localhost -uroot -proot

    3 - A check statement inside a table is parsed but not ignored because it is not supported by mySQL

    4 - Cascade doesn't activate triggers.

    5 - Enter the DB: /Applications/MAMP/Library/bin/mysql --user=user --password=user-password;
*/

/* Database cretion */
CREATE DATABASE IF NOT EXISTS merge;
USE merge;

/******************** TABLES ***********************/
/* USERS */
CREATE TABLE IF NOT EXISTS users (
  id int(11) auto_increment primary key,
  name varchar(100) not null,
  lastname varchar(100) not null,
  born date,
  subscriptiondate timestamp not null,
  type enum('basic','premium','admin') default 'basic',
  profilepicture varchar(300),
  actual_lat decimal(11,8), /* it must be defined */
  actual_lng decimal(11,8), /* it must be defined */
  password varchar(300) not null,
  mail varchar(150) not null,
  delated  ENUM('0','1') default '0'
) engine=INNODB;

/* GROUPS */
CREATE TABLE IF NOT EXISTS groups(
  id int(11) auto_increment primary key,
  name varchar(100) not null,
  creationdate timestamp not null default current_timestamp(),
  image varchar(300),
  description varchar(2000) not null default "No description."
) engine=INNODB;

/* MEMBERS */
CREATE TABLE IF NOT EXISTS members(
  iduser int(11) not null,
  idgroup int(11) not null,
  accepted boolean default 0,
  role enum('admin','normal') default 'normal',
  joindate timestamp not null,
  primary key(iduser, idgroup),
  foreign key(iduser) references users(id) on delete no action ,
  foreign key(idgroup) references groups(id) on delete no action
) engine=INNODB;

/* EVENTS */
CREATE TABLE IF NOT EXISTS events (
  id int(11) auto_increment  primary key,
  name varchar(100) not null,
  place int references place(id) on delete set null on update cascade,
  creationdate timestamp not null,
  startdate timestamp,
  stopdate timestamp,
  creator int references user(id)on delete set null on update cascade,
  type ENUM('public','private') default 'public',
  description varchar(2000),
  categoryid int references categories(id) on delete set null
) engine=INNODB;

/* CATEGORIES */
CREATE TABLE IF NOT EXISTS categories (
  id int(11) auto_increment  primary key,
  name varchar(100) not null,
  description varchar(2000),
  colour varchar(6)
) engine=INNODB;

/* DOCUMENTS */
CREATE TABLE IF NOT EXISTS documents (
  id int(11) auto_increment primary key,
  creator int not null references user(id),
  name varchar(100) default "unknown document",
  event int references event(id),
  creationdate timestamp default current_timestamp,
  public ENUM('0','1') default '0'
) engine=INNODB;

/* NODES */
CREATE TABLE IF NOT EXISTS nodes (
  id int(11) auto_increment primary key,
  document int(11) references documents(id),
  note int(11) references notes(id),
  creationdate timestamp default current_timestamp,
  header varchar(200) default "Title",
  subheader varchar(200) default "Subtitle"
) engine=INNODB;

/* NOTES */
CREATE TABLE IF NOT EXISTS notes (
  id int(11) auto_increment primary key,
  type ENUM('code','text', 'image', 'link') default 'text',
  content text,
  description varchar(200)
) engine=INNODB;

/* PLACES */
CREATE TABLE IF NOT EXISTS places (
  id int(11) auto_increment primary key,
  lat decimal(11,8),
  lng decimal(11,8),
  name varchar(100) not null,
  address varchar(200) not null,
  cap varchar(10),
  city varchar(50) not null,
  nation varchar(50) not null default "Italy"
) engine=INNODB;

/* PARTECIPATIONS */
CREATE TABLE IF NOT EXISTS partecipations (
  id int auto_increment primary key,
  event_id int not null references event(id),
  user_id int not null references user(id),
  status ENUM('accepted','declined','waiting') default 'waiting'
) engine=INNODB;

/******************** VIEWS *************************/

CREATE VIEW usersInfo(userid, name, lastname, born, subscriptiondate, type, profilepicture, email) AS
  SELECT id, name, lastname, born, subscriptiondate, type, profilepicture, email FROM users;

/* TODO */

/******************** TRIGGERS **********************/

/* 1 - check_age
  Checks the user date of birth
*/
DELIMITER //
create trigger check_age
BEFORE INSERT ON merge.user
FOR EACH ROW
BEGIN
  -- CURRENT_TIMESTAMP() - UNIX_TIMESTAMP(NEW.born) > 1009846861  -- 14yo in timestamp
	IF (NEW.born IS NULL) OR ( (YEAR(CURRENT_TIMESTAMP()) - YEAR(NEW.born) - (DATE_FORMAT(CURRENT_TIMESTAMP(), '%m%d') < DATE_FORMAT(NEW.born, '%m%d'))) < 14 )
  THEN
      SIGNAL sqlstate '45000' set message_text = "Age must be more than 14 yo";
	END IF;
END //
DELIMITER ;

/* 2 - check_event_creation
  Checks the if the creation date is correct
  (it can be omitted since we use a stored procedure and set creation with current_timestamp)
*/
DELIMITER //
create trigger check_event_creation
BEFORE INSERT ON merge.event
FOR EACH ROW
BEGIN
	IF ( (NEW.creation IS NULL) OR (NEW.creation > CURRENT_TIMESTAMP()) )
  THEN
      SIGNAL sqlstate '45000' set message_text = "Invalid creation date";
	END IF;
END //
DELIMITER ;

/* 3 - check_mail
  Checks if the email provided by the user is correct.
*/
DELIMITER //
create trigger check_mail
BEFORE INSERT ON merge.users
FOR EACH ROW
BEGIN
	IF (NEW.mail NOT REGEXP '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$' )
  THEN
      SIGNAL sqlstate '45000' set message_text = "Invalid email address";
	END IF;
END //
DELIMITER ;

/* 4 - check_admin
  When an admin leaves a group, it replace the admin with the first member who has joined the group.
*/
DELIMITER //
create trigger change_admin
AFTER DELETE  ON merge.members
FOR EACH ROW
BEGIN
	IF ( OLD.role = "admin" )
  THEN
      UPDATE members SET role = "admin"
      WHERE (idgroup = OLD.idgroup) AND (iduser = (SELECT iduser FROM members WHERE idgroup = OLD.idgroup HAVING min(joindate)));
	END IF;
END //
DELIMITER ;

/* 5 - check_note
  Checks if an image note or a link note has the description associated
*/
DELIMITER //
create trigger ceck_note
BEFORE INSERT ON merge.notes
FOR EACH ROW
BEGIN
	IF ( ( NEW.type = "image" OR NEW.type = "link") AND (NEW.description IS NULL) )
  THEN
    SIGNAL sqlstate '45000' set message_text = "You must provide a description";
  END IF;
END //
DELIMITER ;


/******************** STORED PROCEDURES **********************/
/* insertUser()
    Insert a User TODO
*/
DELIMITER |
CREATE PROCEDURE insertUser(IN name varchar(100),
 IN lastname varchar(100),
 IN born date, IN type int,
 IN profile varchar(300),
 IN password varchar(300),
 IN mail varchar(150),
 OUT id int)
BEGIN
  IF type = 1 THEN
    insert into users(name, lastname, born, subscriptiondate, type, profilepicture, password, mail)
      values(name, lastname, born, CURRENT_TIMESTAMP(), "premium", profile, password, mail);
  ELSEIF type = 2 THEN
    insert into users(name, lastname, born, subscriptiondate, type, profilepicture, password, mail)
      values(name, lastname, born, CURRENT_TIMESTAMP(), "admin", profile, password, mail);
  ELSE
    insert into users(name, lastname, born, subscriptiondate, profilepicture, password, mail)
      values(name, lastname, born, CURRENT_TIMESTAMP(), profile, password, mail);
  END IF;
  SELECT LAST_INSERT_ID() INTO id;
  SELECT LAST_INSERT_ID() AS "last user insert id ";
END |
DELIMITER ;

/* userNearEvents()
    Select a number of places filtered by a given distance (in km)
*/
DELIMITER |
CREATE PROCEDURE userNearEvents(IN userid int, IN dist int)
BEGIN
  DECLARE userLng DOUBLE;
  DECLARE userLat DOUBLE;
  -- Get actual user's lat and lng given the userID
  SELECT actual_lng, actual_lat INTO userLng, userLat FROM users WHERE (id = userid) LIMIT 1;
  -- Find Events
  SELECT ev.id as eventId, ev.name as eventName, ev.creation as dateCreation, ev.start as dateStart, ev.stop as dateStop, ev.description as eventDesc,
         u.id as creatorId, u.name as creatorName, u.lastname as creatorLastname,
         pl.id as placeId, pl.name as placeName, pl.address as placeAddress, pl.lat as placeLat, pl.lng as placeLng,
         ( 3959 * acos( cos( radians(userLat) ) * cos( radians( pl.lat ) ) * cos( radians( pl.lng ) - radians(userLng) ) + sin( radians(userLat) ) * sin( radians( pl.lat ) ) ) ) AS distance
  FROM events as ev, places as pl, users as u
  WHERE (ev.place = pl.id) AND (ev.creator = u.id)
  HAVING (distance < dist)
  ORDER BY distance;

END |
DELIMITER ;

/* suggestedEvents() */
DELIMITER |
CREATE PROCEDURE suggestedEvents(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  SELECT ev.id as eventId, ev.name as eventName, ev.creation as dateCreation, ev.start as dateStart, ev.stop as dateStop, ev.description as eventDesc,
         u.id as creatorId, u.name as creatorName, u.lastname as creatorLastname,
         pl.id as placeId, pl.name as placeName, pl.address as placeAddress, pl.lat as placeLat, pl.lng as placeLng,
         ( 3959 * acos( cos( radians(latitude) ) * cos( radians( pl.lat ) ) * cos( radians( pl.lng ) - radians(longitude) ) + sin( radians(latitude) ) * sin( radians( pl.lat ) ) ) ) AS distance
  FROM events as ev, places as pl, users as u
  WHERE (ev.place = pl.id) AND (ev.creator = u.id)
  HAVING (distance < dist)
  ORDER BY distance;
END |
DELIMITER ;

/* suggestedPlaces() */
DELIMITER |
CREATE PROCEDURE suggestedPlaces(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  SELECT pl.* , ( 3959 * acos( cos( radians(latitude) ) * cos( radians( pl.lat ) ) * cos( radians( pl.lng ) - radians(longitude) ) + sin( radians(latitude) ) * sin( radians( pl.lat ) ) ) ) AS distance
  FROM places as pl
  HAVING (distance < dist)
  ORDER BY distance;
END |
DELIMITER ;

/* login() */
DELIMITER |
CREATE PROCEDURE login( IN usermail VARCHAR(150), IN userpassword VARCHAR(300), IN lat DECIMAL(11,8), IN lng DECIMAL(11,8) )
BEGIN
  DECLARE uid INT default -1;
  SELECT id INTO uid FROM users WHERE (mail = usermail) AND (password = userpassword) LIMIT 1;
  IF (uid <> -1) THEN
    call setPostion(uid, lat, lng);
    call getUser(uid);
  END IF;
END |
DELIMITER ;

/* getUser( id ) */
DELIMITER |
CREATE PROCEDURE getUser(IN id INT)
BEGIN
  SELECT * FROM usersInfo WHERE userid = id;
END |
DELIMITER ;

/* setPosition( pos ) */
DELIMITER |
CREATE PROCEDURE setPosition(IN uid INT, IN lat DECIMAL(11,8), IN lng DECIMAL(11,8) )
BEGIN
  UPDATE users SET actual_lat = lat, actual_lng = lng WHERE (id = uid);
END |
DELIMITER ;

/* getEvents() */
DELIMITER |
CREATE PROCEDURE getEvents()
BEGIN
  SELECT * FROM events;
END |
DELIMITER ;

/* getEvent( id ) */
DELIMITER |
CREATE PROCEDURE getEvent(IN eventid INT)
BEGIN
  SELECT * FROM events WHERE (id = eventid);
END |
DELIMITER ;

/* getUserDoc( id ) */
DELIMITER |
CREATE PROCEDURE getUserDoc(IN userid INT)
BEGIN
  SELECT * FROM documents WHERE (creator = userid);
END |
DELIMITER ;

/*  getDocContent( id ) */
DELIMITER |
CREATE PROCEDURE getDocContent(IN docid INT)
BEGIN
  SELECT * FROM notes,nodes WHERE (nodes.note = notes.id) AND (nodes.document = docid);
END |
DELIMITER ;

/* getGroupMembers() */
DELIMITER |
CREATE PROCEDURE getGroupMembers(IN groupid INT)
BEGIN
  SELECT * FROM members as m, usersInfo as u
  WHERE (m.idgroup = groupid) AND (m.iduser = u.id);
END |
DELIMITER ;

/* getEventPartecipants() */
DELIMITER |
CREATE PROCEDURE getEventPartecipants(IN eventid INT)
BEGIN
  SELECT * FROM partecipations as p, usersInfo as u
  WHERE (p.event_id = eventid) AND (p.user_id = u.id) AND (p.status = "accepted"); -- all or only "accepted" ?
END |
DELIMITER ;


/* search( string )*/
SELECT nome, cognome FROM element WHERE ( CONCAT_WS(' ', nome, cognome) LIKE '%{$textParam}%' OR CONCAT_WS(' ', cognome, nome) LIKE '%{$textParam}%') LIMIT 10;

/******************** GRANT PERMISSIONS **********************/
CREATE USER 'user'@'localhost' IDENTIFIED BY 'user-password';
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin-password-3h5CHx34t2D';
