require 'rspec'

def undent(raw)
  if raw =~ /\A( +)/
    indent = $1
    raw.gsub(/^#{indent}/, '').gsub(/ +$/, '')
  else
    raw
  end
end
