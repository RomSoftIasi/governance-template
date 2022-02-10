//Jenkins env variable
//$POD_DOCKER_REPOSITORY
//$DOCKER_AWS_JENKINS_DOCKER_IMAGE
//$DOCKER_AWS_JENKINS_DOCKER_IMAGE_VERSION


//Pipeline parameters coded at Jenkins pipeline level
// dockerfile - base64 small file
// DATA_IMAGE_NAME - string
// DATA_IMAGE_VERSION - string

def docker_image_source = "$POD_DOCKER_REPOSITORY"+'/'+"$DOCKER_AWS_JENKINS_DOCKER_IMAGE"+':'+"$DOCKER_AWS_JENKINS_DOCKER_IMAGE_VERSION"

podTemplate(
    containers: [
        containerTemplate(name: 'docker', image: docker_image_source, alwaysPullImage:false , ttyEnabled: true, command: 'cat')
    ],
    volumes: [hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')],
    envVars: [secretEnvVar(key: 'DOCKER_USERNAME', secretName: 'docker-config', secretKey: 'docker_username'),
              secretEnvVar(key: 'DOCKER_PASSWORD', secretName: 'docker-config', secretKey: 'docker_password'),
              secretEnvVar(key: 'GITHUB_REPO_TOKEN', secretName: 'docker-config', secretKey: 'GITHUB_REPO_TOKEN')
             ]
  ){

              node(POD_LABEL){

                  stage ('Build and publish docker Image'){
                            container ('docker'){
                                sh 'docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD} '
                                    withFileParameter('dockerfile'){
                                        sh 'cat $dockerfile > Dockerfile'
                                        sh 'docker build --no-cache --build-arg GHCODE=${GITHUB_REPO_TOKEN} --network host -t ${POD_DOCKER_REPOSITORY}/${DATA_IMAGE_NAME}:${DATA_IMAGE_VERSION} .'
                                        sh 'docker push ${POD_DOCKER_REPOSITORY}/${DATA_IMAGE_NAME}:${DATA_IMAGE_VERSION}'

                                    }



                            }
                        }

              }






  }
