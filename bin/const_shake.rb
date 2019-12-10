#!/usr/bin/env ruby
require 'set'
require 'pp'
code = ARGF.read

r1 = /\(function\(\$base, \$super, \$parent_nesting\) \{\s+var self = \$klass\(\$base, \$super, '(\w+)'\);/
r2 = /\(function\(\$base, \$parent_nesting\) \{\s+var self = \$module\(\$base, '(\w+)'\);/
r3 = /Opal\.const_set\([$\w\[\]]+, ['"](\w+)['"]/
#r2 = /Opal\.([$\w]+)\s*=\s*function/

difference = -1

while difference != 0
  ra = (code.scan(r1).flatten + code.scan(r2).flatten + code.scan(r3).flatten)
  rs = ra.to_set

  filtered = rs.map do |fun|
    [fun, code.scan(/[.'"]#{Regexp.escape(fun)}[.'"]/).count]
  end.select do |fun,c|
    c <= ra.count(fun) && fun != "Number"
  end.map { |a,b| a }

  difference = filtered.count

  STDERR.puts "filtering: #{difference} : #{filtered.join(" , ")}"

  filtered.each do |fun|
    fx = Regexp.escape(fun)
    r0 = Regexp.union(
      /\(function\(\$base, \$super, \$parent_nesting\) \{\s+var self = \$klass\(\$base, \$super, '#{fx}'\)/,
      /\(function\(\$base, \$parent_nesting\) \{\s+var self = \$module\(\$base, '#{fx}'\);/)
    rx = /Opal\.const_set\([$\w\[\]]+, ['"]#{fx}['"]/

    position = code.index(r0, 0)
    once = false
    if !position
      once = true
      position = code.index(rx, 0) 
    end

    eom = position
    if !eom
      STDERR.puts "error: can't find #{fun} :(("
      next
    end

    char = nil
    nesting = 0
    twice = once ? 1 : 2
    until char == ')' && twice.zero?
      char = code[eom]
      case char
      when '('
        nesting += 1
      when ')'
        nesting -= 1
      end

      eom += 1
      twice -= 1 if char == ')' && nesting.zero?
    end

    #STDERR.puts code[position...eom]
    if code[eom] == ','
      code[position..eom] = ''
    else
      code[position...eom] = ''
    end
  end
end

puts code