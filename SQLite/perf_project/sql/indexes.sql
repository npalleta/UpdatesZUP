create INDEX "idx_metric_name" on "Metric" ("Name" asc);

create INDEX "idx_metric_name_type" on "Metric" ("Name" asc, "Type" asc);

create INDEX "idx_metric_type" on "Metric" ("Type" asc);

create INDEX "idx_metrics_parentid_key" on "Metrics" ("ParentID" asc, "Key" asc);

create INDEX "idx_metrics_parentid_time_key" on "Metrics" ("ParentID" asc, "Time" asc, "Key" asc);
