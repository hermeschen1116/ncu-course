# sh wrap.sh /usr/core/bin/mmvm /usr/local/minix /usr/local/bin/m2 /usr/bin/cc
run=$1
root=$2
cmd=$3`basename $4`
wrap=$2/$4

cat << EOT > $cmd
#!/bin/sh
opt=""
if [ "x\$1" = "x--m" ]; then opt="-m" shift; fi
EOT

echo "exec $run \$opt -r $root $wrap \$@" >> $cmd

chmod 755 $cmd
