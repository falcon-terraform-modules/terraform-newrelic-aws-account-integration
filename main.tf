locals {
  region_short_name = {
    us-east-1      = "use1"
    us-east-2      = "use2"
    us-west-1      = "usw1"
    us-west-2      = "usw2"
    ap-south-1     = "aps1"
    ap-northeast-1 = "apne1"
    ap-northeast-2 = "apne2"
    ap-northeast-3 = "apne3"
    ap-southeast-1 = "apse1"
    ap-southeast-2 = "apse2"
    ca-central-1   = "cac1"
    eu-central-1   = "euc1"
    eu-west-1      = "euw1"
    eu-west-2      = "euw2"
    eu-west-3      = "euw3"
    eu-north-1     = "eun1"
    sa-east-1      = "sae1"
  }
}

locals {
  cwstream_role_name   = "MetricStreamRole-FirehosePutRecords-NewRelic"
  cwstream_policy_name = "MetricStreamPolicy-FirehosePutRecords-NewRelic"
  cwstream_name        = "NewRelic-MetricStreams"
  firehose_role_name   = "KinesisFirehoseServiceRole-PUT-MetricStreams-NewRelic"
  firehose_policy_name = "KinesisFirehoseServicePolicy-PUT-MetricStreams-NewRelic"
  firehose_stream_name = "NewRelic-MetricStreams"
  firehose_bucket_name = "firehose-backup-newrelic-metricstreams"
  config_bucket_name   = "aws-config"
  config_role_name     = "AWSConfigServiceRole"
  config_policy_name   = "AWSConfigServicePolicy"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "assume_role" {
  for_each = toset([
    "firehose",
    "streams.metrics.cloudwatch",
    "config"
  ])
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "${each.value}.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "newrelic" {
  count = var.link_aws_account_metric_streams_enabled || var.link_aws_account_api_polling_enabled ? 1 : 0
  name  = var.newrelic_role_name
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::754728514883:root"
          }
          Action = "sts:AssumeRole"
          Condition = {
            StringEquals = {
              "sts:ExternalId" = var.newrelic_account_id
            }
          }
        }
      ]
    }
  )
  tags = {
    Name = var.newrelic_role_name
  }
}

resource "aws_iam_role_policy_attachment" "newrelic" {
  count      = var.link_aws_account_metric_streams_enabled || var.link_aws_account_api_polling_enabled ? 1 : 0
  role       = var.link_aws_account_metric_streams_enabled || var.link_aws_account_api_polling_enabled ? aws_iam_role.newrelic[0].name : ""
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "newrelic_cloud_aws_link_account" "metric_streams" {
  count                  = var.link_aws_account_metric_streams_enabled ? 1 : 0
  name                   = var.link_aws_account_metric_streams_name != null ? var.link_aws_account_metric_streams_name : "${data.aws_caller_identity.current.account_id}_MetricStreams"
  account_id             = var.newrelic_account_id
  arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.newrelic_role_name}"
  metric_collection_mode = "PUSH"
}

resource "newrelic_cloud_aws_link_account" "api_polling" {
  count                  = var.link_aws_account_api_polling_enabled ? 1 : 0
  name                   = var.link_aws_account_api_polling_name != null ? var.link_aws_account_api_polling_name : "${data.aws_caller_identity.current.account_id}_APIPolling"
  account_id             = var.newrelic_account_id
  arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.newrelic_role_name}"
  metric_collection_mode = "PULL"
}

