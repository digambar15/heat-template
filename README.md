A Kubernetes cluster with Heat
==============================

These [Heat][] templates will deploy an *N*-node [Kubernetes][] cluster,
where *N* is the value of the `number_of_minions` parameter you
specify when creating the stack.

[heat]: https://wiki.openstack.org/wiki/Heat
[kubernetes]: https://github.com/GoogleCloudPlatform/kubernetes

The cluster uses [Flannel][] to provide an overlay network connecting
pods deployed on different minions.

[flannel]: https://github.com/coreos/flannel

## Requirements

### OpenStack

These templates will work with the Juno version of Heat.

Add coreos image in glance - 

$ wget http://alpha.release.core-os.net/amd64-usr/current/coreos_production_openstack_image.img.bz2
$ bunzip2 coreos_production_openstack_image.img.bz2
$ glance image-create --name core-os \
  --container-format bare \
  --disk-format qcow2 \
  --file coreos_production_openstack_image.img \
  --is-public True


### Guest image

These templates will work with either CentOS Atomic Host or Fedora 21
Atomic.  You will need an image dated later than 2015-01-20 in order
to have both the `flannel` package installed and the appropriately
configured `docker.service` unit.

You can enable the VXLAN backend for flannel by setting the
"flannel_use_vxlan" parameter to "true", but I have run into kernel
crashes using that backend with CentOS 7.  It seems to work fine with
Fedora 21.

## Creating the stack

Creating an environment file `local.yaml` with parameters specific to
your environment:

    parameters:
      ssh_key_name: default 
      external_network_id: 028d70dd-67b8-4901-8bdd-0c62b06cce2d
      dns_nameserver: 192.168.200.1
      server_image: core-os

And then create the stack, referencing that environment file:

    heat stack-create -f kubecluster.yaml -e local.yaml my-kube-cluster

You must provide values for:

- `ssh_key_name`
- `external_network_id`
- `server_image`

## Interacting with Kubernetes

You can get the ip address of the Kubernetes master using the `heat
output-show` command:

    $ heat output-show my-kube-cluster kube_master
    "192.168.200.86"

You can ssh into that server as the `minion` user:

    $ ssh minion@192.168.200.86

And once logged in you can run `kubectl`, etc:

    $ kubectl get minions
    NAME                LABELS
    10.0.0.4            <none>

You can log into your minions using the `minion` user as well.  You
can get a list of minion addresses by running:

    $ heat output-show my-kube-cluster kube_minions_external
    [
      "192.168.200.182"
    ]

## Testing

The templates install an example Pod and Service description into
`/etc/kubernetes/examples`.  You can deploy this with the following
commands:

    $ kubectl create -f /etc/kubernetes/examples/web.service
    $ kubectl create -f /etc/kubernetes/examples/web.pod

This will deploy a minimal webserver and a service.  You can use
`kubectl get pods` and `kubectl get services` to see the results of
these commands.
