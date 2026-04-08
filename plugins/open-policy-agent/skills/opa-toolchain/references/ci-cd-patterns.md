# CI/CD Integration Patterns

## GitHub Actions

### Complete OPA Pipeline

```yaml
name: OPA Policy CI
on: [push, pull_request]

jobs:
  opa-checks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup OPA
        uses: open-policy-agent/setup-opa@v2
        with:
          version: latest

      - name: Setup Regal
        uses: styrainc/setup-regal@v2

      - name: Check Syntax
        run: opa check --strict ./policies/

      - name: Lint with Regal
        run: regal lint ./policies/

      - name: Format Check
        run: |
          opa fmt -l ./policies/
          if [ $? -ne 0 ]; then
            echo "Files need formatting. Run: opa fmt -w ./policies/"
            exit 1
          fi

      - name: Run Tests
        run: opa test ./policies/ -v --coverage --threshold 80

      - name: Build Bundle
        run: opa build -b ./policies/ -o bundle.tar.gz

      - name: Upload Bundle
        uses: actions/upload-artifact@v4
        with:
          name: opa-bundle
          path: bundle.tar.gz
```

### Terraform Plan Gate

```yaml
name: Terraform Policy Check
on:
  pull_request:
    paths: ['terraform/**']

jobs:
  policy-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Setup OPA
        uses: open-policy-agent/setup-opa@v2

      - name: Terraform Plan
        run: |
          cd terraform/
          terraform init
          terraform plan -out=tfplan
          terraform show -json tfplan > tfplan.json

      - name: Install Conftest
        run: |
          LATEST=$(curl -s https://api.github.com/repos/open-policy-agent/conftest/releases/latest | jq -r .tag_name)
          curl -LO "https://github.com/open-policy-agent/conftest/releases/download/${LATEST}/conftest_${LATEST#v}_Linux_x86_64.tar.gz"
          tar xzf conftest_*.tar.gz
          sudo mv conftest /usr/local/bin/

      - name: Policy Check
        run: conftest test terraform/tfplan.json -p policy/terraform/ --output github
```

### Kubernetes Manifest Gate

```yaml
name: K8s Policy Check
on:
  pull_request:
    paths: ['k8s/**', 'helm/**']

jobs:
  policy-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Conftest
        run: |
          curl -LO https://github.com/open-policy-agent/conftest/releases/latest/download/conftest_Linux_x86_64.tar.gz
          tar xzf conftest_*.tar.gz && sudo mv conftest /usr/local/bin/

      - name: Check K8s Manifests
        run: conftest test k8s/*.yaml -p policy/kubernetes/

      - name: Check Helm Output
        run: |
          helm template my-release ./helm/chart | conftest test - -p policy/kubernetes/
```

## GitLab CI

```yaml
stages:
  - lint
  - test
  - build

opa-lint:
  stage: lint
  image: openpolicyagent/opa:latest
  script:
    - opa check --strict ./policies/
    - opa fmt -l ./policies/

opa-test:
  stage: test
  image: openpolicyagent/opa:latest
  script:
    - opa test ./policies/ -v --coverage --threshold 80 --format=json > test-results.json
  artifacts:
    reports:
      junit: test-results.json

opa-build:
  stage: build
  image: openpolicyagent/opa:latest
  script:
    - opa build -b ./policies/ -o bundle.tar.gz
  artifacts:
    paths:
      - bundle.tar.gz
```

## Jenkins

```groovy
pipeline {
    agent any
    stages {
        stage('OPA Checks') {
            steps {
                sh 'opa check --strict ./policies/'
                sh 'regal lint ./policies/'
                sh 'opa test ./policies/ -v --coverage --threshold 80'
            }
        }
        stage('Build Bundle') {
            steps {
                sh 'opa build -b ./policies/ -o bundle.tar.gz'
                archiveArtifacts artifacts: 'bundle.tar.gz'
            }
        }
    }
}
```

## ArgoCD Integration

### Pre-sync Hook with Conftest

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: policy-check
  annotations:
    argocd.argoproj.io/hook: PreSync
spec:
  template:
    spec:
      containers:
        - name: conftest
          image: openpolicyagent/conftest:latest
          command: ["conftest", "test", "/manifests/", "-p", "/policy/"]
          volumeMounts:
            - name: manifests
              mountPath: /manifests
            - name: policy
              mountPath: /policy
      restorePolicy: Never
```

## Bundle Deployment Pipeline

```yaml
# Build and publish bundle to OCI registry
- name: Build and Push Bundle
  run: |
    opa build -b ./policies/ -o bundle.tar.gz
    oras push ghcr.io/${{ github.repository }}/policy:${{ github.sha }} \
      bundle.tar.gz:application/vnd.oci.image.layer.v1.tar+gzip
    oras tag ghcr.io/${{ github.repository }}/policy:${{ github.sha }} latest
```