resource "newrelic_cloud_aws_integrations" "api_polling" {
  count             = var.link_aws_account_api_polling_enabled ? 1 : 0
  linked_account_id = var.link_aws_account_api_polling_enabled ? newrelic_cloud_aws_link_account.api_polling[0].id : ""
  dynamic "billing" {
    for_each = var.link_aws_account_api_polling_aws_integrations.billing.enabled ? [1] : []
    content {}
  }
  dynamic "cloudtrail" {
    for_each = var.link_aws_account_api_polling_aws_integrations.cloudtrail.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.cloudtrail.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.cloudtrail.aws_regions
    }
  }
  dynamic "health" {
    for_each = var.link_aws_account_api_polling_aws_integrations.health.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.health.metrics_polling_interval
    }
  }
  dynamic "trusted_advisor" {
    for_each = var.link_aws_account_api_polling_aws_integrations.trusted_advisor.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.trusted_advisor.metrics_polling_interval
    }
  }
  dynamic "vpc" {
    for_each = var.link_aws_account_api_polling_aws_integrations.vpc.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.vpc.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.vpc.aws_regions
      fetch_nat_gateway        = var.link_aws_account_api_polling_aws_integrations.vpc.fetch_nat_gateway
      fetch_vpn                = var.link_aws_account_api_polling_aws_integrations.vpc.fetch_vpn
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.vpc.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.vpc.tag_value
    }
  }
  dynamic "x_ray" {
    for_each = var.link_aws_account_api_polling_aws_integrations.x_ray.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.x_ray.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.x_ray.aws_regions
    }
  }
  dynamic "s3" {
    for_each = var.link_aws_account_api_polling_aws_integrations.s3.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.s3.metrics_polling_interval
      fetch_extended_inventory = var.link_aws_account_api_polling_aws_integrations.s3.fetch_extended_inventory
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.s3.fetch_tags
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.s3.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.s3.tag_value
    }
  }
  dynamic "doc_db" {
    for_each = var.link_aws_account_api_polling_aws_integrations.doc_db.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.doc_db.metrics_polling_interval
    }
  }
  dynamic "sqs" {
    for_each = var.link_aws_account_api_polling_aws_integrations.sqs.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.sqs.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.sqs.aws_regions
      fetch_extended_inventory = var.link_aws_account_api_polling_aws_integrations.sqs.fetch_extended_inventory
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.sqs.fetch_tags
      queue_prefixes           = var.link_aws_account_api_polling_aws_integrations.sqs.queue_prefixes
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.sqs.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.sqs.tag_value
    }
  }
  dynamic "ebs" {
    for_each = var.link_aws_account_api_polling_aws_integrations.ebs.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.ebs.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.ebs.aws_regions
      fetch_extended_inventory = var.link_aws_account_api_polling_aws_integrations.ebs.fetch_extended_inventory
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.ebs.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.ebs.tag_value
    }
  }
  dynamic "alb" {
    for_each = var.link_aws_account_api_polling_aws_integrations.alb.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.alb.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.alb.aws_regions
      fetch_extended_inventory = var.link_aws_account_api_polling_aws_integrations.alb.fetch_extended_inventory
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.alb.fetch_tags
      load_balancer_prefixes   = var.link_aws_account_api_polling_aws_integrations.alb.load_balancer_prefixes
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.alb.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.alb.tag_value
    }
  }
  dynamic "elasticache" {
    for_each = var.link_aws_account_api_polling_aws_integrations.elasticache.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.elasticache.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.elasticache.aws_regions
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.elasticache.fetch_tags
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.elasticache.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.elasticache.tag_value
    }
  }
  dynamic "api_gateway" {
    for_each = var.link_aws_account_api_polling_aws_integrations.api_gateway.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.api_gateway.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.api_gateway.aws_regions
      stage_prefixes           = var.link_aws_account_api_polling_aws_integrations.api_gateway.stage_prefixes
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.api_gateway.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.api_gateway.tag_value
    }
  }
  dynamic "auto_scaling" {
    for_each = var.link_aws_account_api_polling_aws_integrations.auto_scaling.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.auto_scaling.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.auto_scaling.aws_regions
    }
  }
  dynamic "aws_app_sync" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_app_sync.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_app_sync.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_app_sync.aws_regions
    }
  }
  dynamic "aws_athena" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_athena.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_athena.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_athena.aws_regions
    }
  }
  dynamic "aws_cognito" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_cognito.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_cognito.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_cognito.aws_regions
    }
  }
  dynamic "aws_connect" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_connect.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_connect.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_connect.aws_regions
    }
  }
  dynamic "aws_direct_connect" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_direct_connect.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_direct_connect.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_direct_connect.aws_regions
    }
  }
  dynamic "aws_fsx" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_fsx.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_fsx.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_fsx.aws_regions
    }
  }
  dynamic "aws_glue" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_glue.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_glue.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_glue.aws_regions
    }
  }
  dynamic "aws_kinesis_analytics" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_kinesis_analytics.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_kinesis_analytics.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_kinesis_analytics.aws_regions
    }
  }
  dynamic "aws_media_convert" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_media_convert.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_media_convert.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_media_convert.aws_regions
    }
  }
  dynamic "aws_media_package_vod" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_media_package_vod.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_media_package_vod.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_media_package_vod.aws_regions
    }
  }
  dynamic "aws_mq" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_mq.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_mq.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_mq.aws_regions
    }
  }
  dynamic "aws_msk" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_msk.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_msk.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_msk.aws_regions
    }
  }
  dynamic "aws_neptune" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_neptune.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_neptune.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_neptune.aws_regions
    }
  }
  dynamic "aws_qldb" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_qldb.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_qldb.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_qldb.aws_regions
    }
  }
  dynamic "aws_route53resolver" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_route53resolver.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_route53resolver.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_route53resolver.aws_regions
    }
  }
  dynamic "aws_states" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_states.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_states.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_states.aws_regions
    }
  }
  dynamic "aws_transit_gateway" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_transit_gateway.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_transit_gateway.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_transit_gateway.aws_regions
    }
  }
  dynamic "aws_waf" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_waf.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_waf.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_waf.aws_regions
    }
  }
  dynamic "aws_wafv2" {
    for_each = var.link_aws_account_api_polling_aws_integrations.aws_wafv2.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.aws_wafv2.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.aws_wafv2.aws_regions
    }
  }
  dynamic "cloudfront" {
    for_each = var.link_aws_account_api_polling_aws_integrations.cloudfront.enabled ? [1] : []
    content {
      fetch_lambdas_at_edge    = var.link_aws_account_api_polling_aws_integrations.cloudfront.fetch_lambdas_at_edge
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.cloudfront.fetch_tags
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.cloudfront.metrics_polling_interval
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.cloudfront.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.cloudfront.tag_value
    }
  }
  dynamic "dynamodb" {
    for_each = var.link_aws_account_api_polling_aws_integrations.dynamodb.enabled ? [1] : []
    content {
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.dynamodb.aws_regions
      fetch_extended_inventory = var.link_aws_account_api_polling_aws_integrations.dynamodb.fetch_extended_inventory
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.dynamodb.fetch_tags
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.dynamodb.metrics_polling_interval
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.dynamodb.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.dynamodb.tag_value
    }
  }
  dynamic "ec2" {
    for_each = var.link_aws_account_api_polling_aws_integrations.ec2.enabled ? [1] : []
    content {
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.ec2.aws_regions
      duplicate_ec2_tags       = var.link_aws_account_api_polling_aws_integrations.ec2.duplicate_ec2_tags
      fetch_ip_addresses       = var.link_aws_account_api_polling_aws_integrations.ec2.fetch_ip_addresses
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.ec2.metrics_polling_interval
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.ec2.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.ec2.tag_value
    }
  }
  dynamic "ecs" {
    for_each = var.link_aws_account_api_polling_aws_integrations.ecs.enabled ? [1] : []
    content {
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.ecs.aws_regions
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.ecs.fetch_tags
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.ecs.metrics_polling_interval
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.ecs.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.ecs.tag_value
    }
  }
  dynamic "efs" {
    for_each = var.link_aws_account_api_polling_aws_integrations.efs.enabled ? [1] : []
    content {
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.efs.aws_regions
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.efs.fetch_tags
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.efs.metrics_polling_interval
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.efs.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.efs.tag_value
    }
  }
  dynamic "elasticbeanstalk" {
    for_each = var.link_aws_account_api_polling_aws_integrations.elasticbeanstalk.enabled ? [1] : []
    content {
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.elasticbeanstalk.aws_regions
      fetch_extended_inventory = var.link_aws_account_api_polling_aws_integrations.elasticbeanstalk.fetch_extended_inventory
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.elasticbeanstalk.fetch_tags
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.elasticbeanstalk.metrics_polling_interval
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.elasticbeanstalk.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.elasticbeanstalk.tag_value
    }
  }
  dynamic "elasticsearch" {
    for_each = var.link_aws_account_api_polling_aws_integrations.elasticsearch.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.elasticsearch.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.elasticsearch.aws_regions
      fetch_nodes              = var.link_aws_account_api_polling_aws_integrations.elasticsearch.fetch_nodes
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.elasticsearch.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.elasticsearch.tag_value
    }
  }
  dynamic "elb" {
    for_each = var.link_aws_account_api_polling_aws_integrations.elb.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.elb.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.elb.aws_regions
      fetch_extended_inventory = var.link_aws_account_api_polling_aws_integrations.elb.fetch_extended_inventory
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.elb.fetch_tags
    }
  }
  dynamic "emr" {
    for_each = var.link_aws_account_api_polling_aws_integrations.emr.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.emr.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.emr.aws_regions
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.emr.fetch_tags
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.emr.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.emr.tag_value
    }
  }
  dynamic "iam" {
    for_each = var.link_aws_account_api_polling_aws_integrations.iam.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.iam.metrics_polling_interval
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.iam.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.iam.tag_value
    }
  }
  dynamic "iot" {
    for_each = var.link_aws_account_api_polling_aws_integrations.iot.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.iot.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.iot.aws_regions
    }
  }
  dynamic "kinesis" {
    for_each = var.link_aws_account_api_polling_aws_integrations.kinesis.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.kinesis.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.kinesis.aws_regions
      fetch_shards             = var.link_aws_account_api_polling_aws_integrations.kinesis.fetch_shards
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.kinesis.fetch_tags
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.kinesis.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.kinesis.tag_value
    }
  }
  dynamic "kinesis_firehose" {
    for_each = var.link_aws_account_api_polling_aws_integrations.kinesis_firehose.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.kinesis_firehose.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.kinesis_firehose.aws_regions
    }
  }
  dynamic "lambda" {
    for_each = var.link_aws_account_api_polling_aws_integrations.lambda.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.lambda.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.lambda.aws_regions
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.lambda.fetch_tags
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.lambda.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.lambda.tag_value
    }
  }
  dynamic "rds" {
    for_each = var.link_aws_account_api_polling_aws_integrations.rds.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.rds.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.rds.aws_regions
      fetch_tags               = var.link_aws_account_api_polling_aws_integrations.rds.fetch_tags
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.rds.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.rds.tag_value
    }
  }
  dynamic "redshift" {
    for_each = var.link_aws_account_api_polling_aws_integrations.redshift.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.redshift.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.redshift.aws_regions
      tag_key                  = var.link_aws_account_api_polling_aws_integrations.redshift.tag_key
      tag_value                = var.link_aws_account_api_polling_aws_integrations.redshift.tag_value
    }
  }
  dynamic "route53" {
    for_each = var.link_aws_account_api_polling_aws_integrations.route53.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.route53.metrics_polling_interval
      fetch_extended_inventory = var.link_aws_account_api_polling_aws_integrations.route53.fetch_extended_inventory
    }
  }
  dynamic "ses" {
    for_each = var.link_aws_account_api_polling_aws_integrations.ses.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.ses.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.ses.aws_regions
    }
  }
  dynamic "sns" {
    for_each = var.link_aws_account_api_polling_aws_integrations.sns.enabled ? [1] : []
    content {
      metrics_polling_interval = var.link_aws_account_api_polling_aws_integrations.sns.metrics_polling_interval
      aws_regions              = var.link_aws_account_api_polling_aws_integrations.sns.aws_regions
      fetch_extended_inventory = var.link_aws_account_api_polling_aws_integrations.sns.fetch_extended_inventory
    }
  }
}

