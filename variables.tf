variable "newrelic_account_id" {
  description = "This is your New Relic account id, and it is needed to only allow your account to assume the role needed for account linking. This is a required variable if the value of `link_aws_account_enabled` is set to `true`."
  type        = string
  default     = ""
}

variable "newrelic_license_key" {
  description = "This is your New Relic ingest license key, and it is needed for Kinesis Firehose to successfully send metrics to your New Relic account."
  type        = string
}

variable "newrelic_role_name" {
  description = "Specifies the name of the IAM role for integrating New Relic with an AWS account."
  type        = string
  default     = "NewRelicInfrastructure-Integrations"
}

variable "newrelic_collector_endpoint" {
  description = "This is the New Relic collector endpoint. The URL changes based on your account region (US/EU), and can be found on https://docs.newrelic.com/docs/infrastructure/amazon-integrations/aws-integrations-list/aws-metric-stream/#manual-setup."
  type        = string
  default     = "https://aws-api.newrelic.com/cloudwatch-metrics/v1"
}

variable "link_aws_account_metric_streams_enabled" {
  description = "Specifies whether to enable or disable the link(Metric Streams) between the New Relic account and the AWS account. When integrating with multiple AWS regions, please enable the link(Metric Streams) in only one region. Enabling it in multiple regions will cause errors."
  type        = bool
  default     = true
}

variable "link_aws_account_metric_streams_name" {
  description = "Specifies the name for the link(Metric Streams) between the NewRelic account and the AWS account. The name must be unique within the NewRelic account. If not specified, the default is `{AWS_ACCOUNT_ID}_MetricStreams`."
  type        = string
  default     = null
}

variable "link_aws_account_api_polling_enabled" {
  description = "Specifies whether to enable or disable the link(API Polling) between the New Relic account and the AWS account. When integrating with multiple AWS regions, please enable the link(API Polling) in only one region. Enabling it in multiple regions will cause errors."
  type        = bool
  default     = false
}

variable "link_aws_account_api_polling_name" {
  description = "Specifies the name for the link(API Polling) between the NewRelic account and the AWS account. The name must be unique within the NewRelic account. If not specified, the default is `{AWS_ACCOUNT_ID}_APIPolling`."
  type        = string
  default     = null
}

