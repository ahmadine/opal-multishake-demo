#!/bin/sh
ruby bin/runtime_shake.rb     $1              >  /tmp/shake.1.js
ruby bin/const_shake.rb       /tmp/shake.1.js >  /tmp/shake.2.js
ruby bin/tree_shake.rb        /tmp/shake.2.js >  /tmp/shake.3.js
ruby bin/runtime_shake.rb     /tmp/shake.3.js >  /tmp/shake.4.js
ruby bin/const_shake.rb       /tmp/shake.4.js >  /tmp/shake.5.js
ruby bin/tree_shake.rb        /tmp/shake.5.js >  /tmp/shake.6.js
ruby bin/runtime_shake.rb     /tmp/shake.6.js >  /tmp/shake.7.js
ruby bin/const_shake.rb       /tmp/shake.7.js >  /tmp/shake.8.js
ruby bin/tree_shake.rb        /tmp/shake.8.js >  /tmp/shake.9.js

fgrep -v '.add_stubs('        /tmp/shake.9.js > /tmp/shake.10.js
fgrep -v '.add_stub_for(obj' /tmp/shake.10.js > /tmp/shake.11.js

ruby bin/runtime_shake.rb    /tmp/shake.11.js
