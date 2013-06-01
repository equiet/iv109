#!/usr/bin/env ruby

require 'json'

def distribution(probability)
	last_occurence = -1
	distribution = Hash.new(0)
	findings = 0
	10000.times do |i|
		if Random.rand(100) < probability
			distribution[i - last_occurence] += 1
			last_occurence = i
			findings += 1
		end
	end
	puts findings
	distribution.sort_by { |k,v| k }
end

(10..100).step(10) do |n|
	printf "%6s",  "#{n} | "
	distribution(n).each do |k,v|
		printf "%6s", "#{v.to_f / 100}"
	end
	puts
end