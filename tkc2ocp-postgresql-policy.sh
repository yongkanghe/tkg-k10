# export MY_REGION=us-east-2
export MY_OBJECT_STORAGE_PROFILE=myaws3-migration

echo '------Create backup policies'
cat <<EOF | kubectl apply -f -
apiVersion: config.kio.kasten.io/v1alpha1
kind: Policy
metadata:
  name: tkc2ocp-postgresql-backup
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
        blockModeProfile:
          name: myaws3-migration
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
          - yong-postgresql
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
    name: tkc2ocp-postgresql-backup
    namespace: kasten-io
EOF
