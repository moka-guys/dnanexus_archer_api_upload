# dnanexus_archer_api_upload_v1.0.0
DNAnexus app to upload fastq files onto Archer and submit the job.

## How the app works?
Docker image "archer_api_upload" from https://github.com/moka-guys/archer_api_upload is used to run the app.

## Input
- DNAnexus project id where the fastq files are located (string)
- Archer password in Base64 Encoded format (string)
- Archer protocol id for the job (integer)

## Output
- logfile.txt - txt file containg the log for file uploading and job submission
- sample_log.json - json file containing the list of samples submitted for the job. 
In addition to the output files above, it is expected that the submitted job starts running on Archer job platform (https://analysis.archerdx.com/home#running_jobs)

## Running from the CLI:

The app can be run from the dx CLI. The example below shows the command line to be used:
```
dx run applet-xxx \
-iproject_id=project-xxxx \
-iarcher_password=<pw> \
-iprotocol_id=<id>
```

