docker build --platform linux/amd64 -t xgb_lambda .

id=$(docker create xgb_lambda)
docker cp $id:/lambda-package.zip ./
