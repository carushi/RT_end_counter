## RT\_end\_counter

### Purpose
This repository is to construct Docker image which contains samtools, bedtools2, and RT end counter for high-throughput structure analyses such as icSHAPE, PARS, and DMS-seq.


### Example

```
docker pull carushi/rt_end_counter
```

```
docker run -it carushi/rt_end_counter /bin/bash
```

```
docker cp host/directory/test.bam container_id(e.g.aabbcc112233):/docker/directory/
```
```
bash count_and_cov.sh /docker/directory/test.bam

bash count_and_cov.sh -q 10 /docker/directory/test.bam
# Reads whose quality is less than 10 are filtered.

count_and_cov.sh -k /docker/directory/test.bam
# Keeps temporary files for debug.

```

```
less test_ctss.bed
# RT end count
less test_cov.bed
# Coverage count
```

@ 2017 carushi
