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

    5 - Enter the DB: /Applications/MAMP/Library/bin/mysql --user= <user> --password= <user-password>;
<<<<<<< HEAD
=======
    5 - Enter the DB: /Applications/MAMP/Library/bin/mysql --user=user --password=user-password;
    /Applications/MAMP/Library/bin/mysql --user=root --password=root;
>>>>>>> origin/ludovico
*/

/* Database cretion */
CREATE DATABASE IF NOT EXISTS merge;
USE merge;

/******************** TABLES ***********************/
/* USERS */
CREATE TABLE IF NOT EXISTS users (
  id int(11) auto_increment,
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
  delated  ENUM('0','1') default '0',
  PRIMARY KEY (id)
) engine=INNODB;

/* GROUPS */
CREATE TABLE IF NOT EXISTS groups(
  id int(11) auto_increment,
  name varchar(100) not null,
  creationdate timestamp not null default current_timestamp(),
  image varchar(300),
  description varchar(2000) not null default "No description.",
  PRIMARY KEY (id)
) engine=INNODB;

/* PLACES */
CREATE TABLE IF NOT EXISTS places (
  id int(11) auto_increment,
  lat decimal(11,8),
  lng decimal(11,8),
  name varchar(100) not null,
  address varchar(200) not null,
  cap varchar(10),
  city varchar(50) not null,
  nation varchar(50) not null default "Italy",
  PRIMARY KEY (id)
) engine=INNODB;

/* CATEGORIES */
CREATE TABLE IF NOT EXISTS categories (
  id int(11) auto_increment,
  name varchar(100) not null,
  description varchar(2000),
  colour varchar(6),
  PRIMARY KEY (id)
) engine=INNODB;

/* NOTES */
CREATE TABLE IF NOT EXISTS notes (
  id int(11) auto_increment,
  type ENUM('code','text', 'image', 'link') default 'text',
  content text,
  description varchar(200),
  PRIMARY KEY(id)
) engine=INNODB;

/* MEMBERS */
CREATE TABLE IF NOT EXISTS members(
  iduser int(11) not null,
  idgroup int(11) not null,
  accepted boolean default 0,
  role enum('admin','normal') default 'normal',
  joindate timestamp not null default CURRENT_TIMESTAMP(),
  PRIMARY KEY (iduser, idgroup),
  FOREIGN KEY (iduser) references users(id) on delete no action,
  FOREIGN KEY (idgroup) references groups(id) on delete no action
) engine=INNODB;

/* EVENTS */
CREATE TABLE IF NOT EXISTS events (
  id int(11) auto_increment,
  name varchar(100) not null,
  place int,
  creationdate timestamp default current_timestamp,
  startdate timestamp,
  stopdate timestamp,
  creator int,
  type ENUM('public','private') default 'public',
  description varchar(2000),
  categoryid int,
  PRIMARY KEY (id),
  FOREIGN KEY (place) REFERENCES places(id) on delete set null on update cascade,
  FOREIGN KEY (creator) REFERENCES users(id) on delete set null on update cascade,
  FOREIGN KEY (categoryid) REFERENCES categories(id) on delete set null
) engine=INNODB;

/* DOCUMENTS */
CREATE TABLE IF NOT EXISTS documents (
  id int(11) auto_increment,
  creator int not null,
  name varchar(100) default "unknown document",
  event int not null,
  creationdate timestamp default current_timestamp,
  public ENUM('0','1') default '0',
  PRIMARY KEY (id),
  FOREIGN KEY (creator) REFERENCES users(id),
  FOREIGN KEY (event) REFERENCES events(id)

) engine=INNODB;

/* NODES */
CREATE TABLE IF NOT EXISTS nodes (
  id int(11) auto_increment,
  document int(11),
  note int(11),
  creationdate timestamp default current_timestamp,
  header varchar(200) default "Title",
  subheader varchar(200) default "Subtitle",
  PRIMARY KEY (id),
  FOREIGN KEY (document) REFERENCES documents(id),
  FOREIGN KEY (note) REFERENCES notes(id)
) engine=INNODB;

