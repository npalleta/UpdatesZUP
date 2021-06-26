create view "AgentList" as
select
  a.Name "AgentName",
  s.Value "AgentStatus",
  max(s.Time) as "AgentLastSeen",
  (
    select
      ra.Value
    from
      Metrics ra
    where
      ra.ParentID = a.ID
      and ra.Key = "AssignedRobots"
      and ra.Time = s.Time
  ) "AgentAssigned",
  (
    select
      r.Value
    from
      Metrics r
    where
      r.ParentID = a.ID
      and r.Key = "Robots"
      and r.Time = s.Time
  ) "AgentRobots",
  (
    select
      max(l.Value)
    from
      Metrics l
    where
      l.ParentID = a.ID
      and l.Key = "Load"
      and l.Time = s.Time
  ) "AgentLoad",
  (
    select
      max(c.Value)
    from
      Metrics c
    where
      c.ParentID = a.ID
      and c.Key = "CPU"
      and c.Time = s.Time
  ) "AgentCPU",
  (
    select
      max(m.Value)
    from
      Metrics m
    where
      m.ParentID = a.ID
      and m.Key = "MEM"
      and m.Time = s.Time
  ) "AgentMEM",
  (
    select
      max(n.Value)
    from
      Metrics n
    where
      n.ParentID = a.ID
      and n.Key = "NET"
      and n.Time = s.Time
  ) "AgentNET"
from
  Metric a
  left join Metrics s on s.ParentID = a.ID
  and s.Key = "Status"
where
  a.Type = "Agent"
group by
  s.ParentID
order by
  a.Name;
