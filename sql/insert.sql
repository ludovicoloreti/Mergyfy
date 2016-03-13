
INSERT INTO `users` (`id`, `name`, `lastname`, `born`, `subscriptiondate`, `type`, `profilepicture`, `actual_lat`, `actual_lng`, `password`, `mail`, `delated`) VALUES
(1, 'Filippo', 'Boiani', '1993-10-28', '2016-02-29 22:26:13', 'basic', NULL, '44.48407585', '11.23867035', 'HASHEDPASS', 'mail@mail.com', '0'),
(2, 'Riccardo', 'Sibani', '1994-09-24', '2016-02-29 22:34:38', 'basic', NULL, '44.48407585', '11.23867035', 'HASHEDPASS', 'mail@mail.com', '0'),
(3, 'Ludovico', 'Loreti', '1992-11-11', '2016-02-29 22:08:42', 'basic', NULL, '44.48407585', '11.23867035', 'HASHEDPASS', 'mail@mail.com', '0'),
(4, 'Antonio', 'Messina', '1899-01-01', '2016-02-29 22:08:42', 'basic', NULL, '44.48407585', '11.23867035', 'HASHEDPASS', 'mail@mail.com', '0'),
(5, 'Andrea', 'Diprè', '1960-01-01', '2016-02-29 22:08:42', 'basic', NULL, '44.48407585', '11.23867035', 'HASHEDPASS', 'mail@mail.com', '0');

INSERT INTO `places` (`id`, `lat`, `lng`, `name`, `address`, `cap`, `city`, `nation`) VALUES
(1, '44.48807585', '11.23837035', 'Duomo di Milano', 'Piazza Duomo 1', NULL, 'Milano', 'Italy'),
(2, '44.495158', '11.335874', 'Torre di Pisa', 'Piazza dei miracoli', NULL, 'Pisa', 'Italy'),
(3, '44.490995', '11.335101', 'Palazzo re Enzo', 'Piazza del Nettuno 1', NULL, 'Bologna', 'Italy'),
(4, '44.501280', '11.340165', 'Villa Antani', 'Piazza di Villa Antani 27', NULL, 'Bologna', 'Italy'),
(5, '44.496260', '11.343770', 'Palazzo del Monte', 'Via del Monte, 6', NULL, 'Bologna', 'Italy'),
(6, '44.490260', '11.348748', 'Casa di Jerry Cala', 'Via De Chiari, 6', NULL, 'Bologna', 'Italy');

INSERT INTO `events` (`id`, `name`, `place`, `creationdate`, `startdate`, `stopdate`, `creator`, `type`, `description`, `categoryid`) VALUES
(1, 'Saluto alla Madonna', 1, '2016-02-29 22:08:42', '2016-02-29 22:08:42', '2016-02-29 22:08:42', 1, 'public', 'Bellissmo Evento', NULL),
(2, 'Salto dalla torre', 2, '2016-02-29 22:08:42', '2016-02-29 22:08:42', '2016-02-29 22:08:42', 1, 'public', 'Bello da morire', NULL),
(3, 'Rob0t Festival', 3, '2016-02-29 22:08:42', '2016-02-29 22:08:42', '2016-02-29 22:08:42', 1, 'public', 'Pompo nelle casse', NULL),
(4, 'Evento Lontano Lonatano', 4, '2016-02-29 22:08:42', '2016-02-29 22:08:42', '2016-02-29 22:08:42', 1, 'public', 'Non so', NULL),
(5, 'Evento Vicino Vicino', 5, '2016-02-29 22:08:42', '2016-02-29 22:08:42', '2016-02-29 22:08:42', 1, 'public', 'Speriamo vada', NULL),
(6, 'Tutti al mare', 6, '2016-02-29 22:08:42', '2016-02-29 22:08:42', '2016-02-29 22:08:42', 1, 'public', 'Fa un po'' freddo', NULL);

INSERT INTO `groups` (`id`, `name`, `creationdate`, `image`, `description`) VALUES
(1, 'Ciccio', '2016-02-29 23:42:33', NULL, 'No description.');

INSERT INTO `members` (`iduser`, `idgroup`, `accepted`, `role`, `joindate`) VALUES
(1, 1, 1, 'normal', '2016-02-29 23:45:11'),
(2, 1, 1, 'normal', '2016-02-29 23:45:12'),
(3, 1, 1, 'normal', '2016-02-29 23:44:29'),
(4, 1, 1, 'normal', '2016-02-29 23:45:11'),
(5, 1, 1, 'normal', '2016-02-29 23:45:11');

INSERT INTO `partecipations` (`event_id`, `user_id`, `status`) VALUES
(1, 1, 'waiting'),
(1, 2, 'waiting'),
(1, 3, 'waiting'),
(1, 4, 'waiting'),
(1, 5, 'waiting');


/**** NO ****/
UPDATE events SET place=4 WHERE id=4;
UPDATE events SET place=5 WHERE id=5;
UPDATE events SET place=6 WHERE id=6;

UPDATE places SET name= "casa di jerry cala" WHERE id = 6;
