# LeetCode 1512. Number of Good Pairs
class Solution:
	def numIdenticalPairs(self, nums: list[int]) -> int:
		cnt_result = 0
		for i in range(len(nums)):
			for j in range(i+1, len(nums)):
				if nums[i] == nums[j]:
					cnt_result += 1
		return cnt_result
