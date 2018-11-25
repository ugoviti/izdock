#!/bin/bash
# automatic container build and upload script
# written by Ugo Viti <ugo.viti@initzero.it>

container="$1"
shift
vars_file="$1"

docker_init() {
[ -z "$container" ] && echo "ERROR: undefined container name" && exit 1
[ ! -e "$container" ] && echo "ERROR: the container directory doesn't exist: $container" && exit 1
[ -z "$vars_file" ] && vars_file=$(realpath $container/vars) || vars_file="$(realpath $vars_file)"

set -x

# change the working directory to container directory
cd "$container"

# import container variables to manage tags variables
source $vars_file

[ -z "$build" ] && build=1 || let build+=1
# update build version
#add_replace_line "$vars_file" "build=" "build=$build"
add_replace_line "$(realpath vars)" "build=" "build=$build"

# import common variables
source $PWD/../vars

# override with container variables
[ -z "$repo_gcloud" ] && echo "ERROR: undefined google cloud repository" && exit 1
[ -z "$repo_docker" ] && echo "ERROR: undefined docker repository" && exit 1

# reimport container variables to override common variables
source $vars_file

set +x


# verifico se è avviato il servizio docker
if ! systemctl status docker >/dev/null; then sudo systemctl start docker ; fi
}

docker_build() {

# update Dockerfile version
sed "s/^ENV APP_VER.*/ENV APP_VER \"${tag_prefix}${tag_ver}${tag_suffix}-${build}\"/" -i Dockerfile

# build
if [ ! -z "$args" ]; then
  for v in $args ; do
	  arg+=" --build-arg $v "
  done
fi

if [ ! -z "$tags" ]; then
   [ $upload_gcloud = 1 ] && repo="$repo_gcloud/"
   [ $upload_docker = 1 ] && repo="$repo_docker/"
   for tag in $tags ; do 
     imagetags+=" -t ${repo}${container}:${tag}"
    done
fi

set -x

# build and apply tags
docker build -t ${repo}${container} ${imagetags} ${arg} .
retval=$?
set +x
[ $retval != 0 ] && exit 1

# remove the latest tag if not wanted
[ "${tag_latest}" != "yes" ] && docker rmi ${repo}${container}:latest

[ "$upload_docker" = 1 ] && upload_container
[ "$upload_gcloud" = 1 ] && upload_container

remove_tags
}


upload_container() {
  set -xe
  # upload latest version to docker
  [ "$upload_docker" = 1 ] && docker push $repo_docker/$container
  [ "$upload_gcloud" = 1 ] && gcloud docker -- push gcr.io/$repo_gcloud/$container
  set +xe
}

remove_tags() {
  #set -xe
  # remove local tags
  if [ ! -z "$tags" ]; then
   for tag in $tags ; do 
    #docker rmi $repo$container:$tag
    # remove all tags with build number
    [ ! -z "$(echo ${tag} | grep -- "-${build}")" ] && docker rmi ${repo}${container}:${tag}
   done
  fi
  set +xe
}

docker_report() {
  echo
  echo "==================================================="
  echo "=> Finished building the following images and tags:"

  #echo "$repo/$container:$build"

  if [ ! -z "$tags" ]; then
   for tag in $tags ; do
    echo $repo/$container:$tag
   done
   echo
  fi
}

add_replace_line() {
 file="$1"
 shift
 match="$1"
 match_sed="$(echo $match | sed 's/\//\\\//g')"
 shift
 string="$@"
 string_sed="$(echo $string | sed 's/\//\\\//g')"

 grep -q "^$match" $file && sed -i "s/^$match_sed.*/$string_sed/" $file || echo "$string" >> $file
}

set -x

#[ "$vars_file" = "all" ] && for vars_file in $container/vars.* ; do echo docker_init ; done || docker_init
docker_init
docker_build

# remove local copy
set +x

# make a report of built tags
[ "$upload_docker" = 1 ] && repo=$repo_docker && docker_report
[ "$upload_gcloud" = 1 ] && repo=gcr.io/$repo_gcloud && docker_report

# cleanup lost resources
#docker ps -q -a | xargs docker rm ; docker rmi $(docker images | grep "<none>" | awk '{print $3}')

