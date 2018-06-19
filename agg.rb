class Result
  @target
  @sample
  @duration
  @child
  @range
  @client
  @loop
  @avg
  @med
  @name

  def initialize(name, target, sample, duration, child, client, range, loop, avg, med)
    @name = name
    @target = target
    @sample = sample
    @duration = duration
    @child = child
    @client = client
    @range = range
    @loop = loop
    @avg = avg
    @med = med
  end

  attr_accessor :target, :sample, :duration, :child, :range, :loop, :client, :avg, :med, :name
end

results = []
Dir.glob("*") do |dir|
  next if dir !~ /(master|ext).*/

  target = sample = duration = child = client = range = loop = ""
  tps_sum = 0
  tps_num = 0
  tps_median = []
  File.open(dir + "/result.txt") do |file|
    file.each_line do |line|
      if line =~ /TARGET = .*/ then target = line.split(" ")[2] end
      if line =~ /SAMPLES = .*/ then sample = line.split(" ")[2] end
      if line =~ /DURATION = .*/ then duration = line.split(" ")[2] end
      if line =~ /CHILDS = .*/ then child = line.split(" ")[2] end
      if line =~ /CLIENTS = .*/ then client = line.split(" ")[2] end
      if line =~ /RANGE = .*/ then range = line.split(" ")[2] end
      if line =~ /LOOPS = .*/ then loop = line.split(" ")[2] end

      if line =~ /.*including.*/ then
        tps_median << line.split(" ")[2].to_f
        tps_sum += line.split(" ")[2].to_f
        tps_num = tps_num + 1
      end
    end
  end

  res = Result.new(dir, target, sample, duration, child, client, range, loop, tps_sum / tps_num, tps_median[tps_num / 2])
  results << res
end

marked = Array.new(results.length)
results.each_with_index do |r1, idx1|

  next if r1.target == "master"

  results.each_with_index do |r2, idx2|

    next if r2.target == "ext"

#    if !marked[idx2].nil? then
#      next
#    end

    if r1.target != r2.target and
        r1.sample == r2.sample and
        r1.duration == r2.duration and
        r1.child == r2.child and
        r1.client == r2.client and
        r1.range == r2.range and
        r1.loop == r2.loop then
      p "-------#{idx1} - #{idx2} ----------"
      p r1
      p r2
      marked[idx2] = true
    end
  end
end