/* PARTECIPATIONS */
CREATE TABLE IF NOT EXISTS partecipations (
  event_id int(11) not null,
  user_id int(11) not null,
  status ENUM('accepted','declined','waiting') default 'waiting',
  PRIMARY KEY (event_id, user_id),
  FOREIGN KEY(event_id) REFERENCES events(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
) engine=INNODB;

/******************** VIEWS *************************/

CREATE VIEW usersInfo(userid, name, lastname, born, subscriptiondate, type, profilepicture, mail) AS
  SELECT id, name, lastname, born, subscriptiondate, type, profilepicture, mail FROM users WHERE delated="0";

/* TODO */

/******************** TRIGGERS **********************/

/* 1 - check_age
  Checks the user date of birth
*/
DELIMITER //
create trigger check_age
BEFORE INSERT ON merge.users
FOR EACH ROW
BEGIN
  -- CURRENT_TIMESTAMP() - UNIX_TIMESTAMP(NEW.born) > 1009846861  -- 14yo in timestamp
	IF (NEW.born IS NULL) OR ( (YEAR(CURRENT_TIMESTAMP()) - YEAR(NEW.born) - (DATE_FORMAT(CURRENT_TIMESTAMP(), '%m%d') < DATE_FORMAT(NEW.born, '%m%d'))) < 14 )
  THEN
      SIGNAL sqlstate '45000' set message_text = "Age must be more than 14 yo";
	END IF;
	IF (NEW.mail NOT REGEXP '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$' )
  THEN
      SIGNAL sqlstate '45000' set message_text = "Invalid email address";
	END IF;
END //
DELIMITER ;

/* 2 - check_event_creation
  Checks the if the creation date is correct
  (it can be omitted since we use a stored procedure and set creation with current_timestamp)
*/
/* MERGED TRIGGER
  3 - check_mail
  Checks if the email provided by the user is correct.
*/
DELIMITER //
create trigger check_event_creation
BEFORE INSERT ON merge.events
FOR EACH ROW
BEGIN
	IF ( (NEW.creationdate IS NULL) OR (NEW.creationdate > CURRENT_TIMESTAMP()) )
  THEN
      SIGNAL sqlstate '45000' set message_text = "Invalid creation date";
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
      -- it should call update admin
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
  SELECT ev.id as eventId, ev.name as eventName, ev.creationdate as dateCreation, ev.startdate as dateStart, ev.stopdate as dateStop, ev.description as eventDesc,
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
CREATE PROCEDURE login( IN usermail VARCHAR(150), IN userpassword VARCHAR(300), IN lat DECIMAL(11,8), IN lng DECIMAL(11,8))
BEGIN
  DECLARE uid INT default -1;
  SELECT id INTO uid FROM users WHERE (mail = usermail) AND (password = userpassword) LIMIT 1;
  IF (uid <> -1) THEN
    call updatePosition(uid, lat, lng);
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

/* updateUser */
DELIMITER |
CREATE PROCEDURE updateUser( IN idI INT,
 IN nameI varchar(100),
 IN lastnameI varchar(100),
 IN bornI date,
 IN typeI varchar(30),
 IN profileI varchar(300),
 IN lat DECIMAL(11,8),
 IN lng DECIMAL(11,8),
 IN passwordI varchar(300),
 IN mailI varchar(150),
 IN delatedI INT)
BEGIN
  UPDATE users
    SET name = nameI, lastname = lastnameI, born = bornI,
      type = typeI, profilepicture = profileI, actual_lat = lat,
        actual_lng = lng, password = passwordI, mail = mailI, delated = delatedI
         WHERE id = idI;
END |
DELIMITER ;



/* updatePosition( pos ) */
DELIMITER |
CREATE PROCEDURE updatePosition(IN uid INT, IN lat DECIMAL(11,8), IN lng DECIMAL(11,8) )
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

/* addEvent */
DELIMITER |
CREATE PROCEDURE addEvent(IN nameI VARCHAR(100), IN placeID INT, IN startdateI TIMESTAMP, IN stopdateI TIMESTAMP, IN creatorI INT, IN typeI VARCHAR(20), IN descriptionI VARCHAR(2000))
BEGIN
  DECLARE canPrivatise VARCHAR(20);
  SELECT type INTO canPrivatise FROM users WHERE id = creator;

  IF type = "private" AND canPrivatise = "basic"
  THEN
    SIGNAL sqlstate '45000' set message_text = "You can't write here!";
  ELSE
    INSERT INTO events (name, place, startdate, stopdate, creator, type, description)
      VALUES (nameI, placeID, startdateI, stopdateI, creatorI, typeI, descriptionI);
  END IF;

END |
DELIMITER ;

/* updateEvent */
DELIMITER |
CREATE PROCEDURE updateEvent(IN idI INT, IN nameI VARCHAR(100), IN placeI INT, IN startdateI TIMESTAMP, IN stopdateI TIMESTAMP, IN creatorI INT, IN typeI VARCHAR(10), IN descriptionI VARCHAR(2000), IN categoryI INT)
BEGIN
  UPDATE events SET id=idI, name=nameI, place = placeI, startdate = startdateI, stopdate = stopdateI,
    creator = creatorI, type = typeI, description = descriptionI, category = categoryI
    WHERE id = idI;
END |
DELIMITER ;

/* AddPlace */
DELIMITER |
CREATE PROCEDURE addPlace(IN latI DECIMAL(11,8), IN lngI DECIMAL(11,8), IN nameI VARCHAR(100), IN addressI VARCHAR(200), IN capI VARCHAR(10), IN cityI VARCHAR(50), IN nationI VARCHAR(50))
BEGIN
  INSERT INTO places (lat, lng, name, address, cap, city, nation) VALUES (latI, lngI, nameI, addressI, capI, cityI, nationI);
END |
DELIMITER ;

/* addCategory */
DELIMITER |
CREATE PROCEDURE addCategory(IN nameI VARCHAR(100), IN descriptionI VARCHAR(2000), IN colourI VARCHAR(6))
BEGIN
  INSERT INTO categories (name, description, colour)
  VALUES (nameI, descriptionI, colourI);
END |
DELIMITER ;

/* getCategories */
DELIMITER |
CREATE PROCEDURE getCategories()
BEGIN
  SELECT * FROM categories;
END |
DELIMITER ;

/* updateCategory */
DELIMITER |
CREATE PROCEDURE updateCategory(IN idI INT, IN nameI VARCHAR(100), IN descriptionI VARCHAR(2000), IN colourI VARCHAR(6))
BEGIN
  UPDATE categories
    SET name = nameI, description = descriptionI, colour = colourI
    WHERE id= idI;
END |
DELIMITER ;

/* getUserDocs( id ) */
DELIMITER |
CREATE PROCEDURE getUserDocs(IN userid INT)
BEGIN
  SELECT * FROM documents WHERE (creator = userid);
END |
DELIMITER ;

/*getUserDoc (idDoc) */
DELIMITER |
CREATE PROCEDURE getUserDoc(IN docid INT)
BEGIN
  SELECT * FROM documents WHERE id = docid;
END |
DELIMITER ;

/* createDoc */
DELIMITER |
CREATE PROCEDURE createDoc(IN creatorI INT, IN nameI VARCHAR(100), IN eventI INT, IN publicI INT)
BEGIN
  INSERT INTO documents (creator, name, event, public) VALUES (creatorI, nameI, eventI, publicI);
END |
DELIMITER ;

/* updateDoc() */
DELIMITER |
CREATE PROCEDURE updateDoc(IN idI INT, IN creatorI INT, IN nameI VARCHAR(100), IN eventI INT, IN publicI INT)
BEGIN
  UPDATE documents
    SET creator = creatorI, name = nameI, event = eventI, public = publicI
    WHERE id = idI;
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

/* createGroup */
DELIMITER |
CREATE  PROCEDURE createGroup(IN nameI VARCHAR (100), IN imageI VARCHAR(300), IN descriptionI VARCHAR(2000), IN adminId INT)
BEGIN
  INSERT INTO groups (name, image, description) VALUES (name, imageI, descriptionI);
  call addMember( adminId, last_insert_id() );
END |
DELIMITER ;

/* updateGroup() */
DELIMITER |
CREATE PROCEDURE updateGroup(IN idI INT, IN nameI VARCHAR(100), IN imageI VARCHAR(300), IN descriptionI VARCHAR(2000))
BEGIN
  UPDATE groups
    SET name = nameI, image = imageI, description = descriptionI
    WHERE id = idI;
END |
DELIMITER ;

/* getGroupInfo() */
DELIMITER |
CREATE PROCEDURE getGroupInfo(IN idI INT)
BEGIN
  SELECT * FROM groups WHERE id = idI;
END |
DELIMITER ;

/* getPlace */
DELIMITER |
CREATE PROCEDURE getPlace(IN idI INT)
BEGIN
  SELECT * FROM places WHERE id = idI;
END |
DELIMITER ;

/* AddMember to a Group */
DELIMITER |
CREATE  PROCEDURE addMember(IN idUserI INT, IN idGroupI INT)
BEGIN
  IF((SELECT count(*) FROM members WHERE idgroup = idGroupI) = 0)
  THEN
    INSERT INTO members (iduser, idgroup, accepted, role) VALUES (idUserI, idGroupI, 1 ,'admin');
  ELSE
    INSERT INTO members (iduser, idgroup) VALUES (idUserI, idGroupI);
  END IF ;
END |
DELIMITER ;

/* addPartecipant to an Event */
DELIMITER |
CREATE PROCEDURE addPartecipant(IN eventId INT, IN userId INT)
BEGIN
  INSERT INTO partecipations (event_id, user_id) VALUES (eventId, userId);
END |
DELIMITER ;

/* updatePartecipation */
DELIMITER |
CREATE PROCEDURE updatePartecipation(IN idI INT, IN eventId INT, IN userId INT, IN statusI VARCHAR(20))
BEGIN
  UPDATE parteciparions
    SET event_id = eventId, user_id = userId, status = statusI
    WHERE id = idI;
END |
DELIMITER ;

/* addNote */
DELIMITER |
CREATE PROCEDURE addNote(IN typeI VARCHAR(7), IN contentI TEXT, IN descriptionI VARCHAR(200))
BEGIN
  INSERT INTO notes (type, content, description) VALUES (typeI, contentI, descriptionI);
END |
DELIMITER ;

/* getNote */
DELIMITER |
CREATE PROCEDURE getNote(IN idI INT)
BEGIN
  SELECT * FROM notes WHERE id = idI;
END |
DELIMITER ;

/* updateNote */
DELIMITER |
CREATE PROCEDURE updateNote(IN idI INT, IN typeI VARCHAR(7), IN contentI TEXT, IN description VARCHAR(200))
BEGIN
  UPDATE notes
    SET type = typeI, content = contentI, description = descriptionI
    WHERE id = idI;
END |
DELIMITER ;

/******** searchUser *********/
DELIMITER |
CREATE PROCEDURE searchUser(IN text VARCHAR(200))
BEGIN
 SELECT userid, name, lastname FROM usersInfo WHERE ( CONCAT_WS(' ', name, lastname) LIKE CONCAT('%', text , '%') OR CONCAT_WS(' ', lastname, name) LIKE CONCAT('%', text , '%') ) LIMIT 10;
END |
DELIMITER ;

/******** searchGroup *********/
DELIMITER |
CREATE PROCEDURE searchGroup(IN text VARCHAR(200))
  BEGIN
    SELECT id, name FROM groups WHERE ( name LIKE CONCAT('%', text , '%') ) LIMIT 10;
  END |
DELIMITER ;

/******** deleteUser *********/
DELIMITER |
CREATE PROCEDURE deleteUser(IN userid INT)
  BEGIN
    UPDATE users SET delated="1" WHERE id=userid;
  END |
DELIMITER ;

/******** addGroupToEvent ****/
DELIMITER |
CREATE PROCEDURE addGroupToEvent(IN groupID INT, IN eventID INT)
  BEGIN
    BEGIN
      DECLARE cursor_ID INT;
      DECLARE done INT DEFAULT FALSE;
      DECLARE cursor_i CURSOR FOR SELECT iduser FROM members WHERE idgroup= groupID AND accepted=1 ;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
      OPEN cursor_i;
      read_loop: LOOP
        FETCH cursor_i INTO cursor_ID;
        IF done THEN
          LEAVE read_loop;
        END IF;
        INSERT INTO partecipations(event_id, user_id) VALUES(eventID, cursor_ID);
      END LOOP;
      CLOSE cursor_i;
    END;

  END |
DELIMITER ;
<<<<<<< HEAD

=======
>>>>>>> origin/ludovico
