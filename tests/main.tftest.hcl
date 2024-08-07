variables {
  newrelic_role_name                      = "NewRelicInfrastructure-Integrations-TEST"
  link_aws_account_metric_streams_enabled = true
  link_aws_account_metric_streams_name    = "TEST_MetricStreams"
  link_aws_account_api_polling_enabled    = false
  link_aws_account_api_polling_name       = "TEST_APIPolling"
  link_aws_account_api_polling_aws_integrations = {
    cloudfront = {
      enabled = true
    }
  }
  create_metric_streams_aws_resources = true
  cloudwatch_metric_stream_include_filters = [
    {
      namespace    = "AWS/ECS",
      metric_names = ["CPUUtilization", "MemoryReservation"]
    },
    {
      namespace    = "AWS/RDS",
      metric_names = []
    }
  ]
  firehose_bucket_expiration_days = 7
  aws_config_enabled              = true
  aws_config_configuration_recorder_resource_types = [
    "AWS::ECS::Cluster",
    "AWS::ECS::Service",
    "AWS::RDS::DBInstance",
    "AWS::RDS::DBCluster"
  ]
  aws_config_configuration_recording_frequency = "DAILY"
  config_bucket_expiration_days                = 7
}

provider "newrelic" {
  account_id = var.newrelic_account_id
  api_key    = var.api_key
}

run "main" {
  command = plan
}