resource "aws_s3_bucket" "firehose" {
  count         = var.create_metric_streams_aws_resources ? 1 : 0
  bucket        = "${local.firehose_bucket_name}-${data.aws_caller_identity.current.account_id}-${local.region_short_name[data.aws_region.current.name]}"
  force_destroy = true
  tags = {
    Name = "${local.firehose_bucket_name}-${data.aws_caller_identity.current.account_id}-${local.region_short_name[data.aws_region.current.name]}"
  }
}

resource "aws_s3_bucket_versioning" "firehose" {
  count  = var.create_metric_streams_aws_resources ? 1 : 0
  bucket = var.create_metric_streams_aws_resources ? aws_s3_bucket.firehose[0].bucket : ""
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "firehose" {
  count  = var.create_metric_streams_aws_resources ? 1 : 0
  bucket = var.create_metric_streams_aws_resources ? aws_s3_bucket.firehose[0].bucket : ""
  dynamic "rule" {
    for_each = var.firehose_bucket_expiration_days != null ? [1] : []
    content {
      id     = "expiration"
      status = "Enabled"
      expiration {
        days = var.firehose_bucket_expiration_days
      }
      noncurrent_version_expiration {
        noncurrent_days = 1
      }
    }
  }
  dynamic "rule" {
    for_each = [1]
    content {
      id     = "expiration_delete_markers"
      status = "Enabled"
      expiration {
        expired_object_delete_marker = true
      }
    }
  }
  dynamic "rule" {
    for_each = [1]
    content {
      id     = "abort_incomplete_multipart"
      status = "Enabled"
      abort_incomplete_multipart_upload {
        days_after_initiation = 7
      }
    }
  }
}

resource "aws_iam_role" "firehose" {
  count              = var.create_metric_streams_aws_resources ? 1 : 0
  name               = "${local.firehose_role_name}-${local.region_short_name[data.aws_region.current.name]}"
  assume_role_policy = data.aws_iam_policy_document.assume_role["firehose"].json
  tags = {
    Name = "${local.firehose_role_name}-${local.region_short_name[data.aws_region.current.name]}"
  }
}

data "aws_iam_policy_document" "firehose" {
  count = var.create_metric_streams_aws_resources ? 1 : 0
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    effect = "Allow"
    resources = var.create_metric_streams_aws_resources ? [
      "arn:aws:s3:::${aws_s3_bucket.firehose[0].bucket}",
      "arn:aws:s3:::${aws_s3_bucket.firehose[0].bucket}/*"
    ] : []
  }
}

