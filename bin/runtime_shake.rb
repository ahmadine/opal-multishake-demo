#!/usr/bin/env ruby
require 'set'
require 'pp'
code = ARGF.read

r1 = /[^=]\sfunction\s+([$\w]+)\s*\(/
r2 = /Opal\.([$\w]+)\s*=\s*function/

difference = -1

while difference != 0
  ra = (code.scan(r1).flatten + code.scan(r2).flatten)
  rs = ra.to_set

  filtered = rs.map do |fun|
    [fun, code.scan(/#{Regexp.escape(fun)}\s*[(),;=]/).count]
  end.select do |fun,c|
    c <= ra.count(fun) || 
    (fun == 'binomial_coefficient' && c == 3)    # References itself... twice
  end.map { |a,b| a }

  difference = filtered.count

  STDERR.puts "filtering: #{difference} : #{filtered.join(" , ")}"

  filtered.each do |fun|
    fx = Regexp.escape(fun)
    r0 = /\sfunction\s+#{fx}\s*|Opal\.#{fx}\s*=\s*function/

    position = code.index(r0, 0)
    eom = position + 1

    char = nil
    nesting = 0
    until char == '}' && nesting.zero?
      char = code[eom]
      case char
      when '{'
        nesting += 1
      when '}'
        nesting -= 1
      end

      eom += 1
    end

    if code[eom] == ','
      code[position..eom] = ''
    else
      code[position...eom] = ''
    end
  end
end

puts code