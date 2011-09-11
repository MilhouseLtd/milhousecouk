---
layout: post
title: Mounting NFS Shares on OS X
tags: [server, os x]
---

When doing cross development I find it convenient to build any source code on an NFS mounted directory. This can then be accessed directly from embedded clients as well as the build machine without the need to ftp binaries to the host for executing. My NFS shares are exported from my Ubuntu server and I connect to them from my OS X build machine.

Under OS X it is really simple to access these shares using dynamic automounting. You can simply cd to the share without any setup at all using something like:

> $ cd /net/server.name/export/share

Where server.name is the NFS server hostname, and /export/share is the exported directory. I create a soft link in my home directory so that I can cd directly to the shared directory after running Terminal.app.

This usually works well, NFS has been around for a long time and is well tested. However, I was sometimes getting problems accessing the NFS mount from OS X, sometimes I could access the drive and sometimes not. From the command line I would get the error:

> -bash: cd: dev: Operation timed out

All the other machines on the network had no problems so I knew it was a problem on my MacBook Pro.

Well, after a bit of Googling it turns out that for security NFS requires that all requests originate on an internet port less than 1024. OS X does not always abide by this rule. It is possible on the server in the /etc/hosts file to override this by adding the insecure option to the export line. This is initially what I tried. But this didn’t seem to be 100% effective, it was still slow when accessing the NFS share for the first time and what’s more I wasn’t happy in circumventing an obvious security measure.

So after restoring /etc/exports and restarting the NFS daemon I tried the other approach, fix it on the OS X client end. There are two ways to do this, the first is to edit /etc/autofs.conf and look for the AUTOMOUNTD_MNTOPTS option. Add rescport to the end of the line so it looks something like:

> AUTOMOUNTD_MNTOPTS=nosuid,nodev,resvport

This will force the Mac to use reserved ports for all NFS requests. The second way (which is the approach I took) is to edit /etc/auto_master. Find the line that starts /net, and add the resvport option to the end so it becomes:

> /net -hosts -nobrowse,hidefromfinder,nosuid,resvport

This causes the Mac to use reserved ports only for those mounts under /net which are the dynamic mounts.

Since doing this NFS seems a lot faster and connects every time.