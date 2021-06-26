create view "ResultSummary" as
select
  a.Name,
  max(e.Time) as "_EntryTime",
  (
    select
      mn.Value
    from
      Metrics mn
    where
      mn.ParentID = a.ID
      and mn.Key like "min%"
      and e.Time = mn.Time
  ) "Min",
  (
    select
      av.Value
    from
      Metrics av
    where
      av.ParentID = a.ID
      and av.Key = "avg"
      and e.Time = av.Time
  ) "Average",
  (
    select
      sd.Value
    from
      Metrics sd
    where
      sd.ParentID = a.ID
      and sd.Key like "stDev%"
      and e.Time = sd.Time
  ) "StDev",
  (
    select
      pct.Key
    from
      Metrics pct
    where
      pct.ParentID = a.ID
      and pct.Key like "%ile"
      and e.Time = pct.Time
  ) "%ile_Key",
  (
    select
      pct.Value
    from
      Metrics pct
    where
      pct.ParentID = a.ID
      and pct.Key like "%ile"
      and e.Time = pct.Time
  ) "%ile_Value",
  (
    select
      mx.Value
    from
      Metrics mx
    where
      mx.ParentID = a.ID
      and mx.Key like "max%"
      and e.Time = mx.Time
  ) "Max",
  (
    select
      ps.Value
    from
      Metrics ps
    where
      ps.ParentID = a.ID
      and ps.Key like "_pass%"
      and e.Time = ps.Time
  ) "Pass",
  (
    select
      fl.Value
    from
      Metrics fl
    where
      fl.ParentID = a.ID
      and fl.Key like "_fail%"
      and e.Time = fl.Time
  ) "Fail",
  (
    select
      ot.Value
    from
      Metrics ot
    where
      ot.ParentID = a.ID
      and ot.Key like "_other%"
      and e.Time = ot.Time
  ) "Other"
from
  Metric a
  left join Metrics e on e.ParentID = a.ID
  and e.Key = "EntryTime"
where
  a.Type = "Summary"
group by
  a.ROWID
order by
  a.ROWID;
