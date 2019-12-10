#!/bin/sh

BRANCH=testing
TIMEOUT=${TIMEOUT:-3600}
# You can change the timemout setting the TIMEOUT in the environment

show_processing()
{
  pid="${1}"
  delay='300'
  SECONDS=0
  printf "Building process ."
  while ps a | awk '{print $1}' | grep -q "${pid}"; do
	printf "."
	sleep ${delay}
	if [[ "${SECONDS}" -gt "${TIMEOUT}" ]]; then
		kill -9 ${pid}
		break
	fi
	SECONDS=$((SECONDS + delay))
  done
}

: Update-Upgrade section
sudo apk update; sudo apk upgrade
sudo apk add rsync
cd ~/aports  && git pull --update

: Pre-cleaning setup
rm -rf /var/cache/distfiles/*
rm -rf ~/packages/*/ppc64le/*

trashes=$(sudo apk info -v | grep depend | \
	sed -e "s;.makedepends-\(.*\)-$(date +%Y).*;\1;g")

for t in ${trashes}; do
	(cd ~/aports/main/$t &&  abuild clean; abuild undeps)
	(cd ~/aports/community/$t &&  abuild clean; abuild undeps)
	(cd ~/aports/testing/$t &&  abuild clean; abuild undeps)
done

: Listing projects
cd ~/aports/${BRANCH}/
: Clean up filelist of projects.
rm ~/filelist
while(true); do
	ls -1d ${1}* 2>/dev/null | awk '{ print $1 }' >> ~/filelist

	shift
	[ -n "$1" ] || break
done


: Create build_logs folders empty
[ -e "~/build_logs/" ] && rm -rf ~/build_logs/
mkdir -p ~/build_logs/

: Starting
PROJECTS=$(cat ~/filelist)
for p in ${PROJECTS}; do
	echo "Starting at $(date)" > ~/build_logs/build_${p}.log
	cd ~/aports/${BRANCH}/${p} || continue
	echo "building $p"
	abuild undeps
	abuild clean
	abuild checksum >> ~/build_logs/build_${p}.log 2>&1
	SECONDS=0
	(time abuild -r -K >> ~/build_logs/build_${p}.log 2>&1) &\
	show_processing "$!"
	echo "FINISHED in ${SECONDS} seconds" >> ~/build_logs/build_${p}.log
	abuild undeps
	abuild clean
	echo "sleeping before moving on to next directory"
	sleep 1
	rsync -drvhaP --timeout=30 -e "ssh -o StrictHostKeyChecking=no"\
	      ~/build_logs/ gwalbon@pokgsa.ibm.com:~/web/public/Alpine_builds/
done

exit 0

# {{0..9},{a..c},{d..f},{g..j},k,l,{m..n},o,p{{0..9},{a..d},{g..w}},pe,py{a..z},py3-{a..c},py3-{d..f},py3-{g..o},py3-{p..r},py3-{s..z},{q..s},{t..w},{x..z}}*

RUN = "docker run -d --rm -v $(pwd)/:/home/walbon/Alpine --user=walbon -it alpine:testing /bin/sh /home/walbon/Alpine/full_build.sh "

RUN {0..9}
RUN  a
RUN  b
RUN  c
RUN  {d..f}
RUN  {g..j}
RUN   k
RUN   l
RUN  {m..n}
RUN  o
RUN  p{0..9}
RUN  p{a..d}
RUN  p{g..w}
RUN  pe
RUN  py{a..z}
RUN  py3-{a..c}
RUN  py3-{d..f}
RUN  py3-{g..o}
RUN  py3-{p..r}
RUN  py3-{s..z}
RUN  q
RUN  r
RUN  s
RUN  {t..w}
RUN  {x..z}



