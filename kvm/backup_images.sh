#!/bin/bash
#VERSION=0.0.1
# with VMLIST, do: stop vm, copy vm image to backup folder, start vm

#domain-name:image
VMLIST=( vmname:/var/lib/libvirt/images/vmname.img vmname2:/var/lib/libvirt/images/vmname2.img )
TIMEOUT=120

function stop_vm() {
    virsh shutdown $1
}

function start_vm() {
    virsh start $1
}

for i in ${VMLIST[@]};
do
    _domain=$(echo $i | cut -d':' -f1)
    _image=$(echo $i | cut -d':' -f2)

    stop_vm $_domain

    until $(virsh domstate $_domain | grep -q off);
    do
        echo "Waiting for $_domain to shutdown."
        sleep 2

        COUNT=$(($COUNT+2))
        if [ $COUNT -ge $TIMEOUT ];
        then
            echo "Shutdown timed out (${TIMEOUT}secs)"
            exit 1
        fi  
    done

    cp $_image /media/backup/extra/
    sleep 5
    start_vm $_domain
    sleep 5
    unset _domain
    unset _image
    unset COUNT
done