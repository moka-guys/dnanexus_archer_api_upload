# dnanexus_archer_api_upload_v1.0.0
DNAnexus app to upload fastq files onto Archer and submit the job for downstream analysis.

## How the app works?
Docker image "archer_api_upload" from https://github.com/moka-guys/archer_api_upload is used to run the app.

## Input
- DNAnexus project id where the fastq files are located (string)
- Archer protocol id for the job (integer) - optional
- folder name (string) -optional to provide if the DNAnexus folder name does not follow the usual format. The usual folder name takes the DNAnexus project name between first and last underscore. 
For example, if the name of DNAnexus project is 002_240823_NB552085_0333_AHGLY5AFX7_ADX24030, the usual folder name is 240823_NB552085_0333_AHGLY5AFX7.
- file path (string) - optional to provide if the fastq files are not located in the unusual path. The usual path is <folder_name>/Data/Intensities/BaseCalls
- job name (string) - optional to provide if want to specify. Default job name is folder name in DNAnexus (e.g.240823_NB552085_0333_AHGLY5AFX7)

## Output
- logfile.txt - txt file containg the log for file uploading and job submission
- sample_log.json - json file containing the list of samples submitted for the job. 
In addition to the output files above, it is expected that the submitted job starts running on Archer job platform (https://analysis.archerdx.com/home#running_jobs)

## Running from the CLI:

The app can be run from the dx CLI. The example below shows the command line to be used:
```
dx run applet-xxx \
-iproject_id=project-xxxx
```

