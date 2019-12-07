# !usr/bin/bash

cd ~/chi-pollution/aot_data

# recent tiny slice of dataset
wget http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.recent.csv

# one month of data: September 2019
wget https://s3.amazonaws.com/aot-tarballs/chicago-complete.monthly.2019-09-01-to-2019-09-30.tar
tar -xf chicago-complete.monthly.2019-09-01-to-2019-09-30.tar
mv chicago-complete.monthly.2019-09-01-to-2019-09-30 chicago-2019-09

# all of the data - 31G tar (!)
wget http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.latest.tar