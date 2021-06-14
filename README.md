# A Carvel demo

> A simple Spring Boot application that gets packaged for k8s with the [Carvel](https://carvel.dev) toolsuite

## Installation

Assuming you have a local k8s cluster with an Ingress Controller configured, deploy and test with:

```shell
impkg pull --bundle mamachanko/carvel-demo-bundle --output carvel-demo

ytt `# render the template` \
  --file "carvel-demo/k8s.yml" \
  --file "carvel-demo/values.yml" \
  | kbld `# resolve the image references` \
    --file - \
    --file "carvel-demo/.imgpkg/images.yml" \
    | kapp deploy `# apply to cluster`\
      --diff-changes \
      --app "carvel-demo" \
      --file -

curl -iv localhost
```

Check `values.yml` for configuration options.

## The pipeline

### Inputs
1. tag to build with (defaults to [gitCommit](https://skaffold.dev/docs/pipeline-stages/taggers/#gitcommit-uses-git-commitsreferences-as-tags))
2. promotion tag (defaults to `latest`)

### Outputs
 * An [imgpkg](https://carvel.dev/imgpkg) bundle image: https://hub.docker.com/repository/docker/mamachanko/carvel-demo-bundle
 * A runnable app image: https://hub.docker.com/repository/docker/mamachanko/carvel-demo-app


### Steps
1. Build and push
   * builds and pushes the docker image with _tag_ by using `kbld`
   * pushes a bundle with _tag_ containing k8s manifests and a reference to the docker image with `imgpkg`
3. Consume
   * pulls the bundle with _tag_ by using `imgpkg`
4. Test
   * renders the k8s manifests with `ytt`
   * resolve the image to the one reference in `.imgpk/images.yaml` with `kbld`
   * deploys with `kapp`
   * tests the deployment
6. Promote
   * pushes the bundle with tag `latest`
   * `*-dirty` tags cannot be promoted


### Try for yourself
```shell
./pipeline.sh [tag=$gitCommit] [promotionTag=latest]
```
Uses [gitCommit](https://skaffold.dev/docs/pipeline-stages/taggers/#gitcommit-uses-git-commitsreferences-as-tags) as a default tag strategy.

For example:
```shell
# Git commit is abcdef and workspace is clean
./pipeline.sh
# same as
./pipeline.sh abcdef latest

# Git commit is abcdef and workspace is dirty
./pipeline.sh
# same as
./pipeline.sh abcdef-dirty latest

# Go wild
./pipeline.sh this-is-a-just-test omg-version-1
```
