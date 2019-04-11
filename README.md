## RT\_end\_counter

### Purpose
This repository is associated with [the docker image](https://hub.docker.com/r/carushi/rt_end_counter/), which contains samtools, bedtools2, and RT end counter for high-throughput structure analyses such as icSHAPE, PARS, and DMS-seq.


### Example
You can choose one way from two ways shown below.
One is using a docker image in an interactive mode, and another is in a command line-like mode.
1. Analyze on a docker container

```
docker pull carushi/rt_end_counter
docker run --rm --name reactIDR -it carushi/rt_end_counter
```

```
docker cp host/directory/test.bam reactIDR:/docker/directory/
```

```
bash count_and_cov.sh /docker/directory/test.bam

bash count_and_cov.sh -q 10 /docker/directory/test.bam
# Reads whose quality is less than 10 are filtered out.

bash count_and_cov.sh -l 100 /docker/directory/test.bam
# Reads whose length is less than 100 are remanied.

bash count_and_cov.sh -k /docker/directory/test.bam
# Keeps temporary files for debug.

```

* Check the result!

```
less test_ctss.bed
# RT end count
less test_cov.bed
# Coverage count
```

2. Use a docker container as a command line tool

```
docker pull carushi/rt_end_counter
docker run --rm -v /host/directory:/test_data carushi/rt_end_counter count_and_cov.sh -q 10 /test_data/test.bam
```

@ 2017 carushi
