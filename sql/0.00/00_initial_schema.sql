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
