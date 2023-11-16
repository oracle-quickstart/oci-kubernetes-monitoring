## Streaming of Control Plane logs from CloudWatch to S3

We can use a CloudWatch logs subscription to stream log data in near real-time to AWS S3. Once available in S3, the log data can be pulled and ingested into OCI Logging Analytics.

[FilterWithFirehose](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html#FirehoseExample) page documents the steps needed to push the logs to S3 using Kinesis Data Firehose. This page builds on top of it and should be followed before enabling the log collection from S3.

The high level flow of CloudWatch logs to S3 looks as follows

![Control plane logs to S3](./eks-cp-logs-streaming.png)

The steps to be followed include:

### Create a new Lambda function

Create a new Lambda function using "Process CloudWatch logs sent to Kinesis Firehose" blueprint, preferably with Node.js 14.x runtime. Once created, update Lambda's *processRecords* function in *index.mjs* file with the below code. Note the Function ARN as it would be needed during the creation of Firehose delivery stream.

```
function processRecords (records) {
  return records.map(r => {
    const data = loadJsonGzipBase64(r.data)
    const recId = r.recordId
    // CONTROL_MESSAGE are sent by CWL to check if the subscription is reachable.
    // They do not contain actual data.
    if (data.messageType === 'CONTROL_MESSAGE') {
      return {
        result: 'Dropped',
        recordId: recId
      }
    } else if (data.messageType === 'DATA_MESSAGE') {
      // Replace "/" with an "_"
      let logGroupName = data.logGroup.replace(/\//g, '_')
      let logStreamName = data.logStream.replace(/\//g, '_')
      let prefix
      if (logStreamName.startsWith("kube-apiserver-audit")) {
        prefix = logGroupName + "/" + "kube-apiserver-audit/" + logStreamName
      } else if (logStreamName.startsWith("kube-apiserver")) {
        prefix = logGroupName + "/" + "kube-apiserver/" + logStreamName
      } else if (logStreamName.startsWith("authenticator")) {
        prefix = logGroupName + "/" + "authenticator/" + logStreamName
      } else if (logStreamName.startsWith("kube-controller-manager")) {
        prefix = logGroupName + "/" + "kube-controller-manager/" + logStreamName
      } else if (logStreamName.startsWith("cloud-controller-manager")) {
        prefix = logGroupName + "/" + "cloud-controller-manager/" + logStreamName
      } else if (logStreamName.startsWith("kube-scheduler")) {
        prefix = logGroupName + "/" + "kube-scheduler/" + logStreamName
      } else {
        prefix = "default"
      }
      const partition_keys = {
            object_prefix: prefix
        };
      const joinedData = data.logEvents.map(e => transformLogEvent(e)).join('')
      const encodedData = Buffer.from(joinedData, 'utf-8').toString('base64')
      return {
        data: encodedData,
        result: 'Ok',
        recordId: recId,
        metadata: { partitionKeys: partition_keys }
      }
    } else {
      return {
        result: 'ProcessingFailed',
        recordId: recId
      }
    }
  })
}
```

### Create a subscription filter with Amazon Kinesis Data Firehose

Once Lambda function is created, follow the below steps.

Create a S3 bucket with the name "\<my-bucket\>" in "\<my-region\>" region. You can select the S3 bucket name and region as per your choice.

```
aws s3api create-bucket --bucket <my-bucket> --create-bucket-configuration LocationConstraint=<my-region>
```

Create IAM role "FirehosetoS3Role", specifying the trust policy file "TrustPolicyForFirehose.json" as shown below. This role grants Kinesis Data Firehose permission to put data into the S3 bucket created above.

<details>
  <summary>TrustPolicyForFirehose.json</summary>

```
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```
</details>

```
aws iam create-role --role-name FirehosetoS3Role --assume-role-policy-document file://./TrustPolicyForFirehose.json
```

Create a permissions policy in file "PermissionsForFirehose.json" to define what actions Kinesis Data Firehose can do and associate it with the role "FirehosetoS3Role". Permission actions include putting objects into S3 bucket "\<my-bucket\>" and invoking Lambda function "\<my-function\>".

<details>
  <summary>PermissionsForFirehose.json</summary>

```
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject",
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "arn:aws:s3:::<my-bucket>",
        "arn:aws:s3:::<my-bucket>/*",
        "arn:aws:lambda:<my-region>:<aws-account-id>:function:<my-function>"
      ]
    }
  ]
}
```
</details>

```
aws iam put-role-policy --role-name FirehosetoS3Role --policy-name Permissions-Policy-For-Firehose --policy-document file://./PermissionsForFirehose.json
```

#### Create Firehose delivery stream

Create a destination Kinesis Data Firehose delivery stream "\<my-stream\>". This stream uses the Lambda function "\<my-function\>" created earlier to extract the log events and partition them before storage into S3.

```
aws firehose create-delivery-stream --delivery-stream-name '<my-stream>' --extended-s3-destination-configuration '{"RoleARN": "arn:aws:iam::<aws-account-id>:role/FirehosetoS3Role", "BucketARN": "arn:aws:s3:::<my-bucket>", "Prefix": "!{partitionKeyFromLambda:object\_prefix}/", "ErrorOutputPrefix": "errors/", "CompressionFormat": "GZIP", "DynamicPartitioningConfiguration": {"Enabled": true}, "ProcessingConfiguration": {"Enabled": true, "Processors": \[{"Type": "AppendDelimiterToRecord"},{"Type": "Lambda", "Parameters": \[{"ParameterName" :"LambdaArn", "ParameterValue" : "arn:aws:lambda:<my-region>:<aws-account-id>:function:<my-function>"}\]}\]}}'
```

Create an IAM role "CWLtoKinesisFirehoseRole" that grants CloudWatch logs permission to put data into Kinesis Data Firehose delivery stream created above.

<details>
  <summary>TrustPolicyForCWL.json</summary>

```
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringLike": {
          "aws:SourceArn": "arn:aws:logs:<my-region>:<aws-account-id>:*"
        }
      }
    }
  ]
}
```
</details>

```  
aws iam create-role --role-name CWLtoKinesisFirehoseRole --assume-role-policy-document file://./TrustPolicyForCWL.json
```

Create a permissions policy to define what actions CloudWatch logs can do.

<details>
  <summary>PermissionsForCWL.json</summary>

```
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "firehose:PutRecord"
      ],
      "Resource": [
        "arn:aws:firehose:<my-region>:<aws-account-id>:deliverystream/<my-stream>"
      ]
    }
  ]
}
```
</details>

```  
aws iam put-role-policy --role-name CWLtoKinesisFirehoseRole --policy-name Permissions-Policy-For-CWL --policy-document file://./PermissionsForCWL.json
```

#### Create logs subscription filter

Create CloudWatch Logs subscription filter, choosing the appropriate CloudWatch log group name.

```
aws logs put-subscription-filter --log-group-name "/aws/eks/<clusterName>/cluster" --filter-name "CWLToS3" --filter-pattern " " --destination-arn "arn:aws:firehose:<my-region>:<aws-account-id>:deliverystream/<my-stream>" --role-arn "arn:aws:iam::<aws-account-id>:role/CWLtoKinesisFirehoseRole"
```

Once the above steps are completed, the CloudWatch Logs will start appearing in S3 bucket. The S3 bucket object name would be created under \_aws\_eks\_\<clusterName\>\_cluster/logStreamType/\<logStreamName\>/ as shown below.

![s3-partitioned-logs](./s3-partitioned-logs.png)

We need to create and configure few other resources to enable us to collect the logs from S3.

**Create SQS Queues**

Create six SQS queues *apiserver*, *audit*, *authenticator*, *kube-controller-manager*, *cloud-controller-manager*, *scheduler* of "Standard" type and note down their ARN.

**Create SNS topic**

Create SNS topic like "\<my-sns\>". Once created, edit it to add six new subscriptions, one for each of the SQS queues created above. For every subscription ensure that "Enable raw message delivery" is explicitly enabled.

**SQS access policy (needed for each of the SQS queues).**

The below access policy is for *apiserver* SQS queue. Update the name of the queue as appropriate.

<details>
  <summary>SQS access policy</summary>

```
{
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:<my-region>:<aws-account-id>:apiserver",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "arn:aws:sns:<my-region>:<aws-account-id>:<my-sns>"
        }
      }
    }
  ]
}
```
</details>

**SNS access policy**

Also update its access policy (illustrated below) to allow S3 bucket "\<my-bucket\>" to publish to it.

<details>
  <summary>SNS access policy</summary>

```
{
  "Version": "2012-10-17",
  "Id": "example-ID",
  "Statement": [
    {
      "Sid": "Example SNS topic policy",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:<my-region>:<aws-account-id>:<my-sns>",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "<aws-account-id>"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:s3:*:*:<my-bucket>"
        }
      }
    }
  ]
}
```
</details>

**Update S3 bucket to send notifications** 

Go to the bucket properties and select "Create event notification" under "Event notifications". Select "All object create events" under "Event types". In Destination, select "SNS topic" and select the SNS topic created earlier, to which the event needs to be published.
