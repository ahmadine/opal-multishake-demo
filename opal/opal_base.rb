require "opal/base"

def clog(msg)
  `console.log(#{msg})`
end

clog "Hello world!"