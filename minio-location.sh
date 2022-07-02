echo '-------Creating a S3 profile secret'
. ./setenv.sh

export AWS_ACCESS_KEY_ID=$(cat minioaccess | head -1)
export AWS_SECRET_ACCESS_KEY=$(cat minioaccess | tail -1)

kubectl create secret generic k10-s3-secret \
      --namespace kasten-io \
      --type secrets.kanister.io/aws \
      --from-literal=aws_access_key_id=$AWS_ACCESS_KEY_ID \
      --from-literal=aws_secret_access_key=$AWS_SECRET_ACCESS_KEY

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
      name: $MY_BUCKET
      objectStoreType: S3
      region: $MY_REGION
      endpoint: 10.10.1.221:9000
      skipSSLVerify: true
EOF

