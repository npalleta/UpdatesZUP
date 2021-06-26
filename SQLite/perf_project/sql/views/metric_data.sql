create view "MetricData" as
select
  m.Name "PrimaryMetric",
  m.Type "MetricType",
  ms.Time "MetricTime",
  ms.Key "SecondaryMetric",
  ms.Value "MetricValue"
from
  Metric as m
  join Metrics ms on m.ID = ms.ParentID;
