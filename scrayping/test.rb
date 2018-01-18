reg = Regexp.new('foo')

if reg.match('foovar')
  puts reg.match('foovar')
end