resource "aws_iam_policy" "firehose" {
  count  = var.create_metric_streams_aws_resources ? 1 : 0
  name   = "${local.firehose_policy_name}-${local.region_short_name[data.aws_region.current.name]}"
  policy = data.aws_iam_policy_document.firehose[0].json
  tags = {
    Name = "${local.firehose_policy_name}-${local.region_short_name[data.aws_region.current.name]}"
  }
}

resource "aws_iam_role_policy_attachment" "firehose" {
  count      = var.create_metric_streams_aws_resources ? 1 : 0
  role       = var.create_metric_streams_aws_resources ? aws_iam_role.firehose[0].name : ""
  policy_arn = var.create_metric_streams_aws_resources ? aws_iam_policy.firehose[0].arn : ""
}

resource "aws_kinesis_firehose_delivery_stream" "main" {
  count       = var.create_metric_streams_aws_resources ? 1 : 0
  name        = local.firehose_stream_name
  destination = "http_endpoint"
  http_endpoint_configuration {
    name               = "New Relic"
    url                = var.newrelic_collector_endpoint
    access_key         = var.newrelic_license_key
    retry_duration     = 60
    buffering_size     = 1
    buffering_interval = 60
    role_arn           = var.create_metric_streams_aws_resources ? aws_iam_role.firehose[0].arn : ""
    s3_backup_mode     = "FailedDataOnly"
    s3_configuration {
      role_arn           = var.create_metric_streams_aws_resources ? aws_iam_role.firehose[0].arn : ""
      bucket_arn         = var.create_metric_streams_aws_resources ? aws_s3_bucket.firehose[0].arn : ""
      buffering_size     = 5
      buffering_interval = 300
      compression_format = "GZIP"
    }
    request_configuration {
      content_encoding = "GZIP"
    }
  }
  tags = {
    Name = local.firehose_stream_name
  }
}

