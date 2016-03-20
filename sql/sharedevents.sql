/*
  SHARED EVENT DATABASE
  TABLES:
   1 -  users
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

    5a - Enter the DB: /Applications/MAMP/Library/bin/mysql --user= <user> --password= <user-password>;

    5b - Enter the DB: /Applications/MAMP/Library/bin/mysql --user=user --password=user-password;
    /Applications/MAMP/Library/bin/mysql --user=root --password=root;

    TODO: foreign key references
    TODO: notes: user_id
    TODO: documents: delete id
    TODO: how to handle partecipation status: "waiting", "accepted"
    TODO: how to handle members accepted: BOOLEAN?

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
  name VARCHAR(100) NOT NULL,
  description VARCHAR(2000),
  colour VARCHAR(6),
  PRIMARY KEY (name)
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
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
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
  category_name VARCHAR(100) default 'not given',
  PRIMARY KEY (id),
  FOREIGN KEY (place_id) REFERENCES places(id),
  FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (category_name) REFERENCES categories(name) ON DELETE SET NULL
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
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE SET NULL

) engine=INNODB;

/* NODES */
CREATE TABLE IF NOT EXISTS nodes (
  id INT(11) AUTO_INCREMENT,
  document_id INT(11),
  note_id INT(11),
  creationdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  title VARCHAR(200) DEFAULT "Title",
  PRIMARY KEY (id),
  FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
  FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
) engine=INNODB;

