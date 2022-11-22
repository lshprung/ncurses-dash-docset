require 'pathname'

puts %Q[
  CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);
  CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);
]

INSERT_SQL = %Q[
  INSERT INTO searchIndex(name, type, path) VALUES ('%s','%s','%s');
]

PATTERN = %r[<title>(.*)\(Autoconf\)(.*)</title>]

BUILTIN_PATTERN = /The node you are looking for is at.*Limitations-of-.*\.html/
MACRO_PATTERN = /The node you are looking for is at/

def quote(s)
  s.gsub(/&amp;/, '&').gsub(/'/, "\\'").gsub(/&lt;/, '<')
end

ARGV.each do |arg|
  Pathname.glob(arg) do |path|
    macro_match = path.each_line.lazy.map { |line| MACRO_PATTERN.match(line) }.find { |m| m }
    builtin_match = path.each_line.lazy.map { |line| BUILTIN_PATTERN.match(line) }.find { |m| m }
    if builtin_match
      type = "Builtin"
    elsif macro_match
      type = "Macro"
    else
      type = "Guide"
    end

    match = path.each_line.lazy.map { |line| PATTERN.match(line) }.find { |m| m }
    if match
      printf INSERT_SQL, quote(match[1]), type, path.basename
    else
      $stderr.puts "%{path.basename}: no title found"
    end
  end
end
