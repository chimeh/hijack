#!/bin/bash
THIS_SCRIPT=$(realpath $(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)/$(basename ${BASH_SOURCE:-$0}))
#automatic detection TOPDIR
SCRIPT_DIR=$(dirname $(realpath ${THIS_SCRIPT}))


if [ $# -lt 1 ];then
  echo "usage $0 ./pathto/atlassian-xxx.zip [ckdir] [./pathto/mysql-connector-java-x.x.x-bin.jar] [LANGDIR]"
  exit 1
fi
ARCHIVE=$(realpath $1)

if [ $# -gt 1 ];then
   CKDIR=$(realpath $2)
  else 
   CKDIR="$SCRIPT_DIR/.ori-cked"
fi
echo "CKDIR=$CKDIR"
if [ $# -gt 2 ];then
    MYSQL_JDBC_FROM=$(realpath $3)
else
    MYSQL_JDBC_FROM="${SCRIPT_DIR}/jdbc/mysql-connector-java-5.1.40-bin.jar"
fi
if [ $# -gt 3 ];then
    LANGDIR=$(realpath $4)
   
fi


DATESTR=$(realpath $(date  +%Y%m%d-%Hh%Mm%Ss))
mkdir -p $DATESTR
###################################################################################################################
# patch and update hash
###################################################################################################################



HAVE_HASH_FILE=0

ATLASSIAN_EXTRAS=`unzip -l $ARCHIVE | grep "atlassian-extras-[0-9]" | awk '{print $4}'`
ATLASSIAN_UNIVERSAL=`unzip -l $ARCHIVE | grep atlassian-universal-plugin-manager-plugin- | awk '{print $4}'`
ATLASSIAN_UNIVERSAL_VER_MAJOR=$(echo ${ATLASSIAN_UNIVERSAL} | perl -n -e '/.+\/atlassian-universal-plugin-manager-plugin-([0-9]).([0-9.-]+).jar$/;print $1')
ATLASSIAN_EXTRAS_DECODER=`unzip -l $ARCHIVE | grep "atlassian-extras-decoder-[0-9v]" | awk '{print $4}'`


ATLASSIAN_HASH_FILES=`unzip -l $ARCHIVE | grep "hash-registry.properties" | awk '{print $4}'`
pushd $DATESTR

if [[ ! -z $ATLASSIAN_HASH_FILES ]];then
	HAVE_HASH_FILE=1
	unzip $ARCHIVE $ATLASSIAN_HASH_FILES -d $DATESTR
	cp $DATESTR/$ATLASSIAN_HASH_FILES $DATESTR/$ATLASSIAN_HASH_FILES.origin
fi
    if [[ ! -z $ATLASSIAN_EXTRAS ]];then
    #    echo "$ATLASSIAN_EXTRAS"
	    unzip $ARCHIVE $ATLASSIAN_EXTRAS -d $DATESTR
		cp $DATESTR/$ATLASSIAN_EXTRAS $DATESTR/$ATLASSIAN_EXTRAS.origin
		cp -v $CKDIR/$(basename $ATLASSIAN_EXTRAS) $DATESTR/$ATLASSIAN_EXTRAS
		if [[ $? -ne 0 ]];then  exit $?;fi
		zip -o $ARCHIVE $ATLASSIAN_EXTRAS
if [[ HAVE_HASH_FILE -ne 0 ]];then
        ATLASSIAN_EXTRAS_MD5=`unzip  -p $ARCHIVE  $ATLASSIAN_EXTRAS | md5sum | awk '{print $1}'`
    	ATLASSIAN_EXTRAS_MD5_P="`basename $ATLASSIAN_EXTRAS`"
		perl -i -n -e "s@(^[a-zA-Z_.-/]+$ATLASSIAN_EXTRAS_MD5_P)=.+@\1=$ATLASSIAN_EXTRAS_MD5@;print" $DATESTR/$ATLASSIAN_HASH_FILES
    fi
fi
    
    if [[ ! -z $ATLASSIAN_UNIVERSAL ]] && [[ ! "${ATLASSIAN_UNIVERSAL_VER_MAJOR}" =~ "4" ]];then
    #    echo "$ATLASSIAN_UNIVERSAL"
		unzip $ARCHIVE $ATLASSIAN_UNIVERSAL -d $DATESTR
		cp $DATESTR/$ATLASSIAN_UNIVERSAL $DATESTR/$ATLASSIAN_UNIVERSAL.origin
		cp -v $CKDIR/$(basename $ATLASSIAN_UNIVERSAL) $DATESTR/$ATLASSIAN_UNIVERSAL;
		if [[ $? -ne 0 ]];then exit $?;fi
		zip -o $ARCHIVE $ATLASSIAN_UNIVERSAL
    if [[ HAVE_HASH_FILE -ne 0 ]];then
        ATLASSIAN_UNIVERSAL_MD5=`unzip  -p $ARCHIVE  $ATLASSIAN_UNIVERSAL | md5sum | awk '{print $1}'`
    	ATLASSIAN_UNIVERSAL_MD5_LINE="fs.WEB-INF/atlassian-bundled-plugins/`basename $ATLASSIAN_UNIVERSAL`"
    	echo "$ATLASSIAN_UNIVERSAL_MD5_LINE=$ATLASSIAN_UNIVERSAL_MD5"
		perl  -n -e "print if m{^$ATLASSIAN_UNIVERSAL_MD5_LINE.+}" $DATESTR/$ATLASSIAN_HASH_FILES
		perl -i -n -e "s@^$ATLASSIAN_UNIVERSAL_MD5_LINE.+@$ATLASSIAN_UNIVERSAL_MD5_LINE=$ATLASSIAN_UNIVERSAL_MD5@;print" $DATESTR/$ATLASSIAN_HASH_FILES
    fi
fi
    
    if [[ ! -z $ATLASSIAN_EXTRAS_DECODER ]];then
    #    echo "$ATLASSIAN_EXTRAS_DECODER"
		unzip $ARCHIVE $ATLASSIAN_EXTRAS_DECODER -d $DATESTR
		cp $DATESTR/$ATLASSIAN_EXTRAS_DECODER $DATESTR/$ATLASSIAN_EXTRAS_DECODER.origin
		cp $DATESTR/$ATLASSIAN_EXTRAS_DECODER $DATESTR/$ATLASSIAN_EXTRAS_DECODER.origin
		cp -v $CKDIR/$(basename $ATLASSIAN_EXTRAS_DECODER) $DATESTR/$ATLASSIAN_EXTRAS_DECODER;
		if [[ $? -ne 0 ]];then exit $?;fi
		zip -o $ARCHIVE $ATLASSIAN_EXTRAS_DECODER
if [[ HAVE_HASH_FILE -ne 0 ]];then
        ATLASSIAN_EXTRAS_DECODER_MD5=`unzip  -p $ARCHIVE  $ATLASSIAN_EXTRAS_DECODER | md5sum | awk '{print $1}'`
    	ATLASSIAN_EXTRAS_DECODER_MD5_LINE="fs.WEB-INF/lib/`basename $ATLASSIAN_EXTRAS_DECODER`"
    	echo "$ATLASSIAN_EXTRAS_DECODER_MD5_LINE=$ATLASSIAN_EXTRAS_DECODER_MD5"
		perl  -n -e "print if m{^$ATLASSIAN_EXTRAS_DECODER_MD5_LINE.+}" $DATESTR/$ATLASSIAN_HASH_FILES
		perl -i -n -e "s@^$ATLASSIAN_EXTRAS_DECODER_MD5_LINE.+@$ATLASSIAN_EXTRAS_DECODER_MD5_LINE=$ATLASSIAN_EXTRAS_DECODER_MD5@;print" $DATESTR/$ATLASSIAN_HASH_FILES
    fi
	zip -o $ARCHIVE $ATLASSIAN_HASH_FILES
	popd

fi


###################################################################################################################
#update db driver
###################################################################################################################

pushd $DATESTR

#mysql-connector-java-5.1.40-bin.jar
MYSQL_JDBC_HAVE=`unzip -l $ARCHIVE | egrep "mysql-connector-java-[0-9.]+-bin.jar" | awk '{print $4}'`
if [[ -z $MYSQL_JDBC_HAVE && -n $MYSQL_JDBC_FROM ]];then
      HSQLDB_JDBC=`unzip -l $ARCHIVE | egrep "hsqldb-[0-9.]+jar" | awk '{print $4}'| head -n 1`
	  MYSQL_JDBC_TO=$(dirname $HSQLDB_JDBC)/$(basename $MYSQL_JDBC_FROM)
	  # no mysql jdbc, form path
      unzip $ARCHIVE $HSQLDB_JDBC -d $DATESTR
	  cp -v $MYSQL_JDBC_FROM $MYSQL_JDBC_TO
	  if [[ $? -ne 0 ]];then exit $?;fi
      zip -o $ARCHIVE $MYSQL_JDBC_TO
fi
popd

###################################################################################################################
# filename space to _,  and add lang 
###################################################################################################################
pushd $DATESTR
if [[ -n $LANGDIR ]];then
    pushd $LANGDIR
    HAVA_RENAME=`find $LANGDIR -maxdepth 1 -name "* *"`
    if [[ -n $HAVA_RENAME ]];then
      find $LANGDIR -maxdepth 1 -name "* *"|
      while read name;do
            na=$(echo $name | tr ' ' '_')
            mv "$name" $na
      done
    fi
    popd
fi


popd
#rm -rf $DATESTR
