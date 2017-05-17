def dummy
 goTemplate{
  dockerNode{
      goMake{
        githubOrganisation = 'ashetty1'
        dockerOrganisation = 'fabric8'
        project = 'kompose'
        makeCommand = "git version && git remote && export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/usr/local/glide:/usr/local/:/go/bin:/home/jenkins/go/bin && make test-openshift"
      }
  }
}
