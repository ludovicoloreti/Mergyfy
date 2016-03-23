/* updateDocVisibility()
  Update doc visibility.
*/
DELIMITER |
CREATE PROCEDURE getEventNodes(IN doc_id INT)
BEGIN
  DECLARE event_id INT DEFAULT 0;
  DECLARE creator_id INT DEFAULT 0;
  -- select
  SELECT doc.event_id, doc.creator_id INTO event_id, creator_id FROM documents AS doc WHERE (doc.id = doc_id);
  IF (event_id <> 0 AND creator_id <> 0) THEN

    SELECT * FROM nodes AS nd, notes AS nt, document AS doc WHERE ( (nd.note_id = nt.id) AND (nd.document_id = ANY (SELECT id FROM documents AS dcmt WHERE ( (dcmt.event_id = event_id) AND (dcmt.creator_id <> creator_id) ))));
  ELSE
    SIGNAL sqlstate '45000' set message_text = "Event does not exists";
  END IF;
END |
DELIMITER ;
