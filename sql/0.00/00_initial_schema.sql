CREATE TABLE tournament (
  id         char(64)  NOT NULL,
  name       char(128) NOT NULL,
  rounds     int(11)   NOT NULL DEFAULT '3',
  class      char(1)   NOT NULL DEFAULT 'B',
  start_date date      NOT NULL,
  end_date   date      NOT NULL,
  website    char(128) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE registration (
  tournament_id CHAR(64) NOT NULL,
  email         CHAR(255) NOT NULL,
  given_name    CHAR(32) NOT NULL,
  family_name   CHAR(64) NOT NULL,
  grade         CHAR(3) NOT NULL,
  club          CHAR(64), -- can be NULL
  country       CHAR(2) NOT NULL,
  show_on_site  INT,
  editkey       CHAR(32), -- Digest::MD5::md5_hex
  PRIMARY KEY (tournament_id, email, given_name, family_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
