a=[1,2,3,4]
b=[3,2,1]
c=[8,3,9,6,4,7,5,2,1]

# def perm(arr,result)
# 	if arr.length>0
# 		arr.each do |i|
# 			result<<i
# 			perm(arr-[i],result)
# 		end	
# 	else
# 		puts "#{result}"
# 	end
# end

# perm(a,[])

#字典序法,很奇妙的算法，虽然已经用代码实现，但道理还没明白
def swap(a,m,n)
	tmp = a[m]
	a[m] = a[n]
	a[n] = tmp
end

def perm(list)
	list.sort!
	result = []
	while true
		result << list
		puts "#{list}"
		puts "#{result}"
		#如果没有需要调换的，就认为遍历完成
		nochange = true
		#从右边开始，寻找左边比相邻右边小的数，位置为m
		(list.size-2).downto(0) do |m|
			if list[m]<list[m+1] 
				#如果找到，将nochange改为false
				nochange = false
				#从右边开始，查找比位置m对应的值大的数的位置，记为n，并交换m和n的值。
				(list.size-1).downto(m+1) do |n|
					if list[m]<list[n]
						swap(list,m,n)
						break
					end
				end
				#将m之后的数交换前后顺序
				tail=[]
				tail_size=(list.size-1)-(m+1)

				if tail_size>=1
					tail_size.downto(0) do
					  tail<<list.pop
					end
					list+=tail
				end
				
				# puts "#{list}"
				break 
			end
		end
		break if nochange
	end
	result
end

# perm(b).each do |arr|
# 	puts "#{arr}"
# end

perm(b)
# 10.downto(1) do |i|
# 	puts i
# 	if i==5 
# 		break
# 	end

# end
