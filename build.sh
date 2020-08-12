#!/bin/bash
set -ex

# Update this container
echo "Yum updating container..." > /dev/null 2>&1
yum -y update
echo "Yum updating container...done" > /dev/null 2>&1

# Set up env vars
PYTHON_VER_YUM='36'
PYTHON_VER='3.6'
NUMPY_VER='1.13.3'
SCIPY_VER='0.19.1'
SKLEARN_VER='0.21.3'

LAMBDA_PACKAGE_DIR='outputs/lambda-package'
LIB_DIR="${LAMBDA_PACKAGE_DIR}/lib"
LAMBDA_PACKAGE_ZIP='lambda-package.zip'
LAMBDA_PACKAGE_ZIP_RELPATH="outputs/${LAMBDA_PACKAGE_ZIP}"

SITE_PACKAGES_DIR="/usr/local/lib64/python${PYTHON_VER}/site-packages"

echo "Yum installing non-pip packages..." > /dev/null 2>&1
yum -y install \
    atlas-devel \
    atlas-sse3-devel \
    blas-devel \
    findutils \
    gcc \
    gcc-c++ \
    lapack-devel \
    python${PYTHON_VER_YUM}-devel \
    zip
echo "Yum installing non-pip packages...done" > /dev/null 2>&1

echo "Pip installing packages using local compilation for numpy and scipy..." > /dev/null 2>&1
/usr/bin/pip-${PYTHON_VER} install --upgrade pip==9.0.3 setuptools
/usr/bin/pip-${PYTHON_VER} install --no-binary numpy numpy==${NUMPY_VER}
/usr/bin/pip-${PYTHON_VER} install --no-binary scipy scipy==${SCIPY_VER}
/usr/bin/pip-${PYTHON_VER} install --target $SITE_PACKAGES_DIR xgboost==0.90 
/usr/bin/pip-${PYTHON_VER} install --target $SITE_PACKAGES_DIR joblib
echo "Pip installing packages using local compilation for numpy and scipy...done" > /dev/null 2>&1

echo "Verfifying installation..." > /dev/null 2>&1
/usr/bin/python${PYTHON_VER} -V
/usr/bin/python${PYTHON_VER} -c "import numpy as np; print(np.version.version)"
/usr/bin/python${PYTHON_VER} -c "import numpy as np; print(np.__config__.show())"
/usr/bin/python${PYTHON_VER} -c "import scipy as sp; print(sp.version.version)"
/usr/bin/python${PYTHON_VER} -c "import xgboost; print(xgboost.__version__)"
/usr/bin/python${PYTHON_VER} -c "import joblib; print(joblib.__version__)"

echo "Verfifying installation...done" > /dev/null 2>&1

echo "Preparing ${LIB_DIR}..." > /dev/null 2>&1
mkdir -p ${LIB_DIR}
echo "Preparing ${LIB_DIR}...done" > /dev/null 2>&1
ls $SITE_PACKAGES_DIR
echo "Copying ${SITE_PACKAGES_DIR} contents to ${LAMBDA_PACKAGE_DIR}..." > /dev/null 2>&1
cp -rf ${SITE_PACKAGES_DIR}/* ${LAMBDA_PACKAGE_DIR}
echo "Copying ${SITE_PACKAGES_DIR} contents to ${LAMBDA_PACKAGE_DIR}...done" > /dev/null 2>&1

echo "Copying compiled libraries to ${LIB_DIR}..." > /dev/null 2>&1
cp /usr/lib64/atlas/* ${LIB_DIR}
cp /usr/lib64/libquadmath.so.0 ${LIB_DIR}
cp /usr/lib64/libgfortran.so.3 ${LIB_DIR}
echo "Copying compiled libraries to ${LIB_DIR}...done" > /dev/null 2>&1

echo "Reducing package size..." > /dev/null 2>&1
echo "Original unzipped package size: $(du -sh ${LAMBDA_PACKAGE_DIR} | cut -f1)" > /dev/null 2>&1
# Remove README
rm ${LAMBDA_PACKAGE_DIR}/README
# Remove distribution info directories
rm -rf ${LAMBDA_PACKAGE_DIR}/*.egg-info
rm -rf ${LAMBDA_PACKAGE_DIR}/*.dist-info
# Remove all testing directories
find ${LAMBDA_PACKAGE_DIR} -name tests | xargs rm -rf
# strip excess from compiled .so files
find ${LAMBDA_PACKAGE_DIR} -name "*.so" | xargs strip
echo "Final unzipped package size: $(du -sh ${LAMBDA_PACKAGE_DIR} | cut -f1)" > /dev/null 2>&1
echo "Reducing package size...done" > /dev/null 2>&1

echo "Compressing packages into ${LAMBDA_PACKAGE_ZIP}..." > /dev/null 2>&1
pushd ${LAMBDA_PACKAGE_DIR} > /dev/null 2>&1 && zip -r9q /${LAMBDA_PACKAGE_ZIP_RELPATH} * ; popd > /dev/null 2>&1
echo "lambda-package.zip size: $(du -sh ${LAMBDA_PACKAGE_ZIP_RELPATH} | cut -f1)" > /dev/null 2>&1
echo "Compressing packages into lambda-package.zip...done" > /dev/null 2>&1

echo "SUCCESS!!!" > /dev/null 2>&1

echo "USAGE TIPS:" > /dev/null 2>&1
echo "  Add your lambda function handler module to the top level of ${LAMBDA_PACKAGE_ZIP_RELPATH} (optionally including the .pyc file in __pycache__)" > /dev/null 2>&1
echo "  --OR--" > /dev/null 2>&1
echo "  Add your lambda function handler module to the top level of ${LAMBDA_PACKAGE_DIR} (optionally including the .pyc file in __pycache__) and zip with maximum compression" > /dev/null 2>&1

