require 'time'

out = File.open("M700_2.log", 'w')

File.open('M700.log') do |f|
  start = nil
  f.each do |l|
    out.puts l
    if l =~ /loaded_1\|([A-Z]+)/
      t, = l.split('|')
      if $1 == 'OFF' and start
        e = Time.parse(t)
        out.puts "#{t}|working_time|#{e - start}"
      elsif $1 == 'ON'
        start = Time.parse(t)
      end
    end
  end
end
