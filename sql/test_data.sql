INSERT INTO tournament
  (id, name, rounds, class, start_date, end_date, website, email)
VALUES
  ('london-open-2011', 'London Open Go Congress 2011', 7, 'A', '2011-12-27', '2011-12-31',
   'http://exaple.com', 'foo@example.com'),
  ('london-open-2012', 'London Open Go Congress 2012', 7, 'A', '2012-12-27', '2012-12-31',
   'http://exaple.com', 'foo@example.com');

INSERT INTO tournament_classes
  (tournament_id, class_name, until, price)
VALUES
  ('london-open-2012', 'Youth',    '2012-03-31', '0.00'),
  ('london-open-2012', 'Standard', '2012-03-31', '0.00'),
  ('london-open-2012', 'Youth',    '2012-11-30', '5.00'),
  ('london-open-2012', 'Standard', '2012-11-30', '10.00'),
  ('london-open-2012', 'Youth',    '2012-12-27', '10.00'),
  ('london-open-2012', 'Standard', '2012-12-27', '20.00');
