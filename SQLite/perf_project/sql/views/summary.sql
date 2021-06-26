create view "Summary" AS
select
  r.result_name,
  min(rp.elapsed_time) "min",
  avg(rp.elapsed_time) "avg",
  max(rp.elapsed_time) "max",
  count(rp.result) as _pass,
  (
    select
      count(rf.result)
    from
      Results as rf
    where
      r.rowid == rf.rowid
      and rf.result == "FAIL"
  ) _fail,
  (
    select
      count(ro.result)
    from
      Results as ro
    where
      r.rowid == ro.rowid
      and ro.result <> "PASS"
      and ro.result <> "FAIL"
  ) _other
from
  Results as r
  left join Results as rp on r.rowid == rp.rowid
  and rp.result == "PASS"
group by
  r.result_name
order by
  r.sequence;
