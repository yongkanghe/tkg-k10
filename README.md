#### Follow [@YongkangHe](https://twitter.com/yongkanghe) on Twitter, Subscribe [K8s Data Management](https://www.youtube.com/channel/UCm-sw1b23K-scoVSCDo30YQ?sub_confirmation=1) Youtube Channel

I just want to build a VMware Tanzu Kubernetes Grid Cluster to learn the various Data Management capabilities e.g. Backup/Restore, Disaster Recovery and Application Mobility. It is challenging to create a Tanzu cluster if you are not familiar to it. After the cluster is up running, you still need to install Kasten, create a sample DB, create policies etc.. The whole process is not that simple.

![image](https://cdn2.hubspot.net/hub/3855032/hubfs/Kasten_January2020/Images/kasten_and_tanzu_logos%20%281%29.png?width=720&name=kasten_and_tanzu_logos%20%281%29.png)

This script based automation allows you to protect containers on a running TKGm cluster on AWS Cloud in ~3 minutes. If you don't have a VMware TKGm cluster, you can watch the Youtube video and follow the guide to build a TKGm cluster on AWS Cloud. Once the TKGm cluster is up running, you can proceed to the next steps. 

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/WglSH-GZQ1I/0.jpg)](https://www.youtube.com/watch?v=WglSH-GZQ1I)
#### Subscribe [K8s Data Management](https://www.youtube.com/channel/UCm-sw1b23K-scoVSCDo30YQ?sub_confirmation=1) Youtube Channel

# Here're the prerequisities. 
1. Log in to the terminal where you can access the TKGm Cluster via Kubectl
2. Clone the github repo to your local host, run below command
````
git clone https://github.com/yongkanghe/tkg-k10.git
````
3. Complete the preparation tasks first, set the worker cluster name
````
cd tkg-k10;./vmwprep.sh
````
4. Optionally to customize region, bucketname, object storage profile etc.
````
vim setenv.sh
````
 
# To build the labs, run 
````
./k10-deploy.sh
````
1. Install Kasten K10
2. Deploy a Postgresql database
3. Create a AWS S3 location profile
4. Create a backup policy
5. Run an on-demand backup job

# To delete the labs, run 
````
./k10-destroy.sh
````
1. Remove Postgresql Database
2. Remove Kasten K10
3. Remove all the relevant disks
4. Remove all the relevant snapshots
5. Remove the objects from the bucket

# 3 minutes to protect containers on TKGm Cluster
[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/s9f8O7zs_QI/0.jpg)](https://www.youtube.com/watch?v=s9f8O7zs_QI)
#### Subscribe [K8s Data Management](https://www.youtube.com/channel/UCm-sw1b23K-scoVSCDo30YQ?sub_confirmation=1) Youtube Channel

# VMware + Kasten Data Management for Kubernetes
https://blog.kasten.io/vmware-kasten-data-management-for-kubernetes-modern-applications

# Kasten - No. 1 Kubernetes Backup
https://kasten.io 

# Free Kubernetes Learning
https://learning.kasten.io 

# Kasten - DevOps tool of the month July 2021
http://k10.yongkang.cloud

# Contributors

#### Follow [Yongkang He](http://yongkang.cloud) on LinkedIn, Join [Kubernetes Data Management](https://www.linkedin.com/groups/13983251) LinkedIn Group




