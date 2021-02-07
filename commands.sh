#!/bin/sh -l
# parameters: $1 number of events (default: 100), $2 configuration file (default: hiforestanalyzer_cfg.py)
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
cp -r /mnt/vol HiForestProducer
cd HiForestProducer

scram b -j8

if [ -z "$1" ]; then nev=100; else nev=$1; fi
if [ -z "$2" ]; then config=hiforestanalyzer_cfg.py; else config=$2; fi
# set the number of events
eventline=$(grep maxEvents $config)
sed -i "s/$eventline/process.maxEvents = cms.untracked.PSet( input = cms.untracked.int32($nev) )/g" $config
# remove the connection to cvmfs, for GT access from docker container without cvmfs mount 
if [ "$CVMFS_MOUNTED" = false ] ; then
   sed -i "s/process.GlobalTag.connect/#process.GlobalTag.connect/g" $config
fi
cmsRun $config

cp *.root /mnt/vol/
echo  ls -l /mnt/vol
ls -l /mnt/vol
