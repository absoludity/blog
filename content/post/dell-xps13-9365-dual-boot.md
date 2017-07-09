---
title: Dual booting the Dell XPS13 (9365) with linux
description: "Here we go"
date: 2017-04-30T19:50:00+10:00
tags: [ "ubuntu", "linux", "dell", "tutorial", "bitnami" ]
type: post
---

I recently purchased a [Dell XPS13 (9365)][dell-xps13] (thanks to
[Bitnami][bitnami] for whom I now work) which comes with Windows 10 preinstalled. I was
aware when purchasing that [suspend on Linux is not yet working][suspend-issue]
(thanks [David Farrell][david-farrell]), as well as other functionality
(autorotate, pen integration etc.) and so was keen to have a few options to
work on this machine<!--more-->:

* Running Ubuntu within VirtualBox.
* Dual booting to Ubuntu/Linux (once the suspend issues fixed, I'll be using this most of the time)
* Bash on Windows (mainly just out of interest)

There were already various articles around for setting up dual booting on the Dell XPS13 9365 model,
but none of them had a complete picture. Here's what I did:

* Downloaded and installed all [Dell driver, firmware and application updates][drivers] from Windows 10
* Temporarily disabled hibernation, pagefile and system protection to be able to [resize the drive using Windows 10's partition software][resize]
* Switched the SSD drive (and Windows 10) to [AHCI mode][ahci] mode (as Linux doesn't support the default [NVMExpress][nvme] RAID as [David][david-farrell] mentions)

With that done, I was able to install Ubuntu while still dual booting. I am
currently booting Windows and working within an Ubuntu 17.04 VirtualBox image
as I move around quite a bit and depend on suspend/resume. But the difference
between running in a VM and on the metal is noticeable so I'll be watching the
suspend bug and testing newer kernel releases.

*Edit July 2017*: For the short-term, it actually works fine to just update my Ubuntu power settings
so that the computer doesn't suspend when the lid is closed.

[dell-xps13]: http://www.dell.com/au/p/xps-13-9365-2-in-1-laptop/pd?oc=z511203au&model_id=xps-13-9365-2-in-1-laptop
[bitnami]: https://bitnami.com/
[bitnami-hiring]: https://bitnami.com/careers
[shrink-w10-drive]: http://www.download3k.com/articles/How-to-shrink-a-disk-volume-beyond-the-point-where-any-unmovable-files-are-located-00432
[suspend-issue]: https://bugzilla.kernel.org/show_bug.cgi?id=192591
[david-farrell]: http://perltricks.com/article/laptop-review--dell-xps-13-2-in-1--9365-/
[drivers]: http://www.dell.com/support/home/us/en/04/product-support/product/xps-13-9365-2-in-1-laptop/drivers
[resize]: http://www.download3k.com/articles/How-to-shrink-a-disk-volume-beyond-the-point-where-any-unmovable-files-are-located-00432
[ahci]: https://www.tenforums.com/drivers-hardware/15006-attn-ssd-owners-enabling-ahci-mode-after-windows-10-installation.html
[nvme]: https://en.wikipedia.org/wiki/NVM_Express
