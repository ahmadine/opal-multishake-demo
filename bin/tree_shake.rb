#!/usr/bin/env ruby
require 'set'

def get_stubs code
  code
    .scan(/\.add_stubs\(.*?\)/)
    .map { |call| call.scan(/['"]\$(#{$method_re})['"]/) }
    .flatten
    .to_set
end

code = ARGF.read

whitelisted_calls = Set.new(%w(
  new respond_to? register negative?
))
all_filtered = Set.new

$method_re = /[^$'"]+/

method_def = /\w+\.(?:def[sn]?|alias)\(\w+, ?['"]\$?(#{$method_re})['"]/
method_attr = /\w+\.\$attr_(?:reader|writer|accessor)\("#{$method_re}"\)/ # TODO; alias_native maybe?

method_call1 = /\.\$(\w+)/
method_call2 = /\[['"]\$(#{$method_re})['"]\]/
method_alias = /\w+\.alias\(\w+, ?"#{$method_re}", ?"(#{$method_re})"/
method_object = /\w+\.\$method\("(#{$method_re})"\)/
method_send = /\$send\(\w+, ?'(#{$method_re})'/

original_stubs = get_stubs(code)

difference = -1

while difference != 0
  calls = (
    code.scan(method_call1) +
    code.scan(method_call2) +
    code.scan(method_alias) +
    code.scan(method_object) +
    code.scan(method_send) +
    []
  )

  calls = calls
    .flatten
    .to_set

  method_defs = code
    .scan(method_def)
    .flatten
    .to_set

  filtered = method_defs - (calls + whitelisted_calls)
  all_filtered |= filtered

   STDERR.puts(
     method_defs: method_defs.count,
     calls: calls.count,
     whitelisted_calls: whitelisted_calls.count,
     filtered: filtered.count,
   )

  difference = filtered.count

  position = 0
  while position
    position = code.index(method_def, position)
    method_name = $1

    if filtered.include? method_name
      eom = position + 1

      char = nil
      nesting = 0
      until char == ')' && nesting.zero?
        char = code[eom]
        case char
        when '('
          nesting += 1
        when ')'
          nesting -= 1
        end

        eom += 1
      end

      if code[eom] == ','
        code[position..eom] = ''
      else
        code[position...eom] = ''
      end
    else
      if position
        position += 1
      else
        break
      end
    end
  end
end

code = code.gsub(/,([\)\}])/, '\1')
code.gsub!(/\.add_stubs\(.*?\)/) do |match|
  methods = match.scan(/\$(#{$method_re})/).flatten
  stubs = (methods.to_set - all_filtered)
    .map { |stub| "$#{stub}".inspect }
    .join(',')

  ".add_stubs([#{stubs}])"
end
new_stubs = get_stubs(code)

STDERR.puts "Filtered methods:"
STDERR.puts all_filtered.sort.map { |m| "#{m}" }.join(", ")
STDERR.puts "Eliminated #{all_filtered.count} method definitions"
STDERR.puts "Eliminated %d/%d stubs (%d%%)" % [
  (original_stubs - new_stubs).count,
  original_stubs.count,
  (original_stubs - new_stubs).count.to_f * 100 / original_stubs.count,
]

puts code
