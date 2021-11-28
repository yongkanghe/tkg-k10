starttime=$(date +%s)
. setenv.sh
echo '-------Deleting Kasten K10 and Postgresql from TKGm on AWS'
kubectl get namespace default -ojsonpath="{.metadata.uid}{'\n'}" > clusterid

export AWS_ACCESS_KEY_ID=$(cat awsaccess | head -1)
export AWS_SECRET_ACCESS_KEY=$(cat awsaccess | tail -1)

helm uninstall k10 -n kasten-io
kubectl delete ns kasten-io
helm uninstall postgres -n postgresql
kubectl delete ns postgresql

endtime=$(date +%s)
duration=$(( $endtime - $starttime ))
echo "-------Total time is $(($duration / 60)) minutes $(($duration % 60)) seconds."
echo "" | awk '{print $1}'
echo "-------Created by Yongkang"
echo "-------Email me if any suggestions or issues he@yongkang.cloud"
echo "" | awk '{print $1}'
echo "" | awk '{print $1}'