variable "link_aws_account_api_polling_aws_integrations" {
  description = "Specifies the parameters for AWS services to be integrated via API polling. This is required when `link_aws_account_api_polling_enabled` is set to `true`. In this case, you must set `enabled` to true for at least one of the services. If `enabled` is set to false for all services, or if the value of this input is not set, apply operation will fail. For a list of supported services and parameters for each service beyond `enabled`, refer to the details at https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/cloud_aws_integrations#integration-blocks."
  type = object({
    billing = optional(object({
      enabled = optional(bool, false)
    }), {})
    cloudtrail = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    health = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
    }), {})
    trusted_advisor = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
    }), {})
    vpc = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      fetch_nat_gateway        = optional(bool, null)
      fetch_vpn                = optional(bool, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    x_ray = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    s3 = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      fetch_extended_inventory = optional(bool, null)
      fetch_tags               = optional(bool, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    doc_db = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
    }), {})
    sqs = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      fetch_extended_inventory = optional(bool, null)
      fetch_tags               = optional(bool, null)
      queue_prefixes           = optional(list(string), null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    ebs = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      fetch_extended_inventory = optional(bool, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    alb = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      fetch_extended_inventory = optional(bool, null)
      fetch_tags               = optional(bool, null)
      load_balancer_prefixes   = optional(list(string), null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    elasticache = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      fetch_tags               = optional(bool, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    api_gateway = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      stage_prefixes           = optional(list(string), null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    auto_scaling = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_app_sync = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_athena = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_cognito = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_connect = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_direct_connect = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_fsx = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_glue = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_kinesis_analytics = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_media_convert = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_media_package_vod = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_mq = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_msk = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_neptune = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_qldb = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_route53resolver = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_states = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_transit_gateway = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_waf = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    aws_wafv2 = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    cloudfront = optional(object({
      enabled                  = optional(bool, false)
      fetch_lambdas_at_edge    = optional(bool, null)
      fetch_tags               = optional(bool, null)
      metrics_polling_interval = optional(number, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    dynamodb = optional(object({
      enabled                  = optional(bool, false)
      aws_regions              = optional(list(string), null)
      fetch_extended_inventory = optional(bool, null)
      fetch_tags               = optional(bool, null)
      metrics_polling_interval = optional(number, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    ec2 = optional(object({
      enabled                  = optional(bool, false)
      aws_regions              = optional(list(string), null)
      duplicate_ec2_tags       = optional(bool, null)
      fetch_ip_addresses       = optional(bool, null)
      metrics_polling_interval = optional(number, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    ecs = optional(object({
      enabled                  = optional(bool, false)
      aws_regions              = optional(list(string), null)
      fetch_tags               = optional(bool, null)
      metrics_polling_interval = optional(number, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    efs = optional(object({
      enabled                  = optional(bool, false)
      aws_regions              = optional(list(string), null)
      fetch_tags               = optional(bool, null)
      metrics_polling_interval = optional(number, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    elasticbeanstalk = optional(object({
      enabled                  = optional(bool, false)
      aws_regions              = optional(list(string), null)
      fetch_extended_inventory = optional(bool, null)
      fetch_tags               = optional(bool, null)
      metrics_polling_interval = optional(number, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    elasticsearch = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      fetch_nodes              = optional(bool, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    elb = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      fetch_extended_inventory = optional(bool, null)
      fetch_tags               = optional(bool, null)
    }), {})
    emr = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      fetch_tags               = optional(bool, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    iam = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    iot = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    kinesis = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      fetch_shards             = optional(bool, null)
      fetch_tags               = optional(bool, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    kinesis_firehose = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    lambda = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      fetch_tags               = optional(bool, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    rds = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      fetch_tags               = optional(bool, null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    redshift = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      tag_key                  = optional(string, null)
      tag_value                = optional(string, null)
    }), {})
    route53 = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      fetch_extended_inventory = optional(bool, null)
    }), {})
    ses = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
    }), {})
    sns = optional(object({
      enabled                  = optional(bool, false)
      metrics_polling_interval = optional(number, null)
      aws_regions              = optional(list(string), null)
      fetch_extended_inventory = optional(bool, null)
    }), {})
  })
  default = {
    billing               = {}
    cloudtrail            = {}
    health                = {}
    trusted_advisor       = {}
    vpc                   = {}
    x_ray                 = {}
    s3                    = {}
    doc_db                = {}
    sqs                   = {}
    ebs                   = {}
    alb                   = {}
    elasticache           = {}
    api_gateway           = {}
    auto_scaling          = {}
    aws_app_sync          = {}
    aws_athena            = {}
    aws_cognito           = {}
    aws_connect           = {}
    aws_direct_connect    = {}
    aws_fsx               = {}
    aws_glue              = {}
    aws_kinesis_analytics = {}
    aws_media_convert     = {}
    aws_media_package_vod = {}
    aws_mq                = {}
    aws_msk               = {}
    aws_neptune           = {}
    aws_qldb              = {}
    aws_route53resolver   = {}
    aws_states            = {}
    aws_transit_gateway   = {}
    aws_waf               = {}
    aws_wafv2             = {}
    cloudfront            = {}
    dynamodb              = {}
    ec2                   = {}
    ecs                   = {}
    efs                   = {}
    elasticbeanstalk      = {}
    elasticsearch         = {}
    elb                   = {}
    emr                   = {}
    iam                   = {}
    iot                   = {}
    kinesis               = {}
    kinesis_firehose      = {}
    lambda                = {}
    rds                   = {}
    redshift              = {}
    route53               = {}
    ses                   = {}
    sns                   = {}
  }
}

variable "create_metric_streams_aws_resources" {
  description = "Specifies whether to enable or disable the creation of AWS resources necessary for integration using Metrics Streams. Set the value to `false` if you do not integrate using Metrics Streams."
  type        = bool
  default     = true
}

variable "cloudwatch_metric_stream_include_filters" {
  description = "List of filters specifying which metrics to include in the CloudWatch Metric Stream. Each filter must specify a 'namespace' and a list of 'metric_names'. Providing an empty list for 'metric_names' includes all metrics from the specified namespace. Mutually exclusive with cloudwatch_metric_stream_exclude_filters. Optional."
  type = list(object({
    namespace    = string
    metric_names = list(string)
  }))
  default = []
}

variable "cloudwatch_metric_stream_exclude_filters" {
  description = "List of filters specifying which metrics to exclude from the CloudWatch Metric Stream. Each filter must specify a 'namespace' and a list of 'metric_names'. Providing an empty list for 'metric_names' all metrics in the namespace are excluded. Mutually exclusive with cloudwatch_metric_stream_include_filters. Optional."
  type = list(object({
    namespace    = string
    metric_names = list(string)
  }))
  default = []
}

variable "firehose_bucket_expiration_days" {
  description = "Specifies the retention period for error records of Firehose. The value must be `0` or greater. If this parameter is not specified, the retention period will be indefinite."
  type        = number
  default     = null
}

variable "aws_config_enabled" {
  description = "Specifies whether to enable or disable AWS Config. New Relic utilizes AWS Config to collect metadata. If you want to collect metadata from AWS Config to enhance the attributes of your metrics, please enable AWS Config. If you integrate with an AWS account where AWS Config is already enabled, set the value to `false`. If the purpose of enabling AWS Config is to enhance security, it is advisable to enable AWS Config through other means."
  type        = bool
  default     = false
}

variable "aws_config_configuration_recorder_resource_types" {
  description = "A list that specifies the types of AWS resources for which AWS Config records configuration changes (for example, AWS::EC2::Instance or AWS::CloudTrail::Trail). See https://docs.aws.amazon.com/config/latest/APIReference/API_ResourceIdentifier.html#config-Type-ResourceIdentifier-resourceType for available types. This is a required variable if the value of `aws_config_enabled` is set to `true`."
  type        = list(string)
  default     = []
}

variable "aws_config_configuration_recording_frequency" {
  description = "AWS Config recording frequency. `CONTINUOUS` or `DAILY`."
  type        = string
  default     = "CONTINUOUS"
}

variable "config_bucket_expiration_days" {
  description = "Specifies the retention period for snapshots of AWS Config. The value must be `0` or greater. If this parameter is not specified, the retention period will be indefinite."
  type        = number
  default     = null
}

variable "cloudwatch_metric_stream_output_format" {
  description = "The output format for the CloudWatch Metric Stream. Valid values are 'json', 'opentelemetry0.7', and 'opentelemetry1.0'."
  type        = string
  default     = "opentelemetry0.7"
}