resource "aws_iam_role" "cwstream" {
  count              = var.create_metric_streams_aws_resources ? 1 : 0
  name               = "${local.cwstream_role_name}-${local.region_short_name[data.aws_region.current.name]}"
  assume_role_policy = data.aws_iam_policy_document.assume_role["streams.metrics.cloudwatch"].json
  tags = {
    Name = "${local.cwstream_role_name}-${local.region_short_name[data.aws_region.current.name]}"
  }
}

data "aws_iam_policy_document" "cwstream" {
  count = var.create_metric_streams_aws_resources ? 1 : 0
  statement {
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    effect    = "Allow"
    resources = var.create_metric_streams_aws_resources ? [aws_kinesis_firehose_delivery_stream.main[0].arn] : []
  }
}

resource "aws_iam_policy" "cwstream" {
  count  = var.create_metric_streams_aws_resources ? 1 : 0
  name   = "${local.cwstream_policy_name}-${local.region_short_name[data.aws_region.current.name]}"
  policy = data.aws_iam_policy_document.cwstream[0].json
  tags = {
    Name = "${local.cwstream_policy_name}-${local.region_short_name[data.aws_region.current.name]}"
  }
}

resource "aws_iam_role_policy_attachment" "cwstream" {
  count      = var.create_metric_streams_aws_resources ? 1 : 0
  role       = var.create_metric_streams_aws_resources ? aws_iam_role.cwstream[0].name : ""
  policy_arn = var.create_metric_streams_aws_resources ? aws_iam_policy.cwstream[0].arn : ""
}

