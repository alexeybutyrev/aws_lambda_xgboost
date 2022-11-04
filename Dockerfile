FROM amazonlinux:2.0.20221004.0 AS base
# FROM amazonlinux:2016.09
RUN set -ex

RUN # Set up env vars
ENV PYTHON_VER_YUM="38"
ENV PYTHON_VER="3.8"

# only for amazon linux images v2 - enable py3.8
RUN amazon-linux-extras enable python${PYTHON_VER}

RUN # Update this container
RUN echo "Yum updating container..." > /dev/null 2>&1
RUN yum -y update
RUN echo "Yum updating container...done" > /dev/null 2>&1


ENV LAMBDA_PACKAGE_DIR="outputs/lambda-package"
ENV LIB_DIR="${LAMBDA_PACKAGE_DIR}/lib"
ENV LAMBDA_PACKAGE_ZIP="lambda-package.zip"

ENV SITE_PACKAGES_DIR="/usr/local/lib64/python${PYTHON_VER}/site-packages"

RUN echo "Yum installing non-pip packages..." > /dev/null 2>&1
RUN yum -y install \
  binutils \
  pkgconfig \
  atlas-devel \
  libatlas-base-dev \
  gfortran \
  atlas-sse3-devel \
  blas-devel \
  findutils \
  gcc \
  gcc-c++ \
  git \
  gzip \
  tar \
  wget \
  make \
  lapack-devel \
  findutils \
  python${PYTHON_VER_YUM} \
  python${PYTHON_VER_YUM}-devel \
  python${PYTHON_VER_YUM}-dev \
  python${PYTHON_VER_YUM}-virtualenv \
  python${PYTHON_VER_YUM}-pip \
  zip && \
  yum clean all && \
  rm -rf /var/cache/yum

RUN echo "Yum installing non-pip packages...done" > /dev/null 2>&1

ENV NUMPY_VER='1.19.5'
ENV SCIPY_VER='1.9.3'

RUN echo "Pip installing packages using local compilation for numpy and scipy..." > /dev/null 2>&1
RUN /usr/bin/python${PYTHON_VER} -m pip install --upgrade Cython==0.29.32 pip==22.3 setuptools==53.1.0
# RUN /usr/bin/python${PYTHON_VER} -m pip install --no-binary numpy==${NUMPY_VER}
RUN /usr/bin/python${PYTHON_VER} -m pip install numpy==${NUMPY_VER}
# RUN /usr/bin/python${PYTHON_VER} -m pip install --no-binary scipy scipy==${SCIPY_VER}
RUN /usr/bin/python${PYTHON_VER} -m pip install scipy scipy==${SCIPY_VER}
RUN /usr/bin/python${PYTHON_VER} -m pip install --target ${SITE_PACKAGES_DIR} xgboost==0.90
# RUN /usr/bin/python${PYTHON_VER} -m pip install xgboost==0.90
RUN /usr/bin/python${PYTHON_VER} -m pip install --target ${SITE_PACKAGES_DIR} joblib
# RUN /usr/bin/python${PYTHON_VER} -m pip install joblib
RUN echo "Pip installing packages using local compilation for numpy and scipy...done" > /dev/null 2>&1

RUN echo "Verfifying installation..." > /dev/null 2>&1
RUN /usr/bin/python${PYTHON_VER} -V
RUN /usr/bin/python${PYTHON_VER} -c "import numpy as np; print(np.version.version)"
RUN /usr/bin/python${PYTHON_VER} -c "import numpy as np; print(np.__config__.show())"
RUN /usr/bin/python${PYTHON_VER} -c "import scipy as sp; print(sp.version.version)"
RUN /usr/bin/python${PYTHON_VER} -c "import xgboost; print(xgboost.__version__)"
RUN /usr/bin/python${PYTHON_VER} -c "import joblib; print(joblib.__version__)"

RUN echo "Verfifying installation...done" > /dev/null 2>&1

RUN echo "Preparing ${LIB_DIR}..." > /dev/null 2>&1
RUN mkdir -p "${LIB_DIR}"
RUN echo "Preparing ${LIB_DIR}...done" > /dev/null 2>&1
RUN ls "$SITE_PACKAGES_DIR"
RUN echo "Copying ${SITE_PACKAGES_DIR} contents to ${LAMBDA_PACKAGE_DIR}..." > /dev/null 2>&1
RUN mkdir -p "${LAMBDA_PACKAGE_DIR}"
RUN cp -rf ${SITE_PACKAGES_DIR}/* ${LAMBDA_PACKAGE_DIR}
RUN echo "Copying ${SITE_PACKAGES_DIR} contents to ${LAMBDA_PACKAGE_DIR}...done" > /dev/null 2>&1

RUN echo "Copying compiled libraries to ${LIB_DIR}..." > /dev/null 2>&1
RUN cp /usr/lib64/atlas/* ${LIB_DIR}
RUN cp /usr/lib64/libquadmath.so.0 ${LIB_DIR}
RUN cp /usr/lib64/libgfortran.so.4 ${LIB_DIR}
RUN echo "Copying compiled libraries to ${LIB_DIR}...done" > /dev/null 2>&1

RUN echo "Reducing package size..." > /dev/null 2>&1
RUN echo "Original unzipped package size: $(du -sh ${LAMBDA_PACKAGE_DIR} | cut -f1)" > /dev/null 2>&1
# Remove README
# RUN rm ${LAMBDA_PACKAGE_DIR}/README
# Remove distribution info directories
RUN rm -rf ${LAMBDA_PACKAGE_DIR}/*.egg-info
RUN rm -rf ${LAMBDA_PACKAGE_DIR}/*.dist-info
# Remove all testing directories
RUN find ${LAMBDA_PACKAGE_DIR} -name tests | xargs rm -rf
# strip excess from compiled .so files
RUN find ${LAMBDA_PACKAGE_DIR} -name "*.so" | xargs strip
RUN echo "Final unzipped package size: $(du -sh ${LAMBDA_PACKAGE_DIR} | cut -f1)" > /dev/null 2>&1
RUN echo "Reducing package size...done" > /dev/null 2>&1

RUN echo "Compressing packages into ${LAMBDA_PACKAGE_ZIP}..." > /dev/null 2>&1
RUN pushd ${LAMBDA_PACKAGE_DIR} > /dev/null 2>&1 && zip -r9q /${LAMBDA_PACKAGE_ZIP} * ; popd > /dev/null 2>&1
RUN echo "lambda-package.zip size: $(du -sh ${LAMBDA_PACKAGE_ZIP} | cut -f1)" > /dev/null 2>&1
RUN echo "Compressing packages into lambda-package.zip...done" > /dev/null 2>&1

RUN echo "SUCCESS!!!" > /dev/null 2>&1

RUN echo "USAGE TIPS:" > /dev/null 2>&1
RUN echo "  Add your lambda function handler module to the top level of ${LAMBDA_PACKAGE_ZIP} (optionally including the .pyc file in __pycache__)" > /dev/null 2>&1
RUN echo "  --OR--" > /dev/null 2>&1
RUN echo "  Add your lambda function handler module to the top level of ${LAMBDA_PACKAGE_DIR} (optionally including the .pyc file in __pycache__) and zip with maximum compression" > /dev/null 2>&1
