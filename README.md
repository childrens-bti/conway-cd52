# Conway CD52 Project Repository

## To reproduce the code in this repository:
This repository contains a docker image and code used to conduct analyses.

1. Clone the repository
```
git clone git@github.com:childrens-bti/conway-cd52.git
```

2. Pull the docker container:
```
docker pull pgc-images.sbgenomics.com/childrens-bti/conway-cd52:latest
```
NOTE: if running on a Mac with Apple Silicon chip (M1-M4), please add `--platform linux/amd64`; otherwise add `--platform linux/arm64`

If the image is not available from a registry, build it locally from the repository root:
```bash
docker build -t pgc-images.sbgenomics.com/childrens-bti/conway-cd52:latest .
```

3. Start the docker container, from the `conway-cd52` folder, run:

```bash
# Local machine (RStudio)
docker run --platform linux/amd64 --name <CONTAINER_NAME> -d -e PASSWORD=ANYTHING -p 8787:8787 -v $PWD:/home/rstudio/conway-cd52 pgc-images.sbgenomics.com/childrens-bti/conway-cd52:latest

# EC2 (RStudio - port 80)
docker run --platform linux/amd64 --name <CONTAINER_NAME> -d -e PASSWORD=ANYTHING -p 80:8787 -v $PWD:/home/rstudio/conway-cd52 pgc-images.sbgenomics.com/childrens-bti/conway-cd52:latest
```

NOTE: if running on a Mac with Apple Silicon chip (M1-M4), use `--platform linux/amd64`

4. Access RStudio in your browser:

   **RStudio** (username: `rstudio`, password: `ANYTHING`):
   - Local: `http://localhost:8787`
   - EC2: `http://<ec2-private-ip>`

5. Download the data release, from the `conway-cd52` folder, run:
```bash
bash download_data.sh
```

6. To execute shell within the docker image, from the `conway-cd52` folder, run:
```
docker exec -ti <CONTAINER_NAME> bash
```

7. Navigate to an analysis module and run the shell script:
```
cd /home/rstudio/conway-cd52/analyses/conway-cd52
bash run_modules.sh
```

### Below is the level one directory structure listing the analyses and data files used in this repository

```
.
├── analyses
├── data
├── Dockerfile
├── docs
├── figures
├── LICENSE
├── README.md
├── download_data.sh
└── scripts
```

## Code Authors

Sam Chen ([@sychen9584](https://github.com/sychen9584))
