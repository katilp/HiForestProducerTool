#!/bin/sh -l
sudo chown $USER /mnt/vol

# check the release area exist, and if not (in the case of the light-weight container), create it
DIR=$HOME/CMSSW_4_4_7
if [ -d "$DIR" ]; then
   echo "'$DIR' Release area exists"
   CVMFS_MOUNTED=false
else
   echo "Creating '$DIR'"
   CVMFS_MOUNTED=true
   scramv1 project CMSSW CMSSW_4_4_7
   cd CMSSW_4_4_7/src
   eval `scramv1 runtime -sh`
fi
mkdir HiForest
cd HiForest
# For the plain github action with docker, the repository is available in /mnt/vol
# git clone -b 2011 git://github.com/cms-legacy-analyses/HiForestProducerTool.git HiForestProducer
mkdir HiForestProducer
cd HiForestProducer
cp /mnt/vol/forest2dimuon.C .

cp /mnt/vol/*.root .
root -l -b forest2dimuon.C++

cp *.png /mnt/vol/
echo  ls -l /mnt/vol
ls -l /mnt/vol
