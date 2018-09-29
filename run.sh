#!/bin/bash
PRINT_FLAG="false"
PROGRESSBAR_FLAG=false
D_MODE=""
E_ARG=55	#usage error
WRONG_CNT=0
SUM_TIME_INIT=0
SUM_TIME_LUDE=0
SUM_TIME_CHCK=0

# Usage info
show_help()
{
	echo "Usage: [-f ./filename] [-H] [-r repeat] <size|file> <threads>
-f	./filename	Executable file name.	
-r	repeat		Repeat execution.
-p			Print result one by one for repeated work.
-a			Calculate average time. #not implemented
-b			Print progress bar. #not implemented
-H			Help
		
For Example: ./run.h -f ./lu -r 1000 3000 10
"
exit ${E_ARG}
}

while getopts "dpHr:f:" OPT
do
	case $OPT in
		d)
			D_MODE="-d"	
			;;
		H) 
			show_help	;;
		r)
			re="${OPTARG}"	;;
		f)
			executefile="${OPTARG}" ;;
		p)
			PRINT_FLAG="true"
			;;
		b)
			PROGRESSBAR_FLAG=true
			;;
		\?)
			echo "Invalid option: -$OPTARG. Use -H flag for help."
			exit ${E_ARG}
			;;
	esac
done

#OPTIND shift
shift $(( $OPTIND - 1))

arg1=$1			#matrix size : n
arg2=$2			#thread num


MATRIX_SIZE=${arg1}
THREADS_NUM=${arg2:-16} 

if [ $# = 0 ]
then
	echo "Invalid argument: Use -H flag for help."
	exit $E_ARG
fi

#make use Makefil
make

#anounce
echo "[PROGRAM INFO]
 ---------------------------------------------------------------
| program name	| size or file	| threads num	| repeat count	|
| ${executefile}		| ${MATRIX_SIZE}		| ${THREADS_NUM}threads	| ${re:-1}times	|
 ---------------------------------------------------------------"

RE_CNT=${re:-1}
while [ ${re:-1} -ge 1 ]; do
	${executefile:-./lu} ${MATRIX_SIZE} ${THREADS_NUM} ${D_MODE}>temp
	exec 3<>temp
	read a1<&3
	if ${PRINT_FLAG}; then
		echo ${a1}
	fi
	time_init=${a1:0:7}
	time_lude=${a1:8:7}
	time_chck=${a1:16:7}

	SUM_TIME_INIT=`echo $SUM_TIME_INIT + $time_init | bc`
	SUM_TIME_LUDE="$( bc <<<"$SUM_TIME_LUDE + $time_lude" )"
	SUM_TIME_CHCK="$( bc <<<"$SUM_TIME_CHCK + $time_chck" )"

	len=${#a1}
	correct=${a1:$len-1:$len-0}
	if [ $correct != 0 ]
	then
		((WRONG_CNT++))
	fi
	re=$(( ${re}-1 ))
done

#It is correct when wrong count is 0.
if [ ${WRONG_CNT} == 0 ]
then
	echo "[CORRECT]"
else
	echo "[WRONG]: ${WRONG_CNT}times"
fi

AVG_TIME_INIT="$( bc <<<"scale=5;$SUM_TIME_INIT/$RE_CNT" )"
AVG_TIME_LUDE="$( bc <<<"scale=5;$SUM_TIME_LUDE/$RE_CNT" )"
AVG_TIME_CHCK="$( bc <<<"scale=5;$SUM_TIME_CHCK/$RE_CNT" )"
printf "INIT: %.5f  LUDE: %.5f  CHCK: %.5f\n" "${AVG_TIME_INIT}" "${AVG_TIME_LUDE}" "${AVG_TIME_CHCK}"
