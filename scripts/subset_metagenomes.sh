# Scripts for subsetting the TARA database, based on depth, size fraction of phytoplankton and stations number

FOLDER_DATA="/vortexfs1/omics/data/tara/PRJEB4352/"
FILE_METADATA="/vortexfs1/omics/env-bio/2025/collaboration/hochroth_negroni_finalproj/data/tara_PRJEB4352_metadata.txt"

read -p "Enter target depth choosing between surface [_S_] and depth [_D_]: " DEPTH
read -p "Enter target organisms' size fraction. Options: W0.8-5, W5-20, N20-180, N180-2000: " SIZE
read -p "Enter target stations. Format _[numers]_: " STATIONS
read -p "Enter output file name: " OUTFILE

OUTPUT="/vortexfs1/omics/env-bio/2025/collaboration/hochroth_negroni_finalproj/data/$"OUTFILE""

#grep _S_ tara_PRJEB4352_metadata.txt  | grep -E W5-20 | grep -E _0[0-3][0-9]_
# _0[0-3][0-9]_ mediaterranean stations

count=$(cut -f 2 "$FILE_METADATA" | grep $"DEPTH" | grep -E $"SIZE"| grep -E $"STATIONS" | wc)

echo Number of sequence retrieved: "$count"

