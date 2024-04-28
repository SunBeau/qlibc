#!/bin/bash
#***********************************************************************************************************************
#Author   : SunBeau
#Email    : SunBeau@163.com
#Date     : 2024-04-25
#FileName : pkgs-pgjdbc.sh
#Desc     : dev for qlibc
#***********************************************************************************************************************

# set -x
set -e

# 获取脚本所在路径
SCRIPT_HOME=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

PG_HOME="${SCRIPT_HOME}/pgsql.git.155/dist"
PG_PWD="123456"

#***********************************************************************************************************************
#

# shellcheck disable=SC2317
function fn_pgsql_install {
  cd "${SCRIPT_HOME}"

  git clone https://gitee.com/SunBeau/postgresql.git pgsql.git.155 --depth=1
  cd pgsql.git.155/

  ./configure --prefix="${PG_HOME}"
  make -j4
  make install
}

# shellcheck disable=SC2317
function fn_pgsql_initdb {
  # pwfile
  echo "${PG_PWD}" > /tmp/pg.pwfile

  # init
  "${PG_HOME}/bin/initdb" -D "${PG_HOME}/data" -U postgres -A md5 --pwfile=/tmp/pg.pwfile
}

# shellcheck disable=SC2317
function fn_pgsql_start {
  "${PG_HOME}/bin/pg_ctl" -D "${PG_HOME}/data" -l "${PG_HOME}/data/logfile" start
}

# shellcheck disable=SC2317
function fn_pgsql_psql {
  PGPASSWORD=${PG_PWD} "${PG_HOME}/bin/psql" -U postgres -d postgres
}

# shellcheck disable=SC2317
function fn_pgsql_stop {
  "${PG_HOME}/bin/pg_ctl" -D "${PG_HOME}/data" stop
}

# shellcheck disable=SC2317
function fn_qlibc_test {
  autoconf

  # ./configure --with-pgsql \
  # --with-pgsql-incdir=/usr/include \
  # --with-pgsql-libdir=/usr/lib64

  ./configure CFLAGS="-ggdb -O0" \
  --with-pgsql \
  --with-pgsql-incdir="${PG_HOME}/include" \
  --with-pgsql-libdir="${PG_HOME}/lib"

  make clean
  make

  cd tests

  # make clean
  # make
  # make test

  # export LD_LIBRARY_PATH="${PG_HOME}/lib"
  # ./test_qdatabase_pgsql

  make clean-ext
  make ext
  make test-ext
}

#***********************************************************************************************************************
# main

function main
{
  app=$1
  arg=$2
  functions=(\
    "fn_pgsql_install" \
    "fn_pgsql_initdb" \
    "fn_pgsql_start" \
    "fn_pgsql_psql" \
    "fn_pgsql_stop" \
    "fn_qlibc_test" \
  )

  # check arg and run it
  for func in "${functions[@]}"
  do
    if [ "${arg}" = "${func}" ]; then
      ${func}
      exit 0
    fi
  done

  # no match arg
  echo "Please use one of the following commands:"
  for func in "${functions[@]}"
  do
    echo "   ${app} ${func}"
  done
  exit 1
}

main "$0" "$1"