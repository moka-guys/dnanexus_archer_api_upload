#!/bin/bash

set -e -x -o pipefail
main() {
# download all inputs
mark-section "Download all inputs"
dx-download-all-inputs --parallel

# get project name and folder name
project_name=$(dx describe $project_id --json | jq '.name')
folder_name=$(echo $project_name | sed 's/_[^_]*$//g')
folder_name=$(printf '%s\n' "${folder_name#*_}")

# create output folder
mkdir -p /home/dnanexus/out/archer_api_upload/archer_api_upload

# Location of the archer_api_upload docker file
docker_file_id=project-Gpp93y80b4Zk97Z3XpJPKz2j:file-Gqp0YGQ0b4ZV2gxJQ9b7yq3g #TODO replace project id after moving to 001

# find fastq files in given project and folder
if [[ "$specific_folder" ]]; then
    fastq=$(dx find data --name "*.fastq.gz" --project "$project_id" --folder /${specific_folder}/Data/Intensities/BaseCalls --brief)
elif [[ "$specific_path" ]]; then
    fastq=$(dx find data --name "*.fastq.gz" --project "$project_id" --folder /${specific_path} --brief)
else
    fastq=$(dx find data --name "*.fastq.gz" --project "$project_id" --folder /${folder_name}/Data/Intensities/BaseCalls --brief)
fi
# download fastq files except Undetermined fastq files
for fq in ${fastq[@]}; do
    fq_name=$(dx describe $fq --json | jq '.name')
    if [[ ! $fq_name == *Undetermined* ]]
    then 
        dx download $fq
    fi
done

# take folder name as job name if not specified
if [[ ! "$job_name" ]]; then
    job_name=$folder_name
fi
# download archer auth file
dx download project-Gpp93y80b4Zk97Z3XpJPKz2j:file-Gqp0YqQ0b4ZjK85GvYbGYYK6 # TODO replace the auth file when getting moka password

# download docker image
dx download $docker_file_id
docker_file=$(dx describe ${docker_file_id} --name)
DOCKERIMAGENAME=`tar xfO ${docker_file} manifest.json | sed -E 's/.*"RepoTags":\["?([^"]*)"?.*/\1/'`
docker load < /home/dnanexus/"${docker_file}"
echo $DOCKERIMAGENAME

# run docker
mark-section "Run archer_api_upload docker image"
docker run -v /home/dnanexus/:/home/dnanexus/ \
$DOCKERIMAGENAME /home/dnanexus /home/dnanexus/archer_authentication.txt \
${job_name} ${protocol_id} | tee -a "logfile.txt"

# check if the file uploading and job submission are successful
success=$(grep -o -P '(?<=success\":).*(?=,\"success)' logfile.txt |  sort | uniq)
echo $success
if [ "$success" != true ] ; then     
    echo "Errors in file uploading or job submission. Check logfile.txt for more details"    
    exit 1     
fi

# Upload output files
mv "logfile.txt" /home/dnanexus/out/archer_api_upload/archer_api_upload/
mv "sample_log.json" /home/dnanexus/out/archer_api_upload/archer_api_upload/
dx-upload-all-outputs
}
