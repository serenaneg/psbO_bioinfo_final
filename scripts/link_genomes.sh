#!/bin/bash

nums=$(cut -f 1 /proj/omics/env-bio/2025/collaboration/hochroth_negroni_finalproj/data/med_surface_total.txt)


for filename in $nums; 
do     
	echo $filename
	link_path="/proj/omics/data/tara/PRJEB4352/$filename"

	if [[ -d "$link_path" ]]; then        
		ln -fs "$link_path" "$filename"    
	else        
		echo "Missing: $filename";     	
	fi; 
done
