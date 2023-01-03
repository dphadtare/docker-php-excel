#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM php:7.4-apache
LABEL maintainer="Chase Pierce <cpierce@entrata.com> (@syntaqx), Dattatray Phadatare <dphadatare@entrata.com> (@dphadtare)"

ARG DISTRO=lin
ARG LIBXL_VER=4.0.4
ARG LIBXL_ZTS=20190902
ARG libxl_file=libxl-${DISTRO}-${LIBXL_VER}

# Install libXL
RUN set -ex; \
  apt-get update && apt-get install -y wget git libxml2-dev gcc \
  && cd /tmp \
  && wget http://www.libxl.com/download/libxl-lin-4.0.4.tar.gz \
  && tar -zxv -f ${libxl_file}.tar.gz \
  && cp /tmp/libxl-${LIBXL_VER}.0/lib64/libxl.so /usr/local/lib/libxl.so \
  && mkdir -p /usr/local/include/libxl_c/ \
  && cp /tmp/libxl-${LIBXL_VER}.0/include_c/* /usr/local/include/libxl_c/ \
  && cd /tmp \
  && docker-php-source extract \
  && git clone https://github.com/Jan-E/php_excel.git -b php7_with_pulls \
  && cd /tmp/php_excel \
  && phpize \
  && ./configure \
    --with-php-config=$(which php-config) \
    --with-libxl-incdir=/usr/local/include/libxl_c/ \
    --with-libxl-libdir=/tmp/libxl-${LIBXL_VER}.0/lib64/ \
    --with-libxml-dir=/usr/include/libxml2/ \
    --with-excel=/tmp/libxl-${LIBXL_VER}.0 \
  && make \
  && cp /tmp/php_excel/modules/excel.so /usr/local/lib/php/extensions/no-debug-non-zts-${LIBXL_ZTS}/ \
  && cp /tmp/libxl-${LIBXL_VER}.0/lib64/libxl.so /usr/lib/libxl.so \
  && apt-get remove -y wget git \
  && docker-php-source delete

