# Initialize an array of integers for the currently live web nodes.
webnodes=()
deadcount=0
i=1
while [[ deadcount -lt 5 ]]; do
  # only send 1 ping, and wait a maximum of 1 second for the answer
  if ping -c 1 -W 1 "www$i.drupal.org" ; then
    webnodes+=($i)
    deadcount=0
  else
    echo "www$i.drupal.org is dead"
    ((deadcount++))
  fi
  ((i++))
done  

for i in ${webnodes[@]}; do
  echo "www$i.drupal.org is alive"
done
