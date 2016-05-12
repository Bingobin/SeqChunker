#!/bin/bash

DIR=$(dirname $0);
cd $DIR;
EC="$DIR/ec.fa"
SC="$DIR/../bin/SeqChunker"
TC=0;
rm -f tmp*;

TEMPFILENAME="$DIR/tmp"

TESTCOUNTER=1;

TOTAL_NUMBER_OF_TESTS=2

echo "$TESTCOUNTER..$TOTAL_NUMBER_OF_TESTS"

##----------------------------------------------------------------------------##
#
# Define a FASTA test script
#
##----------------------------------------------------------------------------##

function test_fasta {
    DESC="$1"
    cmd="$2"

    PIPE_FLAG="NOPIPE"

    # assume the third parameter set switches into pipe mode
    if [ $# -eq 3 ]
    then
	PIPE_FLAG="PIPE"
    fi

    STATUS=""

    # delete all existing tmp files
    rm -f "$TEMPFILENAME"*;

    if [ "$PIPE_FLAG" == "PIPE" ]
    then
	$cmd 2>/dev/null >"$TEMPFILENAME"
    else
	$cmd 2>/dev/null

	# combine all output to a single file
	cat "$TEMPFILENAME".* >"$TEMPFILENAME"
    fi

    DIFF=$(diff "$EC" "$TEMPFILENAME")
    if [ ! -z "$DIFF" ]; then
	STATUS="not ok"
    else
	STATUS="ok"
    fi

    echo "$STATUS $TESTCOUNTER - $DESC (command was '$cmd')"

    # finally increment the test counter
    TESTCOUNTER=$((TESTCOUNTER+1))
}

test_fasta "split pipe" "$SC -n 10 $EC"                                    "PIPE"
test_fasta "split file" "$SC -n 20 $EC -o $TEMPFILENAME.$TESTCOUNTER.%02d"

# FASTA


#3 split steps
DESC="split steps"
echo "Test #"$((++TC))" $DESC";
TF="$DIR/tmp"
cmd="$SC -n 20 -x 5 $EC -o tmp.$TC.%02d"
echo "$cmd";
$cmd;

DIFF=$( diff tmp.$TC.01 tmp.$(($TC-1)).01 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    # echo "$DIFF" 1>&2;
    exit 1;
fi;
DIFF=$( diff tmp.$TC.06 tmp.$(($TC-1)).06 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    # echo "$DIFF" 1>&2;
    exit 1;
fi;
DIFF=$( diff tmp.$TC.16 tmp.$(($TC-1)).16 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    # echo "$DIFF" 1>&2;
    exit 1;
fi;
echo "..ok"


#4 split first last step
DESC="split first last step"
echo "Test #"$((++TC))" $DESC";
TF="$DIR/tmp"
cmd="$SC  -n 20 -x 5 -y 2 -f 2 -l 12 $EC -o tmp.$TC.%02d"
echo "$cmd";
$cmd;
DIFF=$( diff tmp.$TC.02 tmp.$(($TC-2)).02 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    echo "$DIFF" 1>&2;
    exit 1;
fi;
DIFF=$( diff tmp.$TC.03 tmp.$(($TC-2)).03)
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    echo "$DIFF" 1>&2;
    exit 1;
fi;

DIFF=$( diff tmp.$TC.07 tmp.$(($TC-2)).07 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    echo "$DIFF" 1>&2;
    exit 1;
fi;
DIFF=$( diff tmp.$TC.12 tmp.$(($TC-2)).12 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    echo "$DIFF" 1>&2;
    exit 1;
fi;
if [ -e "tmp.$TC.13" ]; then
    echo "..failed"
    echo "last not respected" 1>&2;
    echo "$DIFF" 1>&2;
    exit 1;
fi;
echo "..ok"




#5 split in many chunks
DESC="split file many chunks"
echo "Test #"$((++TC))" $DESC";
TF="$DIR/tmp"
cmd="$SC -n 1000 $EC -o tmp.$TC.%04d"
echo "$cmd";
$cmd;
cat tmp.$TC.* > $TF;

DIFF=$(diff $EC $TF)
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    #echo "$DIFF" 1>&2;
    exit 1;
fi;
echo "..ok"


#6 split late first
DESC="split late first"
echo "Test #"$((++TC))" $DESC";
TF="$DIR/tmp"
cmd="$SC -n 1000 -f 1000 -l 1000 $EC -o tmp.$TC.%04d"
echo "$cmd";
$cmd;

DIFF=$( diff tmp.$TC.1000 tmp.$(($TC-1)).1000 2>&1)
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
     echo "$DIFF" 1>&2;
    exit 1;
fi;
echo "..ok"


















##----------------------------------------------------------------------------##

# FASTQ
EC="$DIR/ec.fq"
DESC="split pipe"
echo "Test #"$((++TC))" $DESC";
TF="$DIR/tmp"
cmd="$SC -n 10 $EC"
echo "$cmd";
$cmd > $TF

DIFF=$(diff $EC $TF)
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    echo "$DIFF" 1>&2;
    exit 1;
fi;
echo "..ok"


# split in chunks
DESC="split file"
echo "Test #"$((++TC))" $DESC";
TF="$DIR/tmp"
cmd="$SC -n 20 $EC -o tmp.$TC.%02d"
echo "$cmd";
$cmd;
cat tmp.$TC.* > $TF;

DIFF=$(diff $EC $TF)
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    #echo "$DIFF" 1>&2;
    exit 1;
fi;
echo "..ok"


# split steps
DESC="split steps"
echo "Test #"$((++TC))" $DESC";
TF="$DIR/tmp"
cmd="$SC -n 20 -x 5 $EC -o tmp.$TC.%02d"
echo "$cmd";
$cmd;

DIFF=$( diff tmp.$TC.01 tmp.$(($TC-1)).01 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    # echo "$DIFF" 1>&2;
    exit 1;
fi;
DIFF=$( diff tmp.$TC.06 tmp.$(($TC-1)).06 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    # echo "$DIFF" 1>&2;
    exit 1;
fi;
DIFF=$( diff tmp.$TC.16 tmp.$(($TC-1)).16 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    # echo "$DIFF" 1>&2;
    exit 1;
fi;
echo "..ok"


# split first last step
DESC="split first last step"
echo "Test #"$((++TC))" $DESC";
TF="$DIR/tmp"
cmd="$SC -n 20 -x 5 -y 2 -f 2 -l 12 $EC -o tmp.$TC.%02d"
echo "$cmd";
$cmd;

DIFF=$( diff tmp.$TC.02 tmp.$(($TC-2)).02 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    # echo "$DIFF" 1>&2;
    exit 1;
fi;
DIFF=$( diff tmp.$TC.03 tmp.$(($TC-2)).03)
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    # echo "$DIFF" 1>&2;
    exit 1;
fi;
DIFF=$( diff tmp.$TC.07 tmp.$(($TC-2)).07 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    # echo "$DIFF" 1>&2;
    exit 1;
fi;
DIFF=$( diff tmp.$TC.12 tmp.$(($TC-2)).12 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    # echo "$DIFF" 1>&2;
    exit 1;
fi;
if [ -e "tmp.$TC.13" ]; then
    echo "..failed"
    echo "last not respected" 1>&2;
    # echo "$DIFF" 1>&2;
    exit 1;
fi;
echo "..ok"


# split first last step
DESC="split late first"
echo "Test #"$((++TC))" $DESC";
TF="$DIR/tmp"
cmd="$SC -n 20 -f 19 -l 19 $EC -o tmp.$TC.%02d"
echo "$cmd";
$cmd;

DIFF=$( diff tmp.$TC.19 tmp.$(($TC-3)).19 )
if [ ! -z "$DIFF" ]; then
    echo "..failed"
    echo "unexpected difference found:" 1>&2;
    # echo "$DIFF" 1>&2;
    exit 1;
fi;
echo "..ok"

# check against the dd-based estimated checksums
DESC="Checksum test"
echo "Test #"$((++TC))" $DESC";
cmd="md5sum -c MD5SUM.dd --quiet"
echo "$cmd";
$cmd;
if [ $? -ne 0 ]; then
    echo "..failed"
    echo "Different checksums found:" 1>&2;
    exit 1;
fi;
echo "..ok"

rm tmp*