resource "aws_cloudwatch_metric_stream" "main" {
  count         = var.create_metric_streams_aws_resources ? 1 : 0
  name          = local.cwstream_name
  role_arn      = var.create_metric_streams_aws_resources ? aws_iam_role.cwstream[0].arn : ""
  firehose_arn  = var.create_metric_streams_aws_resources ? aws_kinesis_firehose_delivery_stream.main[0].arn : ""
  output_format = var.cloudwatch_metric_stream_output_format
  dynamic "include_filter" {
    for_each = var.cloudwatch_metric_stream_include_filters
    content {
      namespace    = include_filter.value.namespace
      metric_names = include_filter.value.metric_names
    }
  }
  dynamic "exclude_filter" {
    for_each = var.cloudwatch_metric_stream_exclude_filters
    content {
      namespace    = exclude_filter.value.namespace
      metric_names = exclude_filter.value.metric_names
    }
  }
  tags = {
    Name = local.cwstream_name
  }
}

resource "aws_s3_bucket" "config" {
  count         = var.create_metric_streams_aws_resources && var.aws_config_enabled ? 1 : 0
  bucket        = "${local.config_bucket_name}-${data.aws_caller_identity.current.account_id}-${local.region_short_name[data.aws_region.current.name]}"
  force_destroy = true
  tags = {
    Name = "${local.config_bucket_name}-${data.aws_caller_identity.current.account_id}-${local.region_short_name[data.aws_region.current.name]}"
  }
}

