mkdir -p mock-setup fedora-{2{3,4},rawhide}-{x86_64,i386}

cp /etc/mock/fedora-{2{3,4},rawhide}-{x86_64,i386}* mock-setup

sed -i "/config_opts.*root/ s/fedora/ruby-chkbuild-fedora/" mock-setup/*
sed -i "/config_opts.*yum\.conf/i \\
config_opts['plugin_conf']['bind_mount_opts']['dirs'].append(('.', '/chkbuild' )) \\
  " mock-setup/*

for f in fedora-{2{3,4},rawhide}-{x86_64,i386}; do
#for f in fedora-23-i386; do

  echo -e "****************************\n$(date)\n****************************"

  ln -s -f $f tmp

  mock -r mock-setup/$f.cfg --rootdir=$(pwd)/$f/root --resultdir=$(pwd)/$f/result --scrub=all
  mock -r mock-setup/$f.cfg --rootdir=$(pwd)/$f/root --resultdir=$(pwd)/$f/result \
    --install /usr/bin/{ruby,autoconf,bison,svn,ps} rubygems libffi-devel openssl-devel || \
    mock -r mock-setup/$f.cfg --rootdir=$(pwd)/$f/root rubygems --resultdir=$(pwd)/$f/result \
    --install {,/usr}/bin/{ruby,autoconf,bison,svn,ps} libffi-devel openssl-devel
  mock -r mock-setup/$f.cfg --rootdir=$(pwd)/$f/root --resultdir=$(pwd)/$f/result --chroot "
    su -c '
      cd /chkbuild
      ruby -d start-build
    ' - mockbuild
  "


#  mock -r mock-setup/$f.cfg --rootdir=$(pwd)/$f/root --resultdir=$(pwd)/$f/result --chroot "
#    su -c '
#      cd /chkbuild/tmp/build/20151029T155900Z/ruby
#      ls -la
#      make TESTS=-v RUBYOPT=-w test-all
#    ' - mockbuild
#  "

  rm -rf tmp
done
