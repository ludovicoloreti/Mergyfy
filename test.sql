/* login */
/* updatePosition */
/* getUser */
  call login('mail@mail.com', 'HASHEDPASS', 44.49000, 11.36000); -- ok
  call login('mail@mail.com', 'HASHEDPASS', 0.0000, 0.00000);
  call login('mail@mail.com', 'HASHEDPASS', null, null); -- ok

/* insertUser TODO */
  call insertUser('Ippolito', 'Nievo', '1945-10-10', 0, 'percorso/del/file', 'hash(pwd)', 'email@notduplicated.com', @last_id); -- ok
  select @last_id;
  -- control duplicate
  call insertUser('Ippolito', 'Nievo', '1945-10-10', 0, 'percorso/del/file', 'hash(pwd)', 'email@notduplicated.com', @last_id);

/* userNearEvents */
  call userNearEvents(1, 44.49, 11.36, 100); -- ok
  call userNearEvents(1, null, null, 100); -- ok

  call updatePosition(1, null, null); -- can't update with a null position
  call userNearEvents(6, null, null, 100); -- user with no position: no position no party

/* getUserEvents */
  call getUserEvents(1, 'next'); -- ok
  call getUserEvents(1, 'past'); -- ok
  call getUserEvents(1, 'all'); -- ok
  -- no related events
  call getUserEvents(6, 'all'); -- ok: no results

/* searchEvents */
call searchEvents(1, 'a'); -- ok
call searchEvents(3, 'a'); -- ok: different partecipations

/* suggestedEvents TODO*/

/* suggestedPlaces */
call suggestedPlaces(44.00, 11.00, 100); -- ok
call suggestedPlaces(44.00, 11.00, 38.2); -- ok

/* updateUser */
/* getEvents */
/* getEvent */
/* addEvent */
/* updateEvent */
/* addPlace */
/* addCategory */
/* getCategories */
/* updateCategory */
/* getUserDocs */
/* getUserDoc */
/* createDoc */
/* updateDoc */
/* getDocContent */
/* createNote */
call createNote('text', 'content', 'description', @lastid); -- ok
select @lastid;

/* createNode */
call createNode(1,1,'Bel titolo'); -- ok

/* addNoteToDoc */
call addNoteToDoc('code', 'code content', 'code desc', 1, 'addNoteToDoc'); -- ok

/* getGroupMembers */
/* getEventPartecipants */
/* createGroup */
/* updateGroup */
/* getGroupInfo */
/* getPlace */
/* addMember */
/* addPartecipant */
/* updatePartecipation */
/* addNote */ -- NO
/* getNote */ -- ??
/* updateNote */ -- ??
/* searchUser */
/* searchGroup */
/* deleteUser */
/* addGroupToEvent */