resource "aws_s3_bucket_versioning" "config" {
  count  = var.create_metric_streams_aws_resources && var.aws_config_enabled ? 1 : 0
  bucket = var.create_metric_streams_aws_resources && var.aws_config_enabled ? aws_s3_bucket.config[0].bucket : ""
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "config" {
  count  = var.create_metric_streams_aws_resources && var.aws_config_enabled ? 1 : 0
  bucket = var.create_metric_streams_aws_resources && var.aws_config_enabled ? aws_s3_bucket.config[0].bucket : ""
  dynamic "rule" {
    for_each = var.config_bucket_expiration_days != null ? [1] : []
    content {
      id     = "expiration"
      status = "Enabled"
      expiration {
        days = var.config_bucket_expiration_days
      }
      noncurrent_version_expiration {
        noncurrent_days = 1
      }
    }
  }
  dynamic "rule" {
    for_each = [1]
    content {
      id     = "expiration_delete_markers"
      status = "Enabled"
      expiration {
        expired_object_delete_marker = true
      }
    }
  }
  dynamic "rule" {
    for_each = [1]
    content {
      id     = "abort_incomplete_multipart"
      status = "Enabled"
      abort_incomplete_multipart_upload {
        days_after_initiation = 7
      }
    }
  }
}

resource "aws_iam_role" "config" {
  count              = var.create_metric_streams_aws_resources && var.aws_config_enabled ? 1 : 0
  name               = "${local.config_role_name}-${local.region_short_name[data.aws_region.current.name]}"
  assume_role_policy = data.aws_iam_policy_document.assume_role["config"].json
  tags = {
    Name = "${local.config_role_name}-${local.region_short_name[data.aws_region.current.name]}"
  }
}

resource "aws_iam_role_policy" "config" {
  count = var.create_metric_streams_aws_resources && var.aws_config_enabled ? 1 : 0
  name  = "${local.config_role_name}-${local.region_short_name[data.aws_region.current.name]}_inline"
  role  = var.create_metric_streams_aws_resources && var.aws_config_enabled ? aws_iam_role.config[0].name : ""
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = var.create_metric_streams_aws_resources && var.aws_config_enabled ? "arn:aws:s3:::${aws_s3_bucket.config[0].bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*" : ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config" {
  count      = var.create_metric_streams_aws_resources && var.aws_config_enabled ? 1 : 0
  role       = var.create_metric_streams_aws_resources && var.aws_config_enabled ? aws_iam_role.config[0].name : ""
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_configuration_recorder" "main" {
  count    = var.create_metric_streams_aws_resources && var.aws_config_enabled ? 1 : 0
  role_arn = var.create_metric_streams_aws_resources && var.aws_config_enabled ? aws_iam_role.config[0].arn : ""
  recording_group {
    all_supported                 = false
    resource_types                = var.aws_config_configuration_recorder_resource_types
    include_global_resource_types = "false"
    recording_strategy {
      use_only = "INCLUSION_BY_RESOURCE_TYPES"
    }
  }
  recording_mode {
    recording_frequency = var.aws_config_configuration_recording_frequency
  }
}

resource "aws_config_delivery_channel" "main" {
  count          = var.create_metric_streams_aws_resources && var.aws_config_enabled ? 1 : 0
  s3_bucket_name = var.create_metric_streams_aws_resources && var.aws_config_enabled ? aws_s3_bucket.config[0].bucket : ""
  depends_on     = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  count      = var.create_metric_streams_aws_resources && var.aws_config_enabled ? 1 : 0
  name       = var.create_metric_streams_aws_resources && var.aws_config_enabled ? aws_config_configuration_recorder.main[0].name : ""
  is_enabled = true
  depends_on = [aws_config_delivery_channel.main]
}