/* PARTECIPATIONS */
CREATE TABLE IF NOT EXISTS partecipations (
  event_id INT(11) NOT NULL,
  user_id INT(11) NOT NULL,
  status ENUM('accepted','declined','waiting') DEFAULT 'waiting',
  PRIMARY KEY (event_id, user_id),
  FOREIGN KEY(event_id) REFERENCES events(id) ON DELETE CASCADE,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
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

  IF ( NEW.category_name IS NULL )
  THEN
    SIGNAL sqlstate '45000' SET message_text = "you should specify a category";
  END IF;

END //
DELIMITER ;

/* 3 - check_admin
  When an admin leaves a group, it replaces the admin with the first member who has joined the group.
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
  (NECESSARLY?)
*/
DELIMITER //
create trigger check_note
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

/* updatePosition( user_id, latitude, longitude )
  Update a user's position given his id.
*/
DELIMITER |
CREATE PROCEDURE updatePosition(IN user_id INT, IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  IF ( (latitude IS NOT NULL) AND (longitude IS NOT NULL) ) THEN
    UPDATE users AS usr SET usr.latitude = latitude, usr.longitude = longitude WHERE (usr.id = user_id);
  END IF;
END |
DELIMITER ;

/* getUser( user_id ) */
DELIMITER |
CREATE PROCEDURE getUser(IN user_id INT)
BEGIN
  SELECT * FROM usersInfo AS usr WHERE usr.id = user_id;
END |
DELIMITER ;

/* insertUser(name, lastname, born, type, image_profile, password, mail)
    Insert a User TODO decide which element to insert
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

/* userNearEvents( user_id, latitude, longitude, dist )
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
    SIGNAL sqlstate '45000' SET message_text = "No position, no party";
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

/* searchEvents( user_id, chars )
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
  Suggest some public events near the user. TODO check users' rights on events @pinair
*/
DELIMITER |
CREATE PROCEDURE suggestedEvents(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  SELECT ev.id as eventId, ev.name as eventName, ev.creation as dateCreation, ev.start as dateStart, ev.stop as dateStop, ev.description as eventDesc,
         u.id as creatorId, u.name as creatorName, u.lastname as creatorLastname,
         pl.id as placeId, pl.name as placeName, pl.address as placeAddress, pl.lat as placeLat, pl.lng as placeLng,
         ( 3959 * acos( cos( radians(latitude) ) * cos( radians( pl.lat ) ) * cos( radians( pl.lng ) - radians(longitude) ) + sin( radians(latitude) ) * sin( radians( pl.lat ) ) ) ) AS distance
  FROM events as ev, places as pl, users as u
  WHERE (ev.place = pl.id)  AND (ev.type='public') 
  HAVING (distance < dist)
  ORDER BY distance;
END |
DELIMITER ;

/* suggestedPlaces(latitude, longitude, dist)
  Resturns a set of suggested places based on the user's position.
*/
DELIMITER |
CREATE PROCEDURE suggestedPlaces(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8), IN dist DECIMAL(11,8))
BEGIN
  SELECT plc.* , ( 3959 * acos( cos( radians(latitude) ) * cos( radians( plc.latitude ) ) * cos( radians( plc.longitude ) - radians(longitude) ) + sin( radians(latitude) ) * sin( radians( plc.latitude ) ) ) ) AS calculated_distance
  FROM places as plc
  HAVING ( calculated_distance < dist )
  ORDER BY calculated_distance;
END |
DELIMITER ;

/* updateUser(id, name, lastname, born, image_profile, mail)
  Update the trustworty information only.
*/
DELIMITER |
CREATE PROCEDURE updateUser( IN id INT,
 IN name varchar(100),
 IN lastname varchar(100),
 IN born date,
 IN image_profile varchar(300),
 IN mail varchar(150))
BEGIN
  UPDATE usersInfo AS usr
    SET usr.name = name, usr.lastname = lastname, usr.born = born,
      usr.type = type, usr.image_profile = image_profile, usr.mail = mail
         WHERE usr.id = id;
END |
DELIMITER ;

/* upgradeUser(user_id)
  cahnge the grade from basic to premium.
*/
DELIMITER |
CREATE PROCEDURE upgradeUser(IN user_id INT)
  BEGIN
    DECLARE type VARCHAR(100) DEFAULT "";
    SELECT usr.type INTO type FROM usersInfo AS usr WHERE usr.id = user_id;

    IF type="basic" THEN
      UPDATE usersInfo AS usr SET usr.type="premium" WHERE usr.id=user_id;
    ELSEIF type="premium" THEN
      SIGNAL sqlstate '45000' set message_text = "You are already premium";
    ELSE
      SIGNAL sqlstate '45000' set message_text = "User error";
    END IF;
  END |
DELIMITER ;

/* changePassword( user_id, old_password, new_password)
  Change the password for the specified user.
*/
DELIMITER |
CREATE PROCEDURE changePassword(IN user_id INT, IN old_password VARCHAR(300), IN new_password VARCHAR(300))
  BEGIN
    UPDATE users AS usr SET usr.password= new_password WHERE ( (usr.id= user_id) AND (usr.password= old_password) );
  END |
DELIMITER ;

/* deleteUser(user_id)
  Fake user delate: set a "delated" variable true
*/
DELIMITER |
CREATE PROCEDURE deleteUser(IN user_id INT)
  BEGIN
    UPDATE users AS usr SET usr.delated="1" WHERE usr.id=user_id;
  END |
DELIMITER ;

/* damnatioMemoriae( user_id )
  Delate the user from the table.  TODO: handle the deletion of an user and his dependencies @pinair
*/
DELIMITER |
CREATE PROCEDURE damnatioMemoriae(IN user_id INT)
  BEGIN
    DELETE FROM users WHERE users.id= user_id;
  END |
DELIMITER ;

/* getEvents()
  Gets all events TODO: is it useful? No. @pinair
*/
DELIMITER |
CREATE PROCEDURE getEvents()
BEGIN
  SELECT * FROM events;
END |
DELIMITER ;

/* getEvent( user_id, event_id )
  Return Event, Creator and Place info TODO: what about categories? @pinair
*/
DELIMITER |
CREATE PROCEDURE getEvent(IN user_id INT, IN event_id INT)
BEGIN
  -- Verify user partecipation
  DECLARE presenza INT default 0;
  SELECT COUNT(*) INTO presenza FROM partecipations AS part WHERE (part.user_id= user_id) AND (part.event_id= event_id);

  IF presenza = 1 THEN
    SELECT evnt.id AS event_id, evnt.type AS event_type, evnt.name AS event_name, evnt.description AS event_description, evnt.creationdate, evnt.startdate, evnt.stopdate,
    evnt.category_name, evnt.place_id, plc.name AS place_name, plc.latitude, plc.longitude, plc.address, plc.city, plc.cap, plc.nation,
    evnt.creator_id, usr.name AS creator_name, usr.lastname AS creator_lastname, usr.image_profile AS creator_image_profile
    FROM events AS evnt, places AS plc, usersInfo AS usr, categories AS cat WHERE (evnt.creator_id = usr.id) AND  (evnt.place_id = plc.id) AND (evnt.id = event_id) AND (evnt.category_name = cat.name);
  ELSE
    SIGNAL sqlstate '45000' set message_text = "You are not a partecipant!";
    -- cat.name AS category_name, cat.description AS category_description, cat.colour AS category_colour,
  END IF;
END |
DELIMITER ;

/* addPlace()
  TODO: check the duplication? No. Add Store Procedure similarPlaces below @pinair
*/
DELIMITER |
CREATE PROCEDURE addPlace(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8), IN name VARCHAR(100), IN address VARCHAR(200), IN cap VARCHAR(10), IN city VARCHAR(50), IN nation VARCHAR(50))
BEGIN
  INSERT INTO places (latitude, longitude, name, address, cap, city, nation) VALUES (latitude, longitude, name, address, cap, city, nation);
END |
DELIMITER ;

/* similarPlaces()
  Return the places nearby the new place coordinates (maybe the place to add is inside the db yet?) @pinair [ADDED]
*/
DELIMITER |
CREATE PROCEDURE similarPlaces(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  --Get all the places in 50 meters
  SELECT evnt, ( 3959 * acos( cos( radians(latitude) ) * cos( radians( plc.latitude ) ) * cos( radians( plc.longitude ) - radians(longitude) ) + sin( radians(latitude) ) * sin( radians( plc.latitude ) ) ) ) AS calculated_distance
  FROM events AS evnt
  HAVING calculated_distance < 50
  ORDER BY calculated_distance 
END |
DELIMITER ;

/* addEvent(name, description, place_id, startdate, stopdate, creator_id, event_type)
  Check if the user has the permission to create a private event: If there aren't problems it creates the event
  TODO: Use a trigger to control the insertion @pinair isn't already done here?
*/
DELIMITER |
CREATE PROCEDURE addEvent(IN name VARCHAR(100), IN description VARCHAR(2000), IN place_id INT, IN startdate TIMESTAMP, IN stopdate TIMESTAMP, IN creator_id INT, IN event_type VARCHAR(20), category_name VARCHAR(20))
BEGIN
  DECLARE user_type VARCHAR(20);
  SELECT usr.type INTO user_type FROM users AS usr WHERE usr.id = creator_id;

  IF event_type = "private" AND user_type = "basic"
  THEN
    SIGNAL sqlstate '45000' set message_text = "A basic user can't create private events!";
  ELSE
    INSERT INTO events (name, place_id, startdate, stopdate, creator_id, type, description, category_name)
      VALUES (name, place_id, startdate, stopdate, creator_id, event_type, description, category_name);
  END IF;

END |
DELIMITER ;

/* updateEvent()
  Update event infos TODO: how to implement place, event partecipants and docs? @pinair what's the question?
*/
DELIMITER |
CREATE PROCEDURE updateEvent(IN idI INT, IN nameI VARCHAR(100), IN placeI INT, IN startdateI TIMESTAMP, IN stopdateI TIMESTAMP, IN creatorI INT, IN typeI VARCHAR(10), IN descriptionI VARCHAR(2000), IN categoryI INT)
BEGIN
  UPDATE events SET id=idI, name=nameI, place = placeI, startdate = startdateI, stopdate = stopdateI,
    creator = creatorI, type = typeI, description = descriptionI, category = categoryI
    WHERE id = idI;
END |
DELIMITER ;

/* createCategory(name, description, colour)
  Simply adds a category.
*/
DELIMITER |
CREATE PROCEDURE createCategory(IN name VARCHAR(100), IN description VARCHAR(2000), IN colour VARCHAR(6))
BEGIN
  INSERT INTO categories (name, description, colour) VALUES (name, description, colour);
END |
DELIMITER ;

/* getCategories()
  Get all categories infos.
*/
DELIMITER |
CREATE PROCEDURE getCategories()
BEGIN
  SELECT * FROM categories;
END |
DELIMITER ;

/* updateCategory
  Update a category given the old name TODO think about the primary key... @pinair done
*/
DELIMITER |
CREATE PROCEDURE updateCategory(IN oldname VARCHAR(100), IN name VARCHAR(100), IN description VARCHAR(2000), IN colour VARCHAR(6))
BEGIN
  DECLARE checkname INT DEFAULT 0;
  SELECT COUNT(*) INTO checkname FROM categories AS cat WHERE cat.name = name;

  IF checkname = 0 THEN
    UPDATE categories AS cat SET cat.name = name, cat.description = description, cat.colour = colour WHERE cat.name = oldname;
  ELSE
    SIGNAL sqlstate '45000' set message_text = "the specified category name already exists";
  END IF;
END |
DELIMITER ;

/* getUserDocs(user_id)
  Gets all user's documents given his id.
*/
DELIMITER |
CREATE PROCEDURE getUserDocs(IN user_id INT)
BEGIN
  SELECT * FROM documents AS doc WHERE (doc.creator_id = user_id);
END |
DELIMITER ;

/* getUserDoc(doc_id)
  Get document content. TODO: do we need to check rights? no, why we should? @pinair
*/
DELIMITER |
CREATE PROCEDURE getUserDoc(IN doc_id INT)
BEGIN
  SELECT * FROM documents AS doc WHERE doc.id = doc_id;
END |
DELIMITER ;

/* createDoc(creator_id, name, event_id, visibility_type)
  creates a document, if the user has the rights TODO: check creation rights  @pinair DONE
 */
DELIMITER |
CREATE PROCEDURE createDoc(IN creator_id INT, IN name VARCHAR(100), IN event_id INT, IN visibility_type ENUM('0', '1'))
BEGIN
  DECLARE alreadyExists VARCHAR(150) DEFAULT NULL;
  SELECT name INTO alreadyExists FROM documents AS doc WHERE doc.creator_id = creator_id AND doc.event_id = event_id;
  IF alreadyExists = NULL
  THEN
    SIGNAL sqlstate '4500' set message_text = "The documents already exists!";
  ELSE
    INSERT INTO documents (creator, name, event, public) VALUES (creator_id, name, event_id, visibility_type);
  END IF;
END |
DELIMITER ;

/* updateDocName()
  Update a document name
*/
DELIMITER |
CREATE PROCEDURE updateDocName(IN doc_id INT, IN user_id INT, IN name VARCHAR(100))
BEGIN
  DECLARE checkCreation INT DEFAULT 0;
  -- check rights
  SELECT COUNT(*) INTO checkCreation FROM document AS doc WHERE doc.id = doc_id AND doc.creator_id = user_id;
  IF checkCreation = 1 THEN
    UPDATE documents AS doc SET doc.name = name WHERE doc.id = user_id;
  ELSE
    SIGNAL sqlstate '45000' set message_text = "A user can't update other user's document";
  END IF;
END |
DELIMITER ;

/* updateDocVisibility()
  Update doc visibility.
*/
DELIMITER |
CREATE PROCEDURE updateDocVisibility(IN doc_id INT, IN user_id INT, IN public ENUM("0", "1"))
BEGIN
  DECLARE checkCreation INT DEFAULT 0;
  -- check rights
  SELECT COUNT(*) INTO checkCreation FROM document AS doc WHERE doc.id = doc_id AND doc.creator_id = user_id;
  IF checkCreation = 1 THEN
    UPDATE documents AS doc SET doc.public = public WHERE doc.id = user_id;
  ELSE
    SIGNAL sqlstate '45000' set message_text = "An user can't update other user's document";
  END IF;
END |
DELIMITER ;

/*  getDocContent( id )
  TODO
*/
DELIMITER |
CREATE PROCEDURE getDocContent(IN doc_id INT)
BEGIN
  SELECT * FROM notes,nodes WHERE (nodes.note_id = notes.id) AND (nodes.document_id = doc_id);
END |
DELIMITER ;

/* createNote(type, content, description, @lastid)
  Creates a note and returns its id.
*/
DELIMITER |
CREATE PROCEDURE createNote(IN type ENUM('code','text', 'image', 'link'), IN content TEXT, IN description VARCHAR(200), OUT lastid INT)
BEGIN
  SET lastid = 0;
  INSERT INTO notes(type, content, description) VALUES (type, content, description);
  SELECT last_insert_id() INTO lastid;
END |
DELIMITER ;

/* createNode(document_id, note_id, title)
  Creates a node given document id and a note id
*/
DELIMITER |
CREATE PROCEDURE createNode(IN document_id INT, IN note_id INT, IN title VARCHAR(200))
BEGIN
  INSERT INTO nodes(document_id, note_id, title) VALUES (document_id, note_id, title);
END |
DELIMITER ;

/* addNoteToDoc(type, content, description, document_id, title)
  Creates a note and then adds the note to a document.
 */
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

/* getGroupMembers(group_id)
  Get members given a group id.
*/
DELIMITER |
CREATE PROCEDURE getGroupMembers(IN group_id INT)
BEGIN
  SELECT * FROM members as mmbr, usersInfo as usr
  WHERE (mmbr.group_id = group_id) AND (mmbr.user_id = usr.id);
END |
DELIMITER ;

/* getEventPartecipants(event_id)
  Gets every users that partecipate to an event TODO: all or only "accepted"? @pinair only accepted here, only waiting and declined below
*/
DELIMITER |
CREATE PROCEDURE getEventPartecipants(IN event_id INT)
BEGIN
  SELECT * FROM partecipations as part, usersInfo as usr
  WHERE (part.event_id = event_id) AND (part.user_id = usr.id) AND (part.status = "accepted"); -- all or only "accepted" ?
END |
DELIMITER ;

/* getEventWaitingPartecipans(event_id)
  Gets every users that haven't still answered to the invitation @pinair NEW
*/
DELIMITER |
CREATE PROCEDURE getEventWaitingPartecipants(IN event_id INT)
BEGIN
  SELECT * FROM partecipations as part, usersInfo as usr
  WHERE (part.event_id = event_id) AND (part.user_id = usr.id) AND (part.status = "waiting"); -- all or only "accepted" ?
END |
DELIMITER ;

/* getEventDeclinedPartecipans(event_id)
  Gets every users that won't enjoy the event @pinair NEW
*/
DELIMITER |
CREATE PROCEDURE getEventDeclinedPartecipants(IN event_id INT)
BEGIN
  SELECT * FROM partecipations as part, usersInfo as usr
  WHERE (part.event_id = event_id) AND (part.user_id = usr.id) AND (part.status = "declined"); -- all or only "accepted" ?
END |
DELIMITER ;

/* createGroup(name, image, description, admin_id)
  Create a group and set the admin
*/
DELIMITER |
CREATE PROCEDURE createGroup(IN name VARCHAR (100), IN image VARCHAR(300), IN description VARCHAR(2000), IN admin_id INT)
BEGIN
  -- transaction
  INSERT INTO groups (name, image, description) VALUES (name, image, description);
  call addMember(admin_id, last_insert_id());
END |
DELIMITER ;

/* addMember(user_id, group_id)
  Adds a member to a group. The first member is an admin.
*/
DELIMITER |
CREATE PROCEDURE addMember(IN user_id INT, IN group_id INT)
BEGIN
  IF((SELECT COUNT(*) FROM members AS mmbr WHERE mmbr.group_id = group_id) = 0)
  THEN
    INSERT INTO members (user_id, group_id, accepted, role) VALUES (user_id, group_id, 1 ,'admin');
  ELSE
    INSERT INTO members (user_id, group_id) VALUES (user_id, group_id);
  END IF ;
END |
DELIMITER ;

/* acceptMembership(user_id, group_id)
  Accept invitation to a group.
*/
DELIMITER |
CREATE PROCEDURE acceptMembership(IN user_id INT, IN group_id INT)
BEGIN
  UPDATE members AS mmbr SET mmbr.accepted = 1 WHERE ( (mmbr.user_id = user_id) AND (mmbr.group_id = group_id) ) ;
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

/* addPartecipant to an Event */
DELIMITER |
CREATE PROCEDURE addPartecipant(IN eventId INT, IN userId INT)
BEGIN
  INSERT INTO partecipations (event_id, user_id, status) VALUES (eventId, userId, 'waiting');
END |
DELIMITER ;

/* updatePartecipation */
DELIMITER |
CREATE PROCEDURE updatePartecipation(IN idI INT, IN eventId INT, IN userId INT, IN statusI VARCHAR(20))
BEGIN
  UPDATE partecipations
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
CREATE PROCEDURE updateNote(IN idI INT, IN typeI VARCHAR(7), IN ccall updateNote(1, 'link', 'www.google.it', 'Sito di Google'); ontentI TEXT, IN descriptionI VARCHAR(200))
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
 SELECT id, name, lastname FROM usersInfo WHERE ( CONCAT_WS(' ', name, lastname) LIKE CONCAT('%', text , '%') OR CONCAT_WS(' ', lastname, name) LIKE CONCAT('%', text , '%') ) LIMIT 10;
END |
DELIMITER ;

/******** searchGroup *********/
DELIMITER |
CREATE PROCEDURE searchGroup(IN text VARCHAR(200))
  BEGIN
    SELECT id, name FROM groups WHERE ( name LIKE CONCAT('%', text , '%') ) LIMIT 10;
  END |
DELIMITER ;

/******** addGroupToEvent ****/
DELIMITER |
CREATE PROCEDURE addGroupToEvent(IN groupID INT, IN eventID INT)
  BEGIN
    BEGIN
      DECLARE cursor_ID INT;
      DECLARE done INT DEFAULT FALSE;
      DECLARE cursor_i CURSOR FOR SELECT user_id FROM members WHERE group_id= groupID AND accepted=1 ;
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

/* checkRights(userid, user)
  An user is allowed to see:
   - his docs
   - every doc from an event which he's invited to
*/
DELIMITER |
CREATE PROCEDURE checkRights(IN user_id INT, IN doc_id INT, OUT result INT)
  BEGIN

  END |
DELIMITER ;




