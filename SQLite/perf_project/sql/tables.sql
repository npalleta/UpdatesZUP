create table ReferenceDate(
  id_ref_date integer primary key autoincrement,
  ref_date text
);

create table Results(
  id integer primary key autoincrement,
  script_index int,
  robot int,
  iteration int,
  agent text,
  sequence int,
  result_name text,
  result text,
  elapsed_time num,
  start_time num,
  end_time num,
  id_ref_date integer not null,
  foreign key (id_ref_date) references ReferenceDate (id_ref_date)
);

create table Metric (
  id_metric integer primary key autoincrement,
  ID integer,
  Name text not null,
  Type text not null,
  unique (id_metric, ID)
);

create table Metrics (
  id_metrics integer primary key autoincrement,
  ParentID integer not null,
  Time integer not null,
  Key text not null,
  Value text
);
