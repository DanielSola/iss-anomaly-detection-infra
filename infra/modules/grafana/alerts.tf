resource "grafana_contact_point" "email_alerts" {
  provider = grafana.grafana_provider
  name     = "anomaly-alerts"

  email {
    addresses = ["daniel.sola.fraire@gmail.com"]
  }
  depends_on = [null_resource.check_grafana]

}

resource "grafana_notification_policy" "default" {
  contact_point = grafana_contact_point.email_alerts.name
  provider      = grafana.grafana_provider

  group_by = []

  depends_on = [null_resource.check_grafana]
}

resource "grafana_folder" "AnomalyDetector" {
  provider   = grafana.grafana_provider
  title      = "Anomaly Detector"
  depends_on = [null_resource.check_grafana]
}

resource "grafana_rule_group" "rule_group_4efc786e49e5de4f" {
  name             = "Anomaly"
  folder_uid       = grafana_folder.AnomalyDetector.uid
  interval_seconds = 60
  depends_on       = [null_resource.check_grafana, grafana_folder.AnomalyDetector]
  provider         = grafana.grafana_provider

  rule {
    name      = "AnomalyRule"
    condition = "last_out_of_bounds"

    data {
      ref_id = "lower_limit"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "eej9qve99wbnkd"
      model          = "{\"dimensions\":{},\"expression\":\"fields @timestamp\\n| filter log_type = 'telemetry_data'\\n| stats avg(lower_anomaly_score_deviation_limit) as lower_anomaly_score_deviation_limit_avg by bin(15s)\",\"id\":\"\",\"intervalMs\":1000,\"label\":\"\",\"logGroups\":[{\"accountId\":\"${var.aws_account_id}\",\"arn\":\"arn:aws:logs:eu-west-1:${var.aws_account_id}:log-group:/aws/lambda/iss-telemetry-analyzer-lambda:*\",\"name\":\"/aws/lambda/iss-telemetry-analyzer-lambda\"}],\"matchExact\":true,\"maxDataPoints\":43200,\"metricEditorMode\":0,\"metricName\":\"\",\"metricQueryType\":0,\"namespace\":\"\",\"period\":\"\",\"queryLanguage\":\"CWLI\",\"queryMode\":\"Logs\",\"refId\":\"lower_limit\",\"region\":\"default\",\"sqlExpression\":\"\",\"statistic\":\"Average\",\"statsGroups\":[\"bin(15s)\"]}"
    }
    data {
      ref_id = "upper_limit"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "eej9qve99wbnkd"
      model          = "{\"datasource\":{\"type\":\"cloudwatch\",\"uid\":\"eej9qve99wbnkd\"},\"dimensions\":{},\"expression\":\"fields @timestamp\\n| filter log_type = 'telemetry_data'\\n| stats avg(upper_anomaly_score_deviation_limit) as upper_anomaly_score_deviation_limit_avg by bin(15s)\",\"id\":\"\",\"intervalMs\":1000,\"label\":\"\",\"logGroups\":[{\"accountId\":\"${var.aws_account_id}\",\"arn\":\"arn:aws:logs:eu-west-1:${var.aws_account_id}:log-group:/aws/lambda/iss-telemetry-analyzer-lambda:*\",\"name\":\"/aws/lambda/iss-telemetry-analyzer-lambda\"}],\"matchExact\":true,\"maxDataPoints\":43200,\"metricEditorMode\":0,\"metricName\":\"\",\"metricQueryType\":0,\"namespace\":\"\",\"period\":\"\",\"queryLanguage\":\"CWLI\",\"queryMode\":\"Logs\",\"refId\":\"upper_limit\",\"region\":\"default\",\"sqlExpression\":\"\",\"statistic\":\"Average\",\"statsGroups\":[\"bin(15s)\"]}"
    }
    data {
      ref_id = "anomaly_score"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "eej9qve99wbnkd"
      model          = "{\"datasource\":{\"type\":\"cloudwatch\",\"uid\":\"eej9qve99wbnkd\"},\"dimensions\":{},\"expression\":\"fields @timestamp\\n| filter log_type = 'telemetry_data'\\n| stats avg(anomaly_score) as anomaly_score_avg by bin(15s)\",\"id\":\"\",\"intervalMs\":1000,\"label\":\"\",\"logGroups\":[{\"accountId\":\"${var.aws_account_id}\",\"arn\":\"arn:aws:logs:eu-west-1:${var.aws_account_id}:log-group:/aws/lambda/iss-telemetry-analyzer-lambda:*\",\"name\":\"/aws/lambda/iss-telemetry-analyzer-lambda\"}],\"matchExact\":true,\"maxDataPoints\":43200,\"metricEditorMode\":0,\"metricName\":\"\",\"metricQueryType\":0,\"namespace\":\"\",\"period\":\"\",\"queryLanguage\":\"CWLI\",\"queryMode\":\"Logs\",\"refId\":\"anomaly_score\",\"region\":\"default\",\"sqlExpression\":\"\",\"statistic\":\"Average\",\"statsGroups\":[\"bin(15s)\"]}"
    }
    data {
      ref_id = "above_upper_limit"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0,0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[]},\"reducer\":{\"params\":[],\"type\":\"avg\"},\"type\":\"query\"}],\"datasource\":{\"name\":\"Expression\",\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"$${anomaly_score} - $${upper_limit}\",\"hide\":false,\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"above_upper_limit\",\"type\":\"math\"}"
    }
    data {
      ref_id = "below_lower_limit"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0,0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[]},\"reducer\":{\"params\":[],\"type\":\"avg\"},\"type\":\"query\"}],\"datasource\":{\"name\":\"Expression\",\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"$${lower_limit} - $${anomaly_score}\",\"hide\":false,\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"below_lower_limit\",\"type\":\"math\"}"
    }
    data {
      ref_id = "is_above"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0,0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[]},\"reducer\":{\"params\":[],\"type\":\"avg\"},\"type\":\"query\"}],\"datasource\":{\"name\":\"Expression\",\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"above_upper_limit\",\"hide\":false,\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"is_above\",\"type\":\"threshold\"}"
    }
    data {
      ref_id = "is_below"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0,0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[]},\"reducer\":{\"params\":[],\"type\":\"avg\"},\"type\":\"query\"}],\"datasource\":{\"name\":\"Expression\",\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"below_lower_limit\",\"hide\":false,\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"is_below\",\"type\":\"threshold\"}"
    }
    data {
      ref_id = "out_of_bounds"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0,0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[]},\"reducer\":{\"params\":[],\"type\":\"avg\"},\"type\":\"query\"}],\"datasource\":{\"name\":\"Expression\",\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"$${is_above} + $${is_below}\",\"hide\":false,\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"out_of_bounds\",\"type\":\"math\"}"
    }
    data {
      ref_id = "last_out_of_bounds"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0,0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[]},\"reducer\":{\"params\":[],\"type\":\"avg\"},\"type\":\"query\"}],\"datasource\":{\"name\":\"Expression\",\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"out_of_bounds\",\"hide\":false,\"intervalMs\":1000,\"maxDataPoints\":43200,\"reducer\":\"last\",\"refId\":\"last_out_of_bounds\",\"type\":\"reduce\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "Triggers when the system anomaly score is out of acceptable bounds, indicating anomalies in the ISS Loop A cooling system"
      summary     = "🚨 Anomaly Detected – Loop A Cooling System\n\nSystem: ISS Loop A Cooling\n\nCondition: Anomaly Score out of bounds\n\nDuration: > 1 minute outside safe thresholds"
    }
    is_paused = false

    notification_settings {
      contact_point = "anomaly-alerts"
      group_by      = null
      mute_timings  = null
    }
  }
}
