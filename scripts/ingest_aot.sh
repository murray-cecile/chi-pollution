# !usr/bin/bash

cd ~/chi-pollution/aot_data

# recent tiny slice of dataset
# wget http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.recent.csv

# one month of data: September 2019
# wget https://s3.amazonaws.com/aot-tarballs/chicago-complete.monthly.2019-09-01-to-2019-09-30.tar
# tar -xf chicago-complete.monthly.2019-09-01-to-2019-09-30.tar
# rm *.tar
# mv chicago-complete.monthly.2019-09-01-to-2019-09-30 chicago-2019-09


# get all the data in 2019
first_day=`date +"%Y-%m-%d" -d "01/01/2019"` 
end=`date +"%Y-%m-%d" -d "09/01/2019"`

while [ "$now" != "$end" ] ;
do 

    last_day=`date +"%Y-%m-%d" -d "$first_day + 1 month - 1 day"`;
    
    echo "beginning download for "$first_day " to " $last_day;
    echo  https://s3.amazonaws.com/aot-tarballs/chicago-complete.monthly.$first_day-to-$last_day.tar;
    wget  https://s3.amazonaws.com/aot-tarballs/chicago-complete.monthly.$first_day-to-$last_day.tar;
    
    echo "untarring...";
    tar -xf chicago-complete.monthly.$first_day-to-$last_day.tar;
    cd chicago-complete.monthly.$first_day-to-$last_day;
    mv data.csv.gz data-starting-$first_day.csv.gz;
    ls;
    rm *.tar;

    echo "putting data in HDFS...";
    hdfs dfs -put data-starting-$first_day.csv.gz /inputs/cmmurray/aot;
    cd ..;

    echo "deleting data on disk...";
    rm -r chicago-complete.monthly.$first_day-to-$last_day;

    # reset the loop
    first_day=`date +"%Y-%m-%d" -d "$first_day + 1 month"`; 
    
done
