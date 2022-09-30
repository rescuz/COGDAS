#!/bin/bash
set -e
set -o pipefail
echo `hostname`
echo =====start at `date "+%Y-%m-%d %H:%M:%S"`=====
green='\033[32m'

help()
{
 Usage="ProgramName:COGDAS.R \n
	Description: this program is used to perform difference anaysis in two groups for all kinds of datas with convenient and one stop way. The output content including all genes txt (difference expression genes txt) and volcano plot about all genes. \n
	\n
	Usage: sh run.COGDAS.sh [OPTION] \n\
	\n
	Version:beta1.0 \n \
	Date:2022.09.30 \n \
	Design:Bing Zeng \n \
	Coding:Bing Zeng   \n \
	Email:bingzengvip@163.com \n \
Options:\n\
      [ -s | --singularity] \t-- the absolute path of singularity \n \
      [ -m | --matrix] \t-- the input expression matrix \n \
      [ -c | --clin ] \t-- the clinical information, group information included  \n \
      [ -r | --res_dir ] \t-- the path to output results  \n \
      [ -S|--seqdata_type ] \t-- sequence data type, chip or RNA-seq  \n \
      [ -t|--to_fpkm ] \t-- if the data format of chip platform is raw-count, and wants to transform into FPKM, then you can input Yes. Or your can input NA' \n \
      [ -T|--transdata_type ] \t-- transciptional data type, raw-count or FPKM  \n \
      [ -p|--pvalue ] \t-- default value is 0.05  \n \
      [ -l|--logFC ] \t-- default value is 1  \n \
      [ -L|--lowvalue ] \t-- The value is used for filteration, default value is 1  \n \
      [ -M|--method ] \t-- default method is DESeq2, but you could choose edgeR or combinnation of DESeq2 and edgeR(overlap)  \n \
      [ -a|--algorithm ] \t-- default algorithm of edger is glm. In the condtion of other methods, you could input NA  \n \
      [ -R|--ref_fac ] \t-- default reference factor is "control". The parameter should be specified when you choose DESeq2 or overlap model  \n \
      [ -d|--script_dir ] \t-- the path of R script   \n \
      [ -P|--probe_symbol ] \t-- please provide a list to transform probe to SYMBOL,  when you had those demands, (1) transform raw-count into FPKM; (2) transform probe_id to GENE_SYMBOL to show it in graph or table. Or you could input NA'  \n \
      [ -h | --help ] \t\t-- help information \n \
      "
 echo -e ${green} $Usage
 exit 2
}

ARGS=$(getopt -a -n run.COGDAS.sh -o s:m:c:r:S:t:T:p:l:L:M:a:R:P:d:h --long singularity:,matrix:,clin:,res_dir:,seqdata_type:,to_fpkm:,transdata_type:,pvalue:,logFC:,lowvalue:,method:,algorithm:,ref_fac:,probe_symbol:,script_dir:,help -- "$@")
VALID_ARGS=$?
if [ "$VALID_ARGS" != "0" ]; then
help  
fi

singularity=/opt/singularity/3.9.2/bin/singularity
eval set -- "$ARGS"
while :
do
case "$1" in
	-s | --singularity)            
		singularity=$2  
		shift 2
		;;
   	-m | --matrix)   
		matrix=$2     
		shift 2 
		;;
   	-c | --clin)   
		clin=$2     
		shift 2 
		;;
   	-r | --res_dir)   
		res_dir=$2    
		shift 2 
		;;
   	-S|--seqdata_type) 
		seqdata_type=$2 
		shift 2 ;;
        -t|--to_fpkm)
            to_fpkm=$2
            shift 2
            ;;
        -T|--transdata_type)
            transdata_type=$2
            shift 2
            ;;
        -p|--pvalue)
            pvalue=$2
            shift 2
            ;;
        -l|--logFC)
            logFC=$2
            shift 2
            ;;
        -L|--lowvalue)
            lowvalue=$2
            shift 2
            ;;
        -M|--method)
            method=$2
            shift 2
            ;;
	-a|--algorithm)
            algorithm=$2
            shift 2
            ;;
        -R|--ref_fac)
            ref_fac=$2
            shift  2
            ;;
        -P|--probe_symbol)
            probe_symbol=$2
            shift  2
            ;;
        -d|--script_dir)
            script_dir=$2
            shift 2
            ;;
	-h | --help)             
	    help
	    exit 0
	    shift 
	    ;;    
   	--) 
	    shift
	    break
    	    ;;
 esac
done

matrix_dir=${matrix%/*}
clin_dir=${clin%/*}
probe_dir=${probe_symbol%/*}
$singularity  exec --cleanenv \
        -B $script_dir:$script_dir \
        -B $matrix_dir:$matrix_dir \
        -B $clin_dir:$clin_dir \
        -B $probe_dir:$probe_dir \
        -B $res_dir:$res_dir \
        $script_dir/COGDAS.sif Rscript $script_dir/COGDAS.main.R --matrix_dir $matrix  --clin_dir $clin  --res_dir $res_dir  --seqdata_type $seqdata_type --to_fpkm $to_fpkm --transdata_type $transdata_type --pvalue $pvalue --logFC  $logFC --lowvalue $lowvalue --method $method --algorithm $algorithm --ref_fac $ref_fac  --probe_symbol $probe_symbol && \
if [ $JOB_ID ]; then echo "jobid=$JOB_ID" && qstat -j $JOB_ID | grep usage ; fi
echo ==========end at : `date "+%Y-%m-%d %H:%M:%S"` ==========   && \
echo "COGDAS program is done!!!"
exit 0
