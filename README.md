# demo-runner

# Configure

## Create secret

Export GCP service account token to a file:

`echo '<token>' > token.json`

Generate secret from the token file:

`kubectl create secret generic gcp-sa-token --from-file=./key.json`

`kubectl create secret generic github-token --from-literal=github-token=$GITHUB_TOKEN`

