import xgboost as xgb


def test(event, context):
    return xgb.__version__
