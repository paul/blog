#!/usr/bin/env rackup
require File.dirname(__FILE__) + "/lib/restblog"
 
run Restblog.new(File.dirname(__FILE__))
