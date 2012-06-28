file = ARGV[0]
output = File.open(ARGV[1], "w+")
#tabwidth = ARGV[1]

lines = File.open(file).readlines
lines.each {|l| l.chomp!}

def depth(line)
   line.length - line.lstrip.length
end

def next_non_zero(line_num, depths)
   until depths[line_num].nil? or depths[line_num] > 0
      line_num += 1
   end
   depths[line_num].nil? ? 0 : depths[line_num]
end

post_stack = []
pre_stack = []

end_keywords = %w(module class def if while until unless)
line_num = 0
depths = lines.map {|l| depth(l)}

puts depths
puts "====="

lines.each do |line|
   prefixed = false
   puts line
   # get the indent depth and strip leading whitespace
   # get rid of trailing whitespace
   line.lstrip!
   line.rstrip!

   if line.start_with?("#")
      next
   end

   until (post_top = post_stack.last).nil?
      puts "#{line_num} #{post_top[1]} #{next_non_zero(line_num, depths)}"

      unless line.start_with?("else")
         if post_top[1] >= next_non_zero(line_num, depths)
               output.puts " " * post_top[1] + "end"
               post_stack.pop
         else
            break
         end
      else
         break
      end
   end

   kw = nil
   if end_keywords.map {|w| line.start_with?(w) ? kw = w : false}.any? or line.match(" do")
      unless line.end_with?("end")
         post_stack.push [kw, depths[line_num]]
      end
   end
   
   if line.end_with?('.')
      puts "ENNNNNNDS WITH #{line}"
      pre_stack.push [line, depths[line_num]]
      prefixed = true
   else
      unless pre_stack.empty?
         if depths[line_num] > pre_stack.last[1]
            output.puts " " * pre_stack.last[1] + pre_stack.last[0] + line
            prefixed = true
         else
            pre_stack.pop
         end
      end
   end


   puts "Line #{line_num} -----"

   output.puts " " * depths[line_num] << line unless prefixed

   line_num += 1

end

until post_stack.empty?
   output.puts " " * post_stack.pop[1] + "end"
end
