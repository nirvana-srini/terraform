import json

def helloworld_function_1(event, context):
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Python latest Version 15!')
    }
