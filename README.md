# aws_lambda_xgboost
AWS Lambda Deployment Xgboost package Python 3.8

# Description

We all know with AWS Lambda *50Mb* limit on zip upload and *~262Mb* limit from AWS s3 unzipped total size. This script allows you to make a package that will have xgboost library with all the dependencies and joblib.

# Notes

- The final size is of the file in the zip is about 250M which leaves you about 12M for extra files and packages
- In most cases it's imposible to zip your models into the rest of 12Mb in the zip file (262 - 250) so here there a solotion with boto3 library how to load models from s3 buckets
- The model load call should be before lambda_function that's how it would be loaded once and not going to waste time in calls
- In the code it's suggested to load model into local AWS Lambda /tmp/ directory. That directory is limited to 500Mb 

# How to Install/Run

1. Clone this repo to your local folder

2. Run this command from the repo folder

```{bash}
sh build.sh
```

3. There will be generated folder __lambda-package__ and the zip file __lambda-package.zip__

4. Edit file `lambda_function.py` to adopt it to your models 

5. Add it to __lambda-package.zip__ file

6. Upload __lambda-package.zip__ into AWS s3 bucket

7. Set up up PATH in the AWS Lambda, Python 3.6 as Runtime, Increase memory in base settings

8. Create Test

9. Save

10. Test

11. Repeat until it works :) 

# Credits

[Alexey Butyrev](https://github.com/alexeybutyrev) for providing original xgb packaging in [origin repo](https://github.com/alexeybutyrev/aws_lambda_xgboost)
