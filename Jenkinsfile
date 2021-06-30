pipeline {
  agent { label 'master'}
  	environment {
	    PATH = "/opt/apache-maven-3.6.3/bin:$PATH"
	}
  stages{
	stage('clone'){
		steps {
		  git credentialsId: 'bd8fc50a-b5d9-40de-bb2b-fb58e8af5ad4', url: 'https://github.com/naveenik/hello_world.git'
		}
	}	
    stage("Build")
		steps{
          sh "${mavenHome}/bin/mvn clean package"
             }
    stage("DeployAppTomcat Server")
        steps{
           sshagent(['423b5b58-c0a3-42aa-af6e-f0affe1bad0c'])
		     {
             sh "scp -o StrictHostKeyChecking=no target/hello_world.war  ec2-user@ip-address{tomcat-server}:/opt/apache-tomcat-9.0.34/webapps/" 
             }
             }
        }
}

