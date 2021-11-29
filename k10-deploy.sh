echo '-------Deploying K10 on TKG running on AWS typically in mins)'
starttime=$(date +%s)
. setenv.sh

TKG_BUCKET_NAME=$MY_BUCKET-$(date +%s)
echo $TKG_BUCKET_NAME > tkg_bucketname
export AWS_ACCESS_KEY_ID=$(cat awsaccess | head -1)
export AWS_SECRET_ACCESS_KEY=$(cat awsaccess | tail -1)

tanzu cluster kubeconfig get $(cat tkg_wcluster_name) --admin

echo '-------Install K10'
kubectl create ns kasten-io
helm repo add kasten https://charts.kasten.io
helm install k10 kasten/k10 --namespace=kasten-io \
  --set global.persistence.metering.size=1Gi \
  --set prometheus.server.persistentVolume.size=1Gi \
  --set global.persistence.catalog.size=1Gi \
  --set global.persistence.jobs.size=1Gi \
  --set global.persistence.logging.size=1Gi \
  --set secrets.awsAccessKeyId="${AWS_ACCESS_KEY_ID}" \
  --set secrets.awsSecretAccessKey="${AWS_SECRET_ACCESS_KEY}" \
  --set auth.tokenAuth.enabled=true \
  --set externalGateway.create=true  
  
echo '-------Set the default ns to k10'
kubectl config set-context --current --namespace kasten-io

echo '-------Deploying a postgresql database'
kubectl create ns k10-postgresql
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install postgres bitnami/postgresql -n k10-postgresql --set persistence.size=1Gi

echo '-------Output the Cluster ID'
clusterid=$(kubectl get namespace default -ojsonpath="{.metadata.uid}{'\n'}")
echo "" | awk '{print $1}' > tkg-token
echo My Cluster ID is $clusterid >> tkg-token

echo '-------Creating a S3 profile secret'
kubectl create secret generic k10-s3-secret \
      --namespace kasten-io \
      --type secrets.kanister.io/aws \
      --from-literal=aws_access_key_id=$AWS_ACCESS_KEY_ID \
      --from-literal=aws_secret_access_key=$AWS_SECRET_ACCESS_KEY

echo '-------Wait for 1 or 2 mins for the Web UI IP and token'
kubectl wait --for=condition=ready --timeout=180s -n kasten-io pod -l component=jobs
k10ui=http://$(kubectl get svc gateway-ext | awk '{print $4}'|grep -v EXTERNAL)/k10/#
echo -e "\nCopy/Paste the link to browser to access K10 Web UI -->> $k10ui" >> tkg-token
echo "" | awk '{print $1}' >> tkg-token
sa_secret=$(kubectl get serviceaccount k10-k10 -o jsonpath="{.secrets[0].name}" --namespace kasten-io)
echo "Copy/Paste the token below to Signin K10 Web UI" >> tkg-token
echo "" | awk '{print $1}' >> tkg-token
kubectl get secret $sa_secret --namespace kasten-io -ojsonpath="{.data.token}{'\n'}" | base64 --decode | awk '{print $1}' >> tkg-token
echo "" | awk '{print $1}' >> tkg-token

echo '-------Waiting for K10 services are up running in about 1 or 2 mins'
kubectl wait --for=condition=ready --timeout=300s -n kasten-io pod -l component=catalog

echo '-------Creating a S3 profile'
cat <<EOF | kubectl apply -f -
apiVersion: config.kio.kasten.io/v1alpha1
kind: Profile
metadata:
  name: $MY_OBJECT_STORAGE_PROFILE
  namespace: kasten-io
spec:
  type: Location
  locationSpec:
    credential:
      secretType: AwsAccessKey
      secret:
        apiVersion: v1
        kind: Secret
        name: k10-s3-secret
        namespace: kasten-io
    type: ObjectStore
    objectStore:
      name: $(cat tkg_bucketname)
      objectStoreType: S3
      region: $MY_REGION
EOF

echo '------Create backup policies'
cat <<EOF | kubectl apply -f -
apiVersion: config.kio.kasten.io/v1alpha1
kind: Policy
metadata:
  name: k10-postgresql-backup
  namespace: kasten-io
spec:
  comment: ""
  frequency: "@hourly"
  actions:
    - action: backup
      backupParameters:
        profile:
          namespace: kasten-io
          name: $MY_OBJECT_STORAGE_PROFILE
    - action: export
      exportParameters:
        frequency: "@hourly"
        migrationToken:
          name: ""
          namespace: ""
        profile:
          name: $MY_OBJECT_STORAGE_PROFILE
          namespace: kasten-io
        receiveString: ""
        exportData:
          enabled: true
      retention:
        hourly: 0
        daily: 0
        weekly: 0
        monthly: 0
        yearly: 0
  retention:
    hourly: 4
    daily: 1
    weekly: 1
    monthly: 0
    yearly: 0
  selector:
    matchExpressions:
      - key: k10.kasten.io/appNamespace
        operator: In
        values:
          - k10-postgresql
EOF

sleep 3

echo '-------Kickoff the on-demand backup job'
sleep 2
cat <<EOF | kubectl create -f -
apiVersion: actions.kio.kasten.io/v1alpha1
kind: RunAction
metadata:
  generateName: run-backup-
spec:
  subject:
    kind: Policy
    name: k10-postgresql-backup
    namespace: kasten-io
EOF

echo '-------Accessing K10 UI'
cat tkg-token

endtime=$(date +%s)
duration=$(( $endtime - $starttime ))
echo "-------Total time is $(($duration / 60)) minutes $(($duration % 60)) seconds."
echo "" | awk '{print $1}'
echo "-------Created by Yongkang"
echo "-------Email me if any suggestions or issues he@yongkang.cloud"
echo "" | awk '{print $1}'
echo "" | awk '{print $1}'
