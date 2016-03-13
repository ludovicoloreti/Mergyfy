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
  id INT(11) AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  lastname VARCHAR(100) NOT NULL,
  born DATE,
  subscriptiondate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  type ENUM('basic','premium','admin') DEFAULT 'basic',
  image_profile VARCHAR(300),
  latitude DECIMAL(11,8), /* it must be defined */
  longitude DECIMAL(11,8), /* it must be defined */
  password VARCHAR(300) NOT NULL,
  mail VARCHAR(150) NOT NULL,
  delated  ENUM('0','1') DEFAULT '0',
  PRIMARY KEY (id)
) engine=INNODB;

/* GROUPS */
CREATE TABLE IF NOT EXISTS groups(
  id INT(11) AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  creationdate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  image VARCHAR(300),
  description VARCHAR(2000) NOT NULL DEFAULT "No description.",
  PRIMARY KEY (id)
) engine=INNODB;

/* PLACES */
CREATE TABLE IF NOT EXISTS places (
  id INT(11) AUTO_INCREMENT,
  latitude DECIMAL(11,8),
  longitude DECIMAL(11,8),
  name VARCHAR(100) NOT NULL,
  address VARCHAR(200) NOT NULL,
  cap VARCHAR(10),
  city VARCHAR(50) NOT NULL,
  nation VARCHAR(50) NOT NULL DEFAULT "Italy",
  PRIMARY KEY (id)
) engine=INNODB;

/* CATEGORIES */
CREATE TABLE IF NOT EXISTS categories (
  id INT(11) AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(2000),
  colour VARCHAR(6),
  PRIMARY KEY (id)
) engine=INNODB;

/* NOTES */
CREATE TABLE IF NOT EXISTS notes (
  id INT(11) AUTO_INCREMENT,
  type ENUM('code','text', 'image', 'link') DEFAULT 'text',
  content TEXT,
  description VARCHAR(200),
  PRIMARY KEY(id)
) engine=INNODB;

/* MEMBERS */
CREATE TABLE IF NOT EXISTS members(
  user_id INT(11) NOT NULL,
  group_id INT(11) NOT NULL,
  accepted BOOLEAN DEFAULT 0,
  role ENUM('admin','normal') DEFAULT 'normal',
  joindate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, group_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (group_id) REFERENCES groups(id)
) engine=INNODB;

/* EVENTS */
CREATE TABLE IF NOT EXISTS events (
  id INT(11) AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  place_id INT,
  creationdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  startdate TIMESTAMP,
  stopdate TIMESTAMP,
  creator_id INT,
  type ENUM('public','private') DEFAULT 'public',
  description VARCHAR(2000),
  category_id INT,
  PRIMARY KEY (id),
  FOREIGN KEY (place_id) REFERENCES places(id),
  FOREIGN KEY (creator_id) REFERENCES users(id),
  FOREIGN KEY (category_id) REFERENCES categories(id)
) engine=INNODB;

/* DOCUMENTS */
CREATE TABLE IF NOT EXISTS documents (
  id INT(11) AUTO_INCREMENT,
  creator_id INT NOT NULL,
  name VARCHAR(100) DEFAULT "unknown document",
  event_id INT NOT NULL,
  creationdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  public ENUM('0','1') DEFAULT '1',
  PRIMARY KEY (id),
  FOREIGN KEY (creator_id) REFERENCES users(id),
  FOREIGN KEY (event_id) REFERENCES events(id)

) engine=INNODB;

/* NODES */
CREATE TABLE IF NOT EXISTS nodes (
  id INT(11) AUTO_INCREMENT,
  document_id INT(11),
  note_id INT(11),
  creationdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  title VARCHAR(200) DEFAULT "Title",
  PRIMARY KEY (id),
  FOREIGN KEY (document_id) REFERENCES documents(id),
  FOREIGN KEY (note_id) REFERENCES notes(id)
) engine=INNODB;

