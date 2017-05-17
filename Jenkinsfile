#!/usr/bin/groovy

@Library('github.com/rupalibehera/fabric8-pipeline-library@kompose-pr-build')
def dummy
 goTemplate{
  dockerNode{
      goMake{
        githubOrganisation = 'ashetty1'
	dockerOrganisation = 'fabric8'
        project = 'kompose'
	installPreRequsites = "curl -L https://github.com/kubernetes-incubator/kompose/releases/download/v0.6.0/kompose-linux-amd64 -o /usr/bin/kompose && chmod +x /usr/bin/kompose && curl -L https://github.com/fabric8io/gofabric8/releases/download/v0.4.123/gofabric8-linux-amd64 -o /usr/bin/oc && chmod +x /usr/bin/oc"
        makeCommand = "git version && git remote && export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/usr/local/glide:/usr/local/:/go/bin:/home/jenkins/go/bin && make test-openshift"
      }
  }
}

