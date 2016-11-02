Meza Packages
=============

Repository to build and maintain meza RPMs.


Building RPMs
=============



```bash
yum install git -y
cd ~
git clone https://github.com/enterprisemediawiki/meza-packages
cd meza-packages
cd <the package you want to build>
sudo bash build-rpm.sh
```

After the package is built, the RPM file in `~/meza-packages/RPMs` will be added (replacing any old ones). To push these to github:

```bash
git checkout -b new-branch-name
git status
git add -A
git commit -m "what you changed and why"
git push origin new-branch-name
```
