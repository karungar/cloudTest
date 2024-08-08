import json
import boto3


def lambda_handler(event, context):
    client=boto3.resource('dynamodb')
    table=client.Table('resume-table')
    try:
        response=table.scan()
        items=response['Items']
        return {
            'statusCode': 200,
            'body': json.dumps(items)
        }
    except Exception as e:
        return{
            'statusCode': 500,
            'body': f'Error:{str(e)}'
            }
            