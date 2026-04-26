<!-- BEGIN_TF_DOCS -->
# New Relic AWS Account Integration Terraform module
This Terraform module constructs and configures the necessary resources for integrating AWS Accounts into New Relic.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.42.0 |
| <a name="requirement_newrelic"></a> [newrelic](#requirement\_newrelic) | >= 3.85.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_stream.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_stream) | resource |
| [aws_config_configuration_recorder.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder_status.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_delivery_channel.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_iam_policy.cwstream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cwstream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.newrelic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cwstream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.newrelic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_firehose_delivery_stream.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_s3_bucket.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_versioning.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [newrelic_cloud_aws_integrations.api_polling](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/cloud_aws_integrations) | resource |
| [newrelic_cloud_aws_link_account.api_polling](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/cloud_aws_link_account) | resource |
| [newrelic_cloud_aws_link_account.metric_streams](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/cloud_aws_link_account) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cwstream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_newrelic_account_id"></a> [newrelic\_account\_id](#input\_newrelic\_account\_id) | This is your New Relic account id, and it is needed to only allow your account to assume the role needed for account linking. This is a required variable if the value of `link_aws_account_enabled` is set to `true`. | `string` | `""` | no |
| <a name="input_newrelic_license_key"></a> [newrelic\_license\_key](#input\_newrelic\_license\_key) | This is your New Relic ingest license key, and it is needed for Kinesis Firehose to successfully send metrics to your New Relic account. | `string` | n/a | yes |
| <a name="input_newrelic_role_name"></a> [newrelic\_role\_name](#input\_newrelic\_role\_name) | Specifies the name of the IAM role for integrating New Relic with an AWS account. | `string` | `"NewRelicInfrastructure-Integrations"` | no |
| <a name="input_newrelic_collector_endpoint"></a> [newrelic\_collector\_endpoint](#input\_newrelic\_collector\_endpoint) | This is the New Relic collector endpoint. The URL changes based on your account region (US/EU), and can be found on https://docs.newrelic.com/docs/infrastructure/amazon-integrations/aws-integrations-list/aws-metric-stream/#manual-setup. | `string` | `"https://aws-api.newrelic.com/cloudwatch-metrics/v1"` | no |
| <a name="input_link_aws_account_metric_streams_enabled"></a> [link\_aws\_account\_metric\_streams\_enabled](#input\_link\_aws\_account\_metric\_streams\_enabled) | Specifies whether to enable or disable the link(Metric Streams) between the New Relic account and the AWS account. When integrating with multiple AWS regions, please enable the link(Metric Streams) in only one region. Enabling it in multiple regions will cause errors. | `bool` | `true` | no |
| <a name="input_link_aws_account_metric_streams_name"></a> [link\_aws\_account\_metric\_streams\_name](#input\_link\_aws\_account\_metric\_streams\_name) | Specifies the name for the link(Metric Streams) between the NewRelic account and the AWS account. The name must be unique within the NewRelic account. If not specified, the default is `{AWS_ACCOUNT_ID}_MetricStreams`. | `string` | `null` | no |
| <a name="input_link_aws_account_api_polling_enabled"></a> [link\_aws\_account\_api\_polling\_enabled](#input\_link\_aws\_account\_api\_polling\_enabled) | Specifies whether to enable or disable the link(API Polling) between the New Relic account and the AWS account. When integrating with multiple AWS regions, please enable the link(API Polling) in only one region. Enabling it in multiple regions will cause errors. | `bool` | `false` | no |
| <a name="input_link_aws_account_api_polling_name"></a> [link\_aws\_account\_api\_polling\_name](#input\_link\_aws\_account\_api\_polling\_name) | Specifies the name for the link(API Polling) between the NewRelic account and the AWS account. The name must be unique within the NewRelic account. If not specified, the default is `{AWS_ACCOUNT_ID}_APIPolling`. | `string` | `null` | no |
| <a name="input_link_aws_account_api_polling_aws_integrations"></a> [link\_aws\_account\_api\_polling\_aws\_integrations](#input\_link\_aws\_account\_api\_polling\_aws\_integrations) | Specifies the parameters for AWS services to be integrated via API polling. This is required when `link_aws_account_api_polling_enabled` is set to `true`. In this case, you must set `enabled` to true for at least one of the services. If `enabled` is set to false for all services, or if the value of this input is not set, apply operation will fail. For a list of supported services and parameters for each service beyond `enabled`, refer to the details at https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/cloud_aws_integrations#integration-blocks. | `object` | `null` | no |
| <a name="input_create_metric_streams_aws_resources"></a> [create\_metric\_streams\_aws\_resources](#input\_create\_metric\_streams\_aws\_resources) | Specifies whether to enable or disable the creation of AWS resources necessary for integration using Metrics Streams. Set the value to `false` if you do not integrate using Metrics Streams. | `bool` | `true` | no |
| <a name="input_cloudwatch_metric_stream_output_format"></a> [cloudwatch\_metric\_stream\_output\_format](#input\_cloudwatch\_metric\_stream\_output\_format) | The output format for the CloudWatch Metric Stream. This module accepts only 'opentelemetry0.7' or 'opentelemetry1.0' (the underlying AWS resource also supports 'json', but this module is intended for OpenTelemetry formats only). | `string` | `"opentelemetry1.0"` | no |
| <a name="input_cloudwatch_metric_stream_include_filters"></a> [cloudwatch\_metric\_stream\_include\_filters](#input\_cloudwatch\_metric\_stream\_include\_filters) | List of filters specifying which metrics to include in the CloudWatch Metric Stream. Each filter must specify a 'namespace' and a list of 'metric\_names'. Providing an empty list for 'metric\_names' includes all metrics from the specified namespace. Mutually exclusive with cloudwatch\_metric\_stream\_exclude\_filters. Optional. | <pre>list(object({<br>    namespace    = string<br>    metric_names = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_cloudwatch_metric_stream_exclude_filters"></a> [cloudwatch\_metric\_stream\_exclude\_filters](#input\_cloudwatch\_metric\_stream\_exclude\_filters) | List of filters specifying which metrics to exclude from the CloudWatch Metric Stream. Each filter must specify a 'namespace' and a list of 'metric\_names'. Providing an empty list for 'metric\_names' all metrics in the namespace are excluded. Mutually exclusive with cloudwatch\_metric\_stream\_include\_filters. Optional. | <pre>list(object({<br>    namespace    = string<br>    metric_names = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_firehose_bucket_expiration_days"></a> [firehose\_bucket\_expiration\_days](#input\_firehose\_bucket\_expiration\_days) | Specifies the retention period for error records of Firehose. The value must be `0` or greater. If this parameter is not specified, the retention period will be indefinite. | `number` | `null` | no |
| <a name="input_aws_config_enabled"></a> [aws\_config\_enabled](#input\_aws\_config\_enabled) | Specifies whether to enable or disable AWS Config. New Relic utilizes AWS Config to collect metadata. If you want to collect metadata from AWS Config to enhance the attributes of your metrics, please enable AWS Config. If you integrate with an AWS account where AWS Config is already enabled, set the value to `false`. If the purpose of enabling AWS Config is to enhance security, it is advisable to enable AWS Config through other means. | `bool` | `false` | no |
| <a name="input_aws_config_configuration_recorder_resource_types"></a> [aws\_config\_configuration\_recorder\_resource\_types](#input\_aws\_config\_configuration\_recorder\_resource\_types) | A list that specifies the types of AWS resources for which AWS Config records configuration changes (for example, AWS::EC2::Instance or AWS::CloudTrail::Trail). See https://docs.aws.amazon.com/config/latest/APIReference/API_ResourceIdentifier.html#config-Type-ResourceIdentifier-resourceType for available types. This is a required variable if the value of `aws_config_enabled` is set to `true`. | `list(string)` | `[]` | no |
| <a name="input_aws_config_configuration_recording_frequency"></a> [aws\_config\_configuration\_recording\_frequency](#input\_aws\_config\_configuration\_recording\_frequency) | AWS Config recording frequency. `CONTINUOUS` or `DAILY`. | `string` | `"CONTINUOUS"` | no |
| <a name="input_config_bucket_expiration_days"></a> [config\_bucket\_expiration\_days](#input\_config\_bucket\_expiration\_days) | Specifies the retention period for snapshots of AWS Config. The value must be `0` or greater. If this parameter is not specified, the retention period will be indefinite. | `number` | `null` | no |

## Outputs

No outputs.

## Nested Inputs Reference

## Usage
### 1. Configure NewRelic Provider
#### Example
##### providers.tf
```hcl
provider "newrelic" {
  account_id = "1234567"
  api_key    = "NRAK-XXXXXXXXXXXXXXXXXXXXXXXXX"
}
```
##### terraform.tf
```hcl
terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "= 3.40.1"
    }
  }
}
```

### 2. Deploy module with refer to example usage

## Example Usage
```hcl
module "aws-account-integration" {
  source = "falcon-terraform-modules/aws-account-integration/newrelic"

  newrelic_account_id                     = "1234567"
  newrelic_license_key                    = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  link_aws_account_metric_streams_enabled = true
  link_aws_account_api_polling_enabled    = true
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
```
<!-- END_TF_DOCS -->