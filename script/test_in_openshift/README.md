# Functional tests for Kompose on OpenShift

## Introduction

The functional tests for Kompose on OpenShift cluster leverages  oc cluster up` to bring a single-cluster OpenShift instance. The test scripts
are hosted under script/test_in_openshift. The directory structure is as below:

        script/test_in_openshift/
        ├── compose-files
        │   └── docker-compose-command.yml
        ├── lib.sh
        ├── run.sh
        └── tests
                ├── buildconfig.sh
                ├── entrypoint-command.sh
                ├── etherpad.sh
                └── redis-replica-2.sh
                └── ..

- [run.sh](/script/test_in_openshift/run.sh) is the master script
  which executes all the tests
