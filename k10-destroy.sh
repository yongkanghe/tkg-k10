starttime=$(date +%s)
. setenv.sh
echo '-------Deleting Kasten K10 and Postgresql from TKGm on AWS'
kubectl get namespace default -ojsonpath="{.metadata.uid}{'\n'}" > clusterid

export AWS_ACCESS_KEY_ID=$(cat awsaccess | head -1)
export AWS_SECRET_ACCESS_KEY=$(cat awsaccess | tail -1)

helm uninstall k10 -n kasten-io
kubectl delete ns kasten-io
helm uninstall postgres -n k10-postgresql
kubectl delete ns k10-postgresql

echo '-------Delete the Tanzu WC kubeconfig'
kubectl config delete-context $(kubectl config get-contexts -o name | grep $(cat tkg_wcluster_name))

echo '-------Deleting EBS Volumes'
aws ec2 describe-volumes --region $MY_REGION --query "Volumes[*].{ID:VolumeId}" --filters Name=tag:kubernetes.io/cluster/$(cat tkg_wcluster_name),Values=owned | grep ID | awk '{print $2}' > ebs.list
cat ebs.list
aws ec2 describe-volumes --region $MY_REGION --query "Volumes[*].{ID:VolumeId}" --filters Name=tag:kubernetes.io/created-for/pvc/namespace,Values=kasten-io | grep ID | awk '{print $2}' >> ebs.list
cat ebs.list
aws ec2 describe-volumes --region $MY_REGION --query "Volumes[*].{ID:VolumeId}" --filters Name=tag:kubernetes.io/created-for/pvc/namespace,Values=k10-postgresql | grep ID | awk '{print $2}' >> ebs.list
cat ebs.list
for i in $(sed 's/\"//g' ebs.list);do echo $i;aws ec2 delete-volume --volume-id $i;done

echo '-------Deleting snapshots'
aws ec2 describe-snapshots --owner self --query "Snapshots[*].{ID:SnapshotId}" --filters Name=tag:kanister.io/clustername,Values=$(cat clusterid) | grep ID | awk '{print $2}' > ebssnap.list
for i in $(sed 's/\"//g' ebssnap.list);do echo $i;aws ec2 delete-snapshot --snapshot-id $i;done

echo '-------Deleting objects from the bucket'
aws s3 rb s3://$(cat tkg_bucketname) --force

endtime=$(date +%s)
duration=$(( $endtime - $starttime ))
echo "-------Total time is $(($duration / 60)) minutes $(($duration % 60)) seconds."
echo "" | awk '{print $1}'
echo "-------Created by Yongkang"
echo "-------Email me if any suggestions or issues he@yongkang.cloud"
echo "" | awk '{print $1}'
echo "" | awk '{print $1}'
