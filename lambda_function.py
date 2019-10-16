import json, xgboost, joblib

def load_model(bucket_name, model_file_name, model_local_path = '/tmp/' +model_file_name):
    '''  Load model from s3 bucket function
         bucket_name  - s3 location
         model_file_name - name of the model file (pkl file) 
         model_local_path - local path for AWS Lambda by default is /tmp which is 500M limit
    '''
    session = boto3.client('s3')
    session.download_file(bucket_name, model_file_name, model_local_path)    
    return joblib.load(model_local_path)

# define bucket_name model_file_name 
model = load_model(bucket_name='', model_file_name='')

def lambda_handler(event, context):
    # define event in Test
    # define your load function you may need to add it here or outside file
    # prediction = model(event)
    prediction = event 
    return {'prediction': prediction}