/* PARTECIPATIONS */
CREATE TABLE IF NOT EXISTS partecipations (
  event_id INT(11) NOT NULL,
  user_id INT(11) NOT NULL,
  status ENUM('accepted','declined','waiting') DEFAULT 'waiting',
  PRIMARY KEY (event_id, user_id),
  FOREIGN KEY(event_id) REFERENCES events(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
) engine=INNODB;

/******************** VIEWS *************************/

CREATE VIEW usersInfo(id, name, lastname, born, subscriptiondate, type, image_profile, mail) AS
  SELECT id, name, lastname, born, subscriptiondate, type, image_profile, mail FROM users WHERE delated="0";

/* TODO */

/******************** TRIGGERS **********************/

/* 1 - check_user
  Checks the user date of birth
  Checks the mail format
  Checks if the mail is duplicated
*/
DELIMITER //
create trigger check_user
BEFORE INSERT ON merge.users
FOR EACH ROW
BEGIN
  -- CURRENT_TIMESTAMP() - UNIX_TIMESTAMP(NEW.born) > 1009846861  -- 14yo in timestamp
	IF (NEW.born IS NULL) OR ( (YEAR(CURRENT_TIMESTAMP()) - YEAR(NEW.born) - (DATE_FORMAT(CURRENT_TIMESTAMP(), '%m%d') < DATE_FORMAT(NEW.born, '%m%d'))) < 14 )
  THEN
    SIGNAL sqlstate '45000' SET message_text = "Age must be more than 14 yo";
	END IF;

	IF ( (NEW.mail NOT REGEXP '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$' ) OR (NEW.mail = ANY (SELECT usr.mail FROM users AS usr WHERE usr.delated = "0")) )
  THEN
    SIGNAL sqlstate '45000' SET message_text = "Invalid email address";
	END IF;
END //
DELIMITER ;

/* 2 - check_event_creation
  - Checks the if the creation date is correct
  (it can be omitted since we use a stored procedure and set creation with current_timestamp)

  - Checks if the email provided by the user is correct.

  - Check if the startdate comes before the stopdate
*/
DELIMITER //
create trigger check_event
BEFORE INSERT ON merge.events
FOR EACH ROW
BEGIN
	IF ( (NEW.creationdate IS NULL) OR (NEW.creationdate > CURRENT_TIMESTAMP()) )
  THEN
      SIGNAL sqlstate '45000' SET message_text = "Invalid creation date";
	END IF;

  IF ( NEW.startdate > NEW.stopdate )
  THEN
    SIGNAL sqlstate '45000' SET message_text = "Date interval is not correct";
  END IF;
END //
DELIMITER ;

/* 3 - check_admin
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
      WHERE (group_id = OLD.group_id) AND (user_id = (SELECT user_id FROM members WHERE group_id = OLD.group_id HAVING min(joindate)));
	END IF;
END //
DELIMITER ;

/* 4 - check_note
  Checks if an image note or a link note has the description associated
*/
DELIMITER //
create trigger ceck_note
BEFORE INSERT ON merge.notes
FOR EACH ROW
BEGIN
	IF ( (NEW.type = "image" OR NEW.type = "link") AND (NEW.description IS NULL) )
  THEN
    SIGNAL sqlstate '45000' SET message_text = "You must provide a description";
  END IF;
END //
DELIMITER ;


/******************** STORED PROCEDURES **********************/

/* login( mail, password, latitude, longitude )
    Authenticate the user and set his location.
*/
DELIMITER |
CREATE PROCEDURE login( IN mail VARCHAR(150), IN password VARCHAR(300), IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  DECLARE user_id INT default -1;
  SELECT usr.id INTO user_id FROM users AS usr WHERE (usr.mail = mail) AND (usr.password = password) LIMIT 1;
  IF (user_id <> -1) THEN
    call updatePosition(user_id, latitude, longitude);
    call getUser(user_id);
  END IF;
END |
DELIMITER ;

/* updatePosition( user_id, latitude, longitude ) */
DELIMITER |
CREATE PROCEDURE updatePosition(IN user_id INT, IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  IF ( (latitude IS NOT NULL) AND (longitude IS NOT NULL) ) THEN
    UPDATE users AS usr SET usr.latitude = latitude, usr.longitude = longitude WHERE (usr.id = user_id);
  END IF;
END |
DELIMITER ;
/**
/* getUser( user_id ) */
DELIMITER |
CREATE PROCEDURE getUser(IN user_id INT)
BEGIN
  SELECT * FROM usersInfo AS usr WHERE usr.id = user_id;
END |
DELIMITER ;

/* insertUser(name, lastname, born, type, image_profile, password, mail)
    Insert a User TODO
*/
DELIMITER |
CREATE PROCEDURE insertUser(IN name VARCHAR(100),
 IN lastname VARCHAR(100),
 IN born DATE,
 IN type INT,
 IN image_profile VARCHAR(300),
 IN password VARCHAR(300),
 IN mail VARCHAR(150),
 OUT id INT)
BEGIN
  IF type = 1 THEN
    INSERT INTO users(name, lastname, born, type, image_profile, password, mail)
      VALUES(name, lastname, born, "premium", image_profile, password, mail);
  ELSEIF type = 2 THEN
    INSERT INTO users(name, lastname, born, type, image_profile, password, mail)
      VALUES(name, lastname, born, "admin", image_profile, password, mail);
  ELSE
    INSERT INTO users(name, lastname, born, image_profile, password, mail)
      VALUES(name, lastname, born, image_profile, password, mail);
  END IF;
  SELECT LAST_INSERT_ID() AS last_id INTO id ;
END |
DELIMITER ;

/* userNearEvents( userid, latitude, longitude, dist )
    Select a number of places filtered by a given distance (in km)
*/
DELIMITER |
CREATE PROCEDURE userNearEvents(IN user_id INT, IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8), IN dist INT )
BEGIN
  DECLARE userLng DOUBLE;
  DECLARE userLat DOUBLE;
  SET userLng = longitude;
  SET userLat = latitude;
  -- Get old position if not provided a new one
  IF ( ((userLat IS NULL) AND (userLng IS NULL)) OR ((userLat = 0) AND (userLng = 0)) ) THEN
    SELECT usr.longitude, usr.latitude INTO userLng, userLat FROM users AS usr WHERE (usr.id = user_id) LIMIT 1;
  END IF;
  -- Neither old position nor new position
  IF ( ((userLat IS NULL) AND (userLng IS NULL)) OR ((userLat = 0) AND (userLng = 0)) ) THEN
    SIGNAL sqlstate '45000' SET message_text = "No position no party";
  ELSE
    -- Find Events
    SELECT evnt.id AS event_id, evnt.name AS event_name, evnt.creationdate AS creationdate, evnt.startdate AS startdate, evnt.stopdate AS stopdate, evnt.description AS event_description,
           usr.id AS creator_id, usr.name AS creator_name, usr.lastname AS creator_lastname,
           plc.id AS place_id, plc.name AS place_name, plc.address AS address, plc.latitude AS latitude, plc.longitude AS longitude,
           ( 3959 * acos( cos( radians(userLat) ) * cos( radians( plc.latitude ) ) * cos( radians( plc.longitude ) - radians(userLng) ) + sin( radians(userLat) ) * sin( radians( plc.latitude ) ) ) ) AS calculated_distance
    FROM events AS evnt, places AS plc, users AS usr
    WHERE (evnt.place_id = plc.id) AND (evnt.creator_id = usr.id)
    HAVING (calculated_distance < dist)
    ORDER BY calculated_distance;
  END IF;
END |
DELIMITER ;

/* getUserEvents( user_id, which )
    Select events in which the user has been invited to. We can decide wheter
    to get all the set of events or only the next/past ones.
*/
DELIMITER |
CREATE PROCEDURE getUserEvents( IN user_id INT, IN which ENUM('next','past','all') )
BEGIN
  CASE which
    WHEN 'next' THEN
      SELECT * FROM partecipations AS part, events AS evnt, places AS plc
        WHERE ( (part.event_id = evnt.id) AND (part.user_id = user_id) AND (evnt.place_id = plc.id) AND (evnt.startdate > current_timestamp()) );
    WHEN 'past' THEN
      SELECT * FROM partecipations AS part, events AS evnt, places AS plc
        WHERE ( (part.event_id = evnt.id) AND (part.user_id = user_id) AND (evnt.place_id = plc.id) AND (evnt.stopdate < current_timestamp()) );
    ELSE
      SELECT * FROM partecipations AS part, events AS evnt, places AS plc
        WHERE ( (part.event_id = evnt.id) AND (part.user_id = user_id) AND (evnt.place_id = plc.id) );
  END CASE;
END |
DELIMITER ;

/* searchEvents( userid, text )
    Search for all public events or private ,if the user has been invited to (or he's the creator).
*/
DELIMITER |
CREATE PROCEDURE searchEvents(IN user_id INT, IN chars VARCHAR(200))
  BEGIN
    -- search (1) public events (2) partecipation
    (SELECT evnt.id, evnt.name FROM events AS evnt, places AS plc
      WHERE ( (evnt.place_id = plc.id) AND (evnt.type="public") AND (evnt.name LIKE CONCAT('%', chars , '%')) ) LIMIT 6)
    UNION
    (SELECT evnt.id, evnt.name FROM events AS evnt, places AS plc, partecipations AS part
      WHERE ( (evnt.place_id = plc.id) AND (part.event_id = evnt.id) AND (part.user_id = user_id) AND (evnt.name LIKE CONCAT('%', chars , '%')) ) LIMIT 6);
  END |
DELIMITER ;

/* suggestedEvents()
  Suggest some public events near the user. TODO
*/
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
CREATE PROCEDURE suggestedPlaces(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8), IN dist DECIMAL(11,8))
BEGIN
  SELECT plc.* , ( 3959 * acos( cos( radians(latitude) ) * cos( radians( plc.latitude ) ) * cos( radians( plc.longitude ) - radians(longitude) ) + sin( radians(latitude) ) * sin( radians( plc.latitude ) ) ) ) AS calculated_distance
  FROM places as plc
  HAVING ( calculated_distance < dist )
  ORDER BY calculated_distance;
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

/* getEvents() */
DELIMITER |
CREATE PROCEDURE getEvents()
BEGIN
  SELECT * FROM events;
END |
DELIMITER ;

/* getEvent( id ) */
DELIMITER |
CREATE PROCEDURE getEvent(IN userid INT, IN eventid INT)
BEGIN
  -- Verify user partecipation
  DECLARE presenza INT default 0;
  SELECT COUNT(*) INTO presenza FROM partecipations AS p WHERE (p.user_id=userid) AND (p.event_id=eventid);

  IF presenza = 1 THEN
    SELECT * FROM events AS e, places AS p, usersInfo AS u WHERE (e.creator = u.userid) AND  (e.place = p.id) AND (e.id = eventid);
  ELSE
    SIGNAL sqlstate '45000' set message_text = "You are not a partecipant!";
  END IF;
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

/**/

/*  createNote(  ) */
DELIMITER |
CREATE PROCEDURE createNote(IN type ENUM('code','text', 'image', 'link'), IN content TEXT, IN description VARCHAR(200), OUT lastid INT)
BEGIN
  SET lastid = 0;
  INSERT INTO notes(type, content, description) VALUES (type, content, description);
  SELECT last_insert_id() INTO lastid;
END |
DELIMITER ;

/* createNode() */
DELIMITER |
CREATE PROCEDURE createNode(IN document_id INT, IN note_id INT, IN title VARCHAR(200))
BEGIN
  INSERT INTO nodes(document_id, note_id, title) VALUES (document_id, note_id, title);
END |
DELIMITER ;

/* addNoteToDoc() */
DELIMITER |
CREATE PROCEDURE addNoteToDoc(IN type ENUM('code','text', 'image', 'link'), IN content TEXT, IN description VARCHAR(200), IN document_id INT, IN title VARCHAR(200))
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "Generic error" as "";
      ROLLBACK;
    END;

  START TRANSACTION;
  call createNote(type, content, description, @lastid);
  IF (@lastid <> 0) THEN
    call createNode(document_id, @lastid, title);
    COMMIT;
  ELSE
    SIGNAL sqlstate '45000' set message_text = "Insert Error";
    ROLLBACK;
  END IF;
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
