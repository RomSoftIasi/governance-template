. ./scripts/.env




function configure_docker(){

echo "Authenticate on DOCKER-HUB repository"
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"

}

function create_jenkins_secret(){
echo 'Creating kubernetes secrets docker-config ...'

kubectl create namespace jenkins

kubectl create secret generic docker-config \
    --save-config --dry-run=client \
    --from-literal=docker_username="$DOCKER_USERNAME" \
    --from-literal=docker_password="$DOCKER_PASSWORD" \
    --from-literal=GITHUB_REPO_TOKEN="$GITHUB_REPO_TOKEN" \
    -o yaml |
  kubectl apply -n jenkins -f -

#uncomment to see the stored secret
#kubectl get secret -n jenkins aws-config -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
#kubectl get secret eth-adapter-config -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
echo 'Created kubernetes secrets docker-config.'
}



for i in "$@"
do
  case $i in
    --docker)
      configure_docker
      ;;
    --jenkins-secret)
      create_jenkins_secret
      ;;
  esac
done

exit 0
