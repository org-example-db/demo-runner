# demo-runner

# Configure

## Create secret

Export GCP service account token to a file:

`echo '<token>' > token.json`

Generate secret from the token file:

`kubectl create secret generic gcp-sa-token --from-file=./token.json`

`kubectl create secret generic github-token --from-file=./token.json --from-literal=<github-token>`

