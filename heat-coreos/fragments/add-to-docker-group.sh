#!/bin/sh

# Under atomic, we need to make sure the 'docker' group exists in 
# /etc/group (because /lib/group cannot be modified by usermod).
echo "making 'docker' group editable"
if ! grep -q docker /etc/group; then
	grep docker /lib/group >> /etc/group
fi
