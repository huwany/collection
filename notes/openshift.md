# openshift deployment
- [ ] TBD

# openshift with jenkins:

* update master config
```
cat << EOF >> /etc/origin/master/master-config.yaml
jenkinsPipelineConfig:
autoProvisionEnabled: false
templateNamespace: openshift
templateName: jenkins-persistent
serviceName: jenkins
EOF
```
* restart master (on all master)
```
/usr/local/bin/master-restart api
/usr/local/bin/master-restart controllers
```
* update jenkins-persistent template
```
oc -n openshift edit template jenkins-persistent
...
spec:
    securityContext:
    fsGroup: 1000
...
```
    
* create project
```bash
oc new-project ci
```
* assign scc to project
```bash
oc adm policy add-scc-to-group anyuid system:authenticated
oc adm policy add-scc-to-group privileged system:authenticated
```
* assign role to user
```bash
oc adm policy add-cluster-role-to-user cluster-admin -z jenkins
```
* assign role to user
```bash
oc policy add-role-to-group view system:authenticated
oc policy add-role-to-user admin admin
```

* create ceph client secret
```bash
cat << EOF | oc apply -f -
apiVersion: v1
type: kubernetes.io/rbd
kind: Secret
metadata:
    name: ceph-kube
data:
    key: QVFDeVZ6RmRnTVFwSlJBQU5yYi94cWZPYks2NTd5WjZMUWk5RlE9PQ==
EOF
```

* create jenkins master
```bash
oc new-app \
    -e OPENSHIFT_JENKINS_JVM_ARCH=x86_64 \
    -e GIT_SSL_NO_VERIFY=true \
    -p MEMORY_LIMIT=2Gi \
    -p VOLUME_CAPACITY=10Gi \
    jenkins-persistent
```

* update jenkins login url
```bash
oc patch route jenkins -p '{"spec": {"host": "jenkins.beta.cn"}}'
oc annotate route jenkins --overwrite haproxy.router.openshift.io/timeout=180s
```

* restart jenkins
```bash
oc delete pod -l name=jenkins
```
``or elegant way:`` 
```bash
oc scale --replicas=0 deploymentconfig jenkins
oc scale --replicas=1 deploymentconfig jenkins
```

* clean up jenkins
```bash
oc delete all --all
oc delete sa jenkins
oc delete rolebinding jenkins_edit
oc delete pvc jenkins
oc delete project ci
```
