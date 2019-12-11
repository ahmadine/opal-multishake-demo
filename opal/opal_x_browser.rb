# This is hardly a real test, because we run it on node,
# but this test is intended to simulate a code reduction
# on a very small real code and quite a large library.

require "opal"

%x{
  // Make node shut up about this not being a browser.
  // This is a browser... just a "bit" limited.
  var window = Opal.global;
  
  if (!window.window) window.window = window;
  if (!window.navigator) window.navigator = {
    userAgent: "Mozilla/4.0 (compatible; like Gecko)",
  };
  if (!window.document) window.document = {
    documentElement: {},
    createElement: function() {
      return {
        setAttribute: function() {},
        attributes: {
          id: {}
        },
        nodeType: 1,
      };
    },
    nodeType: 9,
  };
}

require "opal-browser"

puts "Hello world!"
