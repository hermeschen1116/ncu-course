# LeetCode 1672. Richest Customer Wealth
class Solution:
	def maximumWealth(self, accounts: list[list[int]]) -> int:
		max_result = -1
		for account in accounts:
			if sum(account) >= max_result:
				max_result = sum(account)
		return max_result
