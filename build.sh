if [ "$1" = '' ]
then
  echo ''
  echo '--help for commands and flags details'
  echo ''
  exit 0
fi

if [ "$1" = '--help' ]
then
  echo ''
  echo 'Utility shell in order to help deploying Jenkins and Governance'
  echo 'Shell will be executed relative to the Governance workspace directory'
  echo 'All customizations will be done in the already existing files from ./jenkins/modules directory and will be integrated in current execution automatically'
  echo 'Please review and customize as needed the ENVIRONMENT VARIABLES defined in ./jenkins/modules/scripts/.env'
  echo ''
  echo 'Help for build.sh'
  echo ''
  echo '--env-legend            Show greater descriptions for the defined environment variables '
  echo 'docker                  Creates the docker-config secret in order to be used by Jenkins docker pipelines and executes the docker login in order to push docker images'
  echo '--build-all             Build and push docker images for Governance and Jenkins agents '
  echo '--deploy-all            Deploy Jenkins and Governance '
  echo '--clean-all             Remove Jenkins and Governance installations'
  echo '--cbd-gov               Clean,build and deploy the Governance'
  echo ''
  exit 0
fi

if [ "$1" == '--env-legend' ]
then
  echo ''
  echo 'ENVIRONMENT VARIABLES - LEGEND'
  echo ''
  echo 'DOCKER_USERNAME : docker username'
  echo 'DOCKER_PASSWORD : docker password'
  echo 'POD_DOCKER_REPOSITORY : The docker repository where all the docker images will be uploaded and from where will be used'
  echo ''
  echo 'GOV_CONTAINER_NAME : Governance deployment name'
  echo 'GOV_APP_NAME : Governance container label name'
  echo 'GOV_DOCKER_IMAGE : Governance docker image name'
  echo 'GOV_DOCKER_IMAGE_VERSION : Governance docker image version. Currently is coded to gather the latest commit number and use it as a version'
  echo ''
  echo 'KUBECTL_JENKINS_DOCKER_IMAGE : The docker image name for the jenkins agent that require kubectl installed'
  echo 'KUBECTL_JENKINS_DOCKER_IMAGE_VERSION : The version for the jenkins agent with kubectl. Static value. Image is build only once when the Jenkins is deployed.'
  echo ''
  echo 'DOCKER_AWS_JENKINS_DOCKER_IMAGE : The docker image for the Jenkins agent that is responsible with building docker images and pushing them to the repository'
  echo 'DOCKER_AWS_JENKINS_DOCKER_IMAGE_VERSION : The version for the jenkins agent with docker and repository access. Static value. Image is build when Jenkins is deployed.'
  echo ''
  echo ''
  exit 0
fi

./scripts/clone-gov.sh

if [ "$1" = 'docker' ]
then
  ./scripts/configure_docker.sh --docker --jenkins-secret
else
  echo 'WARNING: docker command was not used. The rest of the operations will be done assuming the docker login was executed and the jenkins secret will be created after the Jenkins is deployed and before using any pipelines '
  echo ''
fi

for i in "$@"
do
  case $i in
    --build-all)
      cd governance-workspace || return
      ./scripts/gov/build-gov.sh
      ./scripts/jenkins/build-jenkins-agents.sh
      cd ..
      ;;
    --deploy-all)
      cd governance-workspace || return
      ./scripts/gov/deploy-gov.sh
      ./scripts/jenkins/deploy-jenkins.sh
      cd ..
      ;;
    --clean-all)
      cd governance-workspace || return
      ./scripts/gov/clean-gov.sh
      ./scripts/jenkins/clean-jenkins.sh
      cd ..
      ;;
    --cbd-gov)
      cd governance-workspace || return
      ./scripts/gov/clean-gov.sh
      ./scripts/gov/build-gov.sh
      sleep 1m
      ./scripts/gov/deploy-gov.sh
      cd ..
      ;;
  esac
done


./scripts/clean-gov-clone.sh


