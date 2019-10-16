# aws_lambda_xgboost
AWS Lambda Deployment Xgboost package Python 3.6

# Description

We all know with AWS Lambda *50Mb* limit on zip upload and *~262Mb* limit from AWS s3 unzipped total size. This script allows you to make a package that will have xgboost library with all the dependencies and joblib.

# Notes

- The final size is of the file in the zip is about 254M which leaves you about 8M for extra files and packages
- In most cases it's imposible to zip your models into the rest of 8Mb in the zip file (262 - 254) so here there a solotion with boto3 library how to load models from s3 buckets
- The model load call should be before lambda_function that's how it would be loaded once and not going to waste time in calls
- In the code it's suggested to load model into local AWS Lambda /tmp/ directory. That directory is limited to 500Mb 

# How to Install/Run

1. Clone this repo to your local folder

2. Run this command from the repo folder

```{bash}
docker run -v $(pwd):/outputs -it amazonlinux:2016.09 /bin/bash /outputs/build.sh
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

[Ryan Brown](https://github.com/ryansb) for providing original packaging sklearn and numpy [example](https://github.com/ryansb/sklearn-build-lambda)
Here it was used [modified version](https://github.com/ryansb/sklearn-build-lambda/pull/16/commits/75c713d23107300370b16b134936b959f1f0f73b) to Python 3.6 from [Mark Campanelli](https://github.com/markcampanelli)

[Jing Xie](https://www.linkedin.com/in/jing-xie-4a307012/) and [Ken Mcdonnell](https://www.linkedin.com/in/ken-mcdonnell-b438b237/) for helping with deploying models and debugging.
