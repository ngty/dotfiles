#
# Author::  Christoph Kappel <unexist@dorfelite.net>
# Version:: $Id: data/subtle.rb,v 2978 2011/08/02 11:16:25 unexist $
# License:: GNU GPLv2
#
# = Subtle default configuration
#
# This file will be installed as default and can also be used as a starter for
# an own custom configuration file. The system wide config usually resides in
# +/etc/xdg/subtle+ and the user config in +HOME/.config/subtle+, both locations
# are dependent on the locations specified by +XDG_CONFIG_DIRS+ and
# +XDG_CONFIG_HOME+.
#

Dir[File.expand_path('../configs/*.rb', __FILE__)].sort.each do |config|
  instance_eval(File.read(config))
end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
