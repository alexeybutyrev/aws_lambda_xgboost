rm -rf lambda-packag*

docker build --platform linux/amd64 -t xgb_lambda .

id=$(docker create xgb_lambda)
docker cp $id:/lambda-package.zip ./

mkdir lambda-package
cd lambda-package
unzip ../lambda-package.zip
cd ..
cp lambda_xgb_version.py lambda-package/
docker run --rm \
  -v "$PWD"/lambda-package:/var/task:ro,delegated \
  lambci/lambda:python3.8 \
  lambda_xgb_version.test
#   [-v <layer_dir>:/opt:ro,delegated] \
