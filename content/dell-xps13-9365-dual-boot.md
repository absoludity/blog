Title: Dual booting the Dell XPS13 (9365) with linux
Date: 2017-04-30 19:50
Category: Tutorials

I recently purchased a [Dell XPS13 (9365)][dell-xps13] thanks to my new employer [Bitnami][bitnami]
(obligatory [we're hiring][bitnami-hiring] message), which comes with Windows 10 preinstalled. I was
aware when purchasing that [suspend on Linux is not yet working][suspend-issue]
(thanks [David Farrell][david-farrell], as well as other functionality (autorotate,
pen integration etc.) and so was keen to have a few options to work on this machine:

* Dual booting to Ubuntu/Linux,
* Bash on Windows (mainly just out of interest)
* Running Ubuntu within VirtualBox.

There were already various articles around for setting up dual booting on the Dell XPS13 9365 model,
but none of them had a complete picture. Here's what I did:

* Downloaded and installed all [Dell driver, firmware and application updates][drivers] from Windows 10
* Disabled hibernation, pagefile and system protection to be able to [resize the drive using Windows 10's partition software][resize]
* Switched the SSD drive (and Windows 10) to [AHCI mode][ahci] mode (as Linux doesn't support the default RAID as [David][david-farrell] mentions)

With that done, I was able to install Ubuntu while still dual booting.

[dell-xps13]: http://www.dell.com/au/p/xps-13-9365-2-in-1-laptop/pd?oc=z511203au&model_id=xps-13-9365-2-in-1-laptop
[bitnami]: https://bitnami.com/
[bitnami-hiring]: https://bitnami.com/careers
[shrink-w10-drive]: http://www.download3k.com/articles/How-to-shrink-a-disk-volume-beyond-the-point-where-any-unmovable-files-are-located-00432
[suspend-issue]: https://bugzilla.kernel.org/show_bug.cgi?id=192591
[david-farrell]: http://perltricks.com/article/laptop-review--dell-xps-13-2-in-1--9365-/
[drivers]: http://www.dell.com/support/home/us/en/04/product-support/product/xps-13-9365-2-in-1-laptop/drivers
[resize]: http://www.download3k.com/articles/How-to-shrink-a-disk-volume-beyond-the-point-where-any-unmovable-files-are-located-00432
[ahci]: https://www.tenforums.com/drivers-hardware/15006-attn-ssd-owners-enabling-ahci-mode-after-windows-10-installation.html
