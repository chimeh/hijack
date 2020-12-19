#!/bin/bash
THIS_SCRIPT=$(realpath $(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)/$(basename ${BASH_SOURCE:-$0}))
#automatic detection TOPDIR
SCRIPT_DIR=$(dirname $(realpath ${THIS_SCRIPT}))
USAGE="
  usage:
 $(basename $(realpath $0)) SRC_JAR DST_JAR
"

if [[ $# -eq 2 ]];then
    SRC_JAR=$1
    DST_JAR=$2
elif [[ $# -eq 1 ]];then
    SRC_JAR=${SCRIPT_DIR}/atlassian-extras-decoder-v2-3.2.jar
    DST_JAR=$1
else
   echo "Error"
   echo "${USAGE}"
   exit 1
fi
if [[ ! -f ${SRC_JAR} ]] || [[ ! -f ${DST_JAR} ]];then
   echo "Error"
   echo "${USAGE}"
   exit 1
fi
echo "## "
jar -xvf ${SRC_JAR}   com/atlassian/extras/decoder/v2/Version2LicenseDecoder.class
echo "## "
javap -c ${SCRIPT_DIR}/com/atlassian/extras/decoder/v2/Version2LicenseDecoder.class
echo "## "
jar -uvf ${DST_JAR} com/atlassian/extras/decoder/v2/Version2LicenseDecoder.class
echo "## "
jar -xvf ${DST_JAR}   com/atlassian/extras/decoder/v2/Version2LicenseDecoder.class
javap -c ${SCRIPT_DIR}/com/atlassian/extras/decoder/v2/Version2LicenseDecoder.class
echo "## "
jar -tvf ${DST_JAR}   com/atlassian/extras/decoder/v2/Version2LicenseDecoder.class